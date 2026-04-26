/**
 * Credit Intelligence Agent (CIA) — supabase/functions/cia-agent/index.ts
 *
 * Synthesises signals from all three monitoring agents into structured credit
 * intelligence. Operates in three modes selected via request body { mode }:
 *
 * briefing (default)
 *   Reads unprocessed credit_events (cia_processed = false), calls Claude Opus
 *   to produce a portfolio-wide daily briefing, writes DAILY_BRIEFING and
 *   COMPOSITE_RISK events, and marks source events cia_processed = true.
 *   Demo: returns DEMO_BRIEFING constant; no API call.
 *
 * question
 *   Accepts { question: string }. Keyword-filters credit_events on title and
 *   description (up to 3 keywords, ilike), falls back to most recent 15 if
 *   fewer than 2 results. Calls Claude Sonnet (live) or Claude Haiku (demo).
 *   Returns { answer, sources[], confidence, confidence_reason }.
 *   Note: makes a real API call even in DEMO_MODE.
 *
 * suggestions
 *   Returns 4 suggested questions based on recent credit signals.
 *   Calls Claude Haiku (live) or returns DEMO_SUGGESTIONS (demo).
 *
 * Request body: { mode?: "briefing"|"question"|"suggestions", question?: string,
 *                 force_refresh?: boolean, customer_id?: string }
 * Response (briefing): { run_id, briefing, events_processed, stale_agents, messages }
 * Response (question): { answer, sources[], confidence, confidence_reason }
 * Response (suggestions): { suggestions: string[] }
 *
 * Tables read:  credit_events, customers, agent_runs
 * Tables written (briefing): credit_events (DAILY_BRIEFING, COMPOSITE_RISK*), agent_runs
 *
 * Demo mode: Controlled by DEMO_MODE=true Supabase secret.
 */
// supabase/functions/cia-agent/index.ts
// Credit Intelligence Agent (CIA) — synthesises signals from all agents into daily briefings

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Anthropic from "https://esm.sh/@anthropic-ai/sdk@0.27.0";

// ─── Types ───────────────────────────────────────────────────────────────────

interface CreditEvent {
  id: string;
  scope: string;
  customer_id: string | null;
  customer_ids: string[] | null;
  event_type: string;
  source_agent: string;
  severity: "critical" | "high" | "medium" | "low" | "info";
  signal_type: string | null;
  title: string;
  description: string | null;
  payload: Record<string, unknown>;
  credit_rating_score: number | null;
  credit_rating_raw: string | null;
  credit_rating_source: string | null;
  action_required: boolean;
  action_type: string | null;
  action_status: string | null;
  cia_processed: boolean;
  run_id: string | null;
  created_at: string;
}

interface Customer {
  id: string;
  name: string;
  ticker: string | null;
  company_type: "public" | "private" | "sme";
  credit_limit: number | null;
  current_balance: number | null;
}

interface AgentRun {
  id: string;
  agent_name: string;
  status: string;
  completed_at: string | null;
  created_at: string;
}

interface CIARequest {
  mode?: "briefing" | "question" | "suggestions";
  question?: string;
  force_refresh?: boolean;
  customer_id?: string;
}

// ─── Constants ───────────────────────────────────────────────────────────────

const DEMO_SEED_RUN_ID = "cia-demo-seed-00000000-0000-0000-0000-000000000001";

const CACHE_TTL: Record<string, number> = {
  "ar-aging-agent":  24 * 60 * 60 * 1000,
  "news-monitor-agent": 4 * 60 * 60 * 1000,
  "sec-monitor-agent": 48 * 60 * 60 * 1000,
};

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const DEMO_SUGGESTIONS = [
  "Why is Triumph Group flagged across multiple agents?",
  "Which customers have the highest credit risk right now?",
  "Should I reduce Arconic's credit limit?",
  "What's my biggest portfolio exposure today?",
];

// ─── Demo Seed Data ───────────────────────────────────────────────────────────

const DEMO_BRIEFING = `## Credit Intelligence Briefing — Demo Portfolio

**Executive Summary**

Your portfolio shows elevated multi-signal risk on Triumph Group. Three independent agents have flagged this counterparty: overdue AR in the 61–90 day bucket, a covenant waiver disclosure in their latest SEC filing, and negative news coverage around liquidity concerns. This convergence of signals warrants immediate credit limit review.

**Critical Alerts (1)**

- **Triumph Group** — Multi-signal convergence: AR 61–90 days overdue ($420K), SEC covenant waiver filed, negative news sentiment HIGH. Recommended action: reduce credit limit from $1.5M to $750K pending management call.

**High Severity (3)**

- **Heliogen Inc** — Going concern warning in latest 10-K. No current AR exposure but flag for new order approvals.
- **GE Aerospace** — Credit utilization at 87% ($4.35M / $5M limit). Approaching concentration threshold.
- **Kaman Corp** — $180K overdue 31–60 days. Dunning stage 2 letter recommended.

**Macro Signal**

Aerospace & Defense sector showing stress signals across 3 of 7 monitored counterparties. Recommend sector-level credit limit review at next monthly governance meeting.

**Pending Actions Awaiting Your Approval**

3 credit limit reductions are staged and awaiting approval in the Actions panel.`;

const DEMO_MESSAGES = [
  {
    role: "assistant",
    content: DEMO_BRIEFING,
  },
];

// ─── Helpers ─────────────────────────────────────────────────────────────────

function isStale(lastRun: AgentRun | null, agentName: string): boolean {
  if (!lastRun?.completed_at) return true;
  const ttl = CACHE_TTL[agentName] ?? 24 * 60 * 60 * 1000;
  return Date.now() - new Date(lastRun.completed_at).getTime() > ttl;
}

function groupEventsByCustomer(events: CreditEvent[]): Record<string, CreditEvent[]> {
  const grouped: Record<string, CreditEvent[]> = {};
  for (const evt of events) {
    const key = evt.customer_id ?? "__portfolio__";
    grouped[key] = grouped[key] ?? [];
    grouped[key].push(evt);
  }
  return grouped;
}

function severityRank(s: string): number {
  return { critical: 4, high: 3, medium: 2, low: 1, info: 0 }[s] ?? 0;
}

function buildSystemPrompt(customers: Customer[]): string {
  const customerMap = customers.map(c =>
    `- ${c.name} (id: ${c.id}, type: ${c.company_type}, credit limit: $${c.credit_limit?.toLocaleString() ?? "N/A"}, balance: $${c.current_balance?.toLocaleString() ?? "0"})`
  ).join("\n");

  return `You are the Credit Intelligence Agent (CIA) for CreditPilot, an autonomous B2B trade credit management system.

Your role is to synthesise signals from multiple monitoring agents — AR Aging, News Monitor, and SEC Filing Monitor — into actionable credit intelligence. You think like a senior credit analyst at a trade credit insurance company.

**Portfolio customers:**
${customerMap}

**Your output format:**
1. Start with a brief executive summary (2–3 sentences).
2. List CRITICAL alerts first, then HIGH, MEDIUM.
3. For each alert: customer name, signal summary, cross-agent correlation if applicable, recommended action.
4. Highlight any customers appearing in multiple agent signals — these are highest priority.
5. End with any macro/sector observations.
6. If the user asked a specific question, answer it directly after the briefing under "## Your Question".

**Principles:**
- Be specific: cite amounts, dates, event types.
- Flag multi-signal convergence explicitly — it's the most important pattern.
- Distinguish between "act now" and "monitor closely".
- Never fabricate data; work only with the events provided.
- Keep the briefing scannable — use markdown headers and bullets.`;
}

function buildUserPrompt(
  events: CreditEvent[],
  customers: Customer[],
  question?: string
): string {
  const customerById = Object.fromEntries(customers.map(c => [c.id, c]));

  const eventSummaries = events
    .sort((a, b) => severityRank(b.severity) - severityRank(a.severity))
    .map(evt => {
      const customer = evt.customer_id ? customerById[evt.customer_id] : null;
      return [
        `[${evt.severity.toUpperCase()}] ${evt.event_type}`,
        `  Customer: ${customer?.name ?? evt.customer_id ?? "Portfolio"}`,
        `  Agent: ${evt.source_agent}`,
        `  Title: ${evt.title}`,
        evt.description ? `  Detail: ${evt.description}` : null,
        evt.credit_rating_score != null ? `  Credit score: ${evt.credit_rating_score}/100` : null,
        evt.action_required ? `  Action required: ${evt.action_type ?? "review"}` : null,
        `  Event ID: ${evt.id}`,
      ].filter(Boolean).join("\n");
    })
    .join("\n\n");

  const parts = [
    `Here are ${events.length} unprocessed credit events from your monitoring agents:`,
    "",
    eventSummaries,
  ];

  if (question) {
    parts.push("", `## User question: ${question}`);
  }

  return parts.join("\n");
}

function extractText(message: Anthropic.Message): string {
  return message.content
    .filter(b => b.type === "text")
    .map(b => (b as { type: "text"; text: string }).text)
    .join("");
}

// ─── Main Handler ─────────────────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const DEMO_MODE = Deno.env.get("DEMO_MODE") === "true";

  const jsonRes = (data: unknown, status = 200) =>
    new Response(JSON.stringify(data), {
      status,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });

  let body: CIARequest = {};
  try {
    body = await req.json();
  } catch {
    // empty body is fine
  }

  const { mode = "briefing", question, force_refresh = false, customer_id } = body;

  // ── SUGGESTIONS mode ──────────────────────────────────────────────────────
  if (mode === "suggestions") {
    if (DEMO_MODE) {
      return jsonRes({ suggestions: DEMO_SUGGESTIONS });
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return jsonRes({ error: "Unauthorized" }, 401);

    const { data: recentEvents } = await supabaseClient
      .from("credit_events")
      .select("event_type, severity, source_agent, title, customers!left(company_name)")
      .order("created_at", { ascending: false })
      .limit(10);

    const eventsText = (recentEvents ?? []).map((e: any) =>
      `[${String(e.severity).toUpperCase()}] ${e.event_type} — ${e.title} (${e.source_agent}) — ${e.customers?.company_name ?? "Portfolio"}`
    ).join("\n");

    const anthropic = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY")! });

    try {
      const message = await anthropic.messages.create({
        model: "claude-haiku-4-5",
        max_tokens: 200,
        system: "You are a credit analyst assistant. Given these recent credit signals, generate exactly 4 short questions a credit manager would want to ask. Return ONLY a JSON array of 4 strings, no other text.",
        messages: [{ role: "user", content: `Recent credit signals:\n${eventsText}` }],
      });

      const text = extractText(message);
      const cleaned = text.replace(/^```json\s*/i, "").replace(/^```\s*/i, "").replace(/\s*```$/i, "").trim();
      const suggestions = JSON.parse(cleaned);
      return jsonRes({ suggestions });
    } catch {
      return jsonRes({ suggestions: DEMO_SUGGESTIONS });
    }
  }

  // ── QUESTION mode ──────────────────────────────────────────────────────────
  if (mode === "question") {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return jsonRes({ error: "Unauthorized" }, 401);
    if (!question) return jsonRes({ error: "question is required" }, 400);

    // Extract keywords from the question (words > 4 chars, strip punctuation)
    const keywords = question
      .split(/\s+/)
      .map((w: string) => w.toLowerCase().replace(/[?!.,'"]/g, ""))
      .filter((w: string) => w.length > 4);

    let events: any[] = [];

    if (keywords.length > 0) {
      const orFilter = keywords.slice(0, 3)
        .flatMap((kw: string) => [`title.ilike.%${kw}%`, `description.ilike.%${kw}%`])
        .join(",");

      const { data: filtered } = await supabaseClient
        .from("credit_events")
        .select("id, event_type, severity, source_agent, title, description, created_at, customers!left(id, company_name, ticker)")
        .or(orFilter)
        .order("created_at", { ascending: false })
        .limit(15);

      events = filtered ?? [];
    }

    // Fall back to most recent 15 if keyword filter found < 2 results
    if (events.length < 2) {
      const { data: fallback } = await supabaseClient
        .from("credit_events")
        .select("id, event_type, severity, source_agent, title, description, created_at, customers!left(id, company_name, ticker)")
        .order("created_at", { ascending: false })
        .limit(15);
      events = fallback ?? [];
    }

    const eventsContext = events
      .sort((a: any, b: any) => severityRank(b.severity) - severityRank(a.severity))
      .map((e: any) =>
        [
          `ID: ${e.id}`,
          `Type: ${e.event_type}`,
          `Severity: ${e.severity}`,
          `Agent: ${e.source_agent}`,
          `Customer: ${e.customers?.company_name ?? "Portfolio"}`,
          `Title: ${e.title}`,
          e.description ? `Detail: ${e.description}` : null,
          `Date: ${e.created_at}`,
        ]
          .filter(Boolean)
          .join("\n")
      )
      .join("\n\n");

    const questionSystemPrompt = `You are a credit analyst assistant for CreditPilot. Answer the user's question based ONLY on the provided credit events.

Return ONLY valid JSON in this exact shape, no other text, no markdown code fences:
{
  "answer": "2-3 paragraphs of analysis, markdown formatted with **bold key terms**",
  "sources": [
    {
      "event_id": "uuid",
      "customer_name": "string",
      "event_type": "string",
      "severity": "critical|high|medium|low|info",
      "date": "ISO date string",
      "agent": "string"
    }
  ],
  "confidence": "High|Medium|Low",
  "confidence_reason": "one sentence explaining confidence level"
}

Only include events in sources that directly support your answer.`;

    const model = DEMO_MODE ? "claude-haiku-4-5" : "claude-sonnet-4-20250514";
    const maxTokens = DEMO_MODE ? 600 : 800;

    const anthropic = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY")! });

    try {
      const message = await anthropic.messages.create({
        model,
        max_tokens: maxTokens,
        system: questionSystemPrompt,
        messages: [
          {
            role: "user",
            content: `Question: ${question}\n\nCredit events:\n${eventsContext}`,
          },
        ],
      });

      const text = extractText(message);
      const cleaned = text.replace(/^```json\s*/i, "").replace(/^```\s*/i, "").replace(/\s*```$/i, "").trim();
      const result = JSON.parse(cleaned);
      return jsonRes(result);
    } catch (err) {
      console.error("Question mode error:", err);
      return jsonRes({ error: "Failed to generate answer" }, 500);
    }
  }

  // ── BRIEFING mode (default) ────────────────────────────────────────────────

  // Demo fast-path
  if (DEMO_MODE) {
    const { error: runError } = await supabaseClient
      .from("agent_runs")
      .upsert({
        id: DEMO_SEED_RUN_ID,
        agent_name: "cia-agent",
        status: "completed",
        completed_at: new Date().toISOString(),
        created_at: new Date().toISOString(),
      }, { onConflict: "id" });

    if (runError) console.error("Demo upsert error:", runError);

    return jsonRes({
      run_id: DEMO_SEED_RUN_ID,
      demo: true,
      briefing: DEMO_BRIEFING,
      events_processed: 12,
      stale_agents: [],
      messages: DEMO_MESSAGES,
    });
  }

  // Live briefing path
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return jsonRes({ error: "Unauthorized" }, 401);
  }

  // 1. Check cache TTL per agent
  const { data: recentRuns } = await supabaseClient
    .from("agent_runs")
    .select("id, agent_name, status, completed_at, created_at")
    .in("agent_name", ["ar-aging-agent", "news-monitor-agent", "sec-monitor-agent"])
    .eq("status", "completed")
    .order("completed_at", { ascending: false });

  const latestByAgent: Record<string, AgentRun> = {};
  for (const run of (recentRuns ?? [])) {
    if (!latestByAgent[run.agent_name]) {
      latestByAgent[run.agent_name] = run;
    }
  }

  const staleAgents = Object.entries(CACHE_TTL)
    .filter(([agent]) => force_refresh || isStale(latestByAgent[agent] ?? null, agent))
    .map(([agent]) => agent);

  // 2. Read unprocessed credit_events
  let eventsQuery = supabaseClient
    .from("credit_events")
    .select("*")
    .eq("cia_processed", false)
    .order("created_at", { ascending: false })
    .limit(100);

  if (customer_id) {
    eventsQuery = eventsQuery.eq("customer_id", customer_id);
  }

  const { data: events, error: eventsError } = await eventsQuery;

  if (eventsError) {
    return jsonRes({ error: eventsError.message }, 500);
  }

  if (!events || events.length === 0) {
    return jsonRes({
      run_id: null,
      briefing: "No unprocessed credit events found. All signals are up to date.",
      events_processed: 0,
      stale_agents: staleAgents,
      messages: [],
    });
  }

  // 3. Load customer context
  const customerIds = [...new Set(events.map((e: any) => e.customer_id).filter(Boolean))] as string[];
  const { data: customers } = await supabaseClient
    .from("customers")
    .select("id, name, ticker, company_type, credit_limit, current_balance")
    .in("id", customerIds);

  // 4. Call Claude
  const anthropic = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY")! });
  const systemPrompt = buildSystemPrompt(customers ?? []);
  const userPrompt = buildUserPrompt(events as CreditEvent[], customers ?? [], question);

  let briefing = "";
  try {
    const message = await anthropic.messages.create({
      model: "claude-opus-4-5",
      max_tokens: 2000,
      system: systemPrompt,
      messages: [{ role: "user", content: userPrompt }],
    });
    briefing = extractText(message);
  } catch (err) {
    console.error("Anthropic API error:", err);
    return jsonRes({ error: "Failed to generate briefing" }, 500);
  }

  // 5. Create agent_runs record
  const { data: runData, error: runError } = await supabaseClient
    .from("agent_runs")
    .insert({
      agent_name: "cia-agent",
      status: "completed",
      started_at: new Date().toISOString(),
      completed_at: new Date().toISOString(),
    })
    .select("id")
    .single();

  if (runError) console.error("agent_runs insert error:", runError);
  const runId = runData?.id ?? null;

  // 6. Write CIA_ASSESSMENT events back
  const groupedEvents = groupEventsByCustomer(events as CreditEvent[]);
  const assessmentEvents = [];

  assessmentEvents.push({
    scope: "portfolio",
    customer_id: null,
    event_type: "DAILY_BRIEFING",
    source_agent: "cia-agent",
    severity: "info" as const,
    title: "Daily Credit Intelligence Briefing",
    description: briefing.slice(0, 500),
    payload: {
      full_briefing: briefing,
      events_synthesised: events.length,
      question: question ?? null,
      stale_agents: staleAgents,
    },
    action_required: false,
    is_demo: DEMO_MODE,
    cia_processed: true,
    run_id: runId,
  });

  for (const [custId, custEvents] of Object.entries(groupedEvents)) {
    if (custId === "__portfolio__") continue;
    const agentsSeen = new Set(custEvents.map((e: any) => e.source_agent));
    if (agentsSeen.size >= 2) {
      const maxSeverity = custEvents.reduce((max: string, e: any) =>
        severityRank(e.severity) > severityRank(max) ? e.severity : max,
        "info" as string
      );
      const customer = (customers ?? []).find((c: any) => c.id === custId);
      assessmentEvents.push({
        scope: "customer",
        customer_id: custId,
        event_type: maxSeverity === "critical" ? "COMPOSITE_RISK_CRITICAL" : "COMPOSITE_RISK_ELEVATED",
        source_agent: "cia-agent",
        severity: maxSeverity as "critical" | "high" | "medium" | "low" | "info",
        title: `Multi-signal risk: ${customer?.name ?? custId}`,
        description: `Signals from ${[...agentsSeen].join(", ")} — ${custEvents.length} events`,
        payload: {
          source_event_ids: custEvents.map((e: any) => e.id),
          agents: [...agentsSeen],
          event_count: custEvents.length,
        },
        action_required: maxSeverity === "critical" || maxSeverity === "high",
        action_type: maxSeverity === "critical" ? "CREDIT_LIMIT_REVIEW" : null,
        action_status: maxSeverity === "critical" ? "pending" : null,
        is_demo: DEMO_MODE,
        cia_processed: true,
        run_id: runId,
      });
    }
  }

  if (assessmentEvents.length > 0) {
    const { error: insertError } = await supabaseClient
      .from("credit_events")
      .insert(assessmentEvents);
    if (insertError) console.error("Assessment insert error:", insertError);
  }

  // 7. Mark source events as processed
  const eventIds = (events as CreditEvent[]).map(e => e.id);
  const { error: markError } = await supabaseClient
    .from("credit_events")
    .update({ cia_processed: true })
    .in("id", eventIds);

  if (markError) console.error("Mark processed error:", markError);

  return jsonRes({
    run_id: runId,
    demo: false,
    briefing,
    events_processed: events.length,
    composite_risks_detected: assessmentEvents.filter(e => e.event_type !== "DAILY_BRIEFING").length,
    stale_agents: staleAgents,
    messages: [{ role: "assistant", content: briefing }],
  });
});
