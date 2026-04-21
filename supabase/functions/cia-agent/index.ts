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
  question?: string;           // optional queued question from user
  force_refresh?: boolean;     // bypass TTL cache
  customer_id?: string;        // scope to single customer
}

// ─── Constants ───────────────────────────────────────────────────────────────

const DEMO_SEED_RUN_ID = "cia-demo-seed-00000000-0000-0000-0000-000000000001";

const CACHE_TTL: Record<string, number> = {
  "ar-aging-agent":  24 * 60 * 60 * 1000,   // 24h
  "news-monitor-agent": 4 * 60 * 60 * 1000, // 4h
  "sec-monitor-agent": 48 * 60 * 60 * 1000, // 48h
};

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

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

// ─── Main Handler ─────────────────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const DEMO_MODE = Deno.env.get("DEMO_MODE") === "true";

  // ── Demo mode fast-path ──────────────────────────────────────────────────
  if (DEMO_MODE) {
    const { error: runError } = await supabase
      .from("agent_runs")
      .upsert({
        id: DEMO_SEED_RUN_ID,
        agent_name: "cia-agent",
        status: "completed",
        completed_at: new Date().toISOString(),
        created_at: new Date().toISOString(),
      }, { onConflict: "id" });

    if (runError) console.error("Demo upsert error:", runError);

    return new Response(
      JSON.stringify({
        run_id: DEMO_SEED_RUN_ID,
        demo: true,
        briefing: DEMO_BRIEFING,
        events_processed: 12,
        stale_agents: [],
        messages: DEMO_MESSAGES,
      }),
      { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
    );
  }

  // ── Live path ────────────────────────────────────────────────────────────

  // Rate limit check (after demo bypass)
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  }

  let body: CIARequest = {};
  try {
    body = await req.json();
  } catch {
    // empty body is fine
  }

  const { question, force_refresh = false, customer_id } = body;

  // 1. Check cache TTL per agent
  const { data: recentRuns } = await supabase
    .from("agent_runs")
    .select("id, agent_name, status, completed_at, created_at")
    .in("agent_name", ["ar-aging-agent", "news-monitor-agent", "sec-monitor-agent"])
    .eq("status", "completed")
    .order("completed_at", { ascending: false });

  // Latest completed run per agent
  const latestByAgent: Record<string, AgentRun> = {};
  for (const run of (recentRuns ?? [])) {
    if (!latestByAgent[run.agent_name]) {
      latestByAgent[run.agent_name] = run;
    }
  }

  const staleAgents = Object.entries(CACHE_TTL)
    .filter(([agent]) => force_refresh || isStale(latestByAgent[agent] ?? null, agent))
    .map(([agent]) => agent);

  // 2. Trigger stale agents (fire-and-forget — don't await, CIA proceeds with existing data)
  // In production you'd invoke them via fetch(); for now we surface which ones are stale
  // so the frontend can decide to show a "data may be stale" warning.

  // 3. Read unprocessed credit_events
  let eventsQuery = supabase
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
    return new Response(JSON.stringify({ error: eventsError.message }), {
      status: 500,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  }

  if (!events || events.length === 0) {
    return new Response(
      JSON.stringify({
        run_id: null,
        briefing: "No unprocessed credit events found. All signals are up to date.",
        events_processed: 0,
        stale_agents: staleAgents,
        messages: [],
      }),
      { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
    );
  }

  // 4. Load customer context for named references
  const customerIds = [...new Set(events.map(e => e.customer_id).filter(Boolean))] as string[];
  const { data: customers } = await supabase
    .from("customers")
    .select("id, name, ticker, company_type, credit_limit, current_balance")
    .in("id", customerIds);

  // 5. Call Claude API
  const anthropic = new Anthropic({
    apiKey: Deno.env.get("ANTHROPIC_API_KEY")!,
  });

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

    briefing = message.content
      .filter(b => b.type === "text")
      .map(b => (b as { type: "text"; text: string }).text)
      .join("\n");
  } catch (err) {
    console.error("Anthropic API error:", err);
    return new Response(JSON.stringify({ error: "Failed to generate briefing" }), {
      status: 500,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  }

  // 6. Create agent_runs record
  const { data: runData, error: runError } = await supabase
    .from("agent_runs")
    .insert({
      agent_name: "cia-agent",
      status: "completed",
      started_at: new Date().toISOString(),
      completed_at: new Date().toISOString(),
    })
    .select("id")
    .single();

  if (runError) {
    console.error("agent_runs insert error:", runError);
  }

  const runId = runData?.id ?? null;

  // 7. Write CIA_ASSESSMENT events back to credit_events
  const groupedEvents = groupEventsByCustomer(events as CreditEvent[]);
  const assessmentEvents = [];

  // Portfolio-level daily briefing event
  assessmentEvents.push({
    scope: "portfolio",
    customer_id: null,
    event_type: "DAILY_BRIEFING",
    source_agent: "cia-agent",
    severity: "info" as const,
    title: "Daily Credit Intelligence Briefing",
    description: briefing.slice(0, 500), // truncated for description field
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

  // Per-customer COMPOSITE_RISK events for customers with multiple signals
  for (const [custId, custEvents] of Object.entries(groupedEvents)) {
    if (custId === "__portfolio__") continue;
    const agentsSeen = new Set(custEvents.map(e => e.source_agent));
    if (agentsSeen.size >= 2) {
      const maxSeverity = custEvents.reduce((max, e) =>
        severityRank(e.severity) > severityRank(max) ? e.severity : max,
        "info" as string
      );
      const customer = (customers ?? []).find(c => c.id === custId);
      assessmentEvents.push({
        scope: "customer",
        customer_id: custId,
        event_type: maxSeverity === "critical" ? "COMPOSITE_RISK_CRITICAL" : "COMPOSITE_RISK_ELEVATED",
        source_agent: "cia-agent",
        severity: maxSeverity as "critical" | "high" | "medium" | "low" | "info",
        title: `Multi-signal risk: ${customer?.name ?? custId}`,
        description: `Signals from ${[...agentsSeen].join(", ")} — ${custEvents.length} events`,
        payload: {
          source_event_ids: custEvents.map(e => e.id),
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
    const { error: insertError } = await supabase
      .from("credit_events")
      .insert(assessmentEvents);
    if (insertError) console.error("Assessment insert error:", insertError);
  }

  // 8. Mark source events as cia_processed
  const eventIds = (events as CreditEvent[]).map(e => e.id);
  const { error: markError } = await supabase
    .from("credit_events")
    .update({ cia_processed: true })
    .in("id", eventIds);

  if (markError) console.error("Mark processed error:", markError);

  // 9. Return response
  return new Response(
    JSON.stringify({
      run_id: runId,
      demo: false,
      briefing,
      events_processed: events.length,
      composite_risks_detected: assessmentEvents.filter(e => e.event_type !== "DAILY_BRIEFING").length,
      stale_agents: staleAgents,
      messages: [{ role: "assistant", content: briefing }],
    }),
    { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
  );
});
