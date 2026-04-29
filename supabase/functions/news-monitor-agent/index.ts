/**
 * News Monitor Agent — supabase/functions/news-monitor-agent/index.ts
 *
 * Full live news pipeline: searches for negative news about each customer via
 * Tavily, classifies articles with Claude Haiku (falling back to keywords),
 * deduplicates by content fingerprint, writes credit events, and composes
 * Microsoft Teams alerts for medium/high/critical findings.
 *
 * If TAVILY_API_KEY is absent the agent falls back to processing existing
 * unreviewed rows in negative_news (original behaviour — preserves demo
 * compatibility without a search subscription).
 *
 * Request body: { triggered_by?: string }
 * Response:     { run_id: string, status: "completed" }
 *
 * Tables read:  customers, negative_news
 * Tables written: negative_news, credit_events, agent_messages, agent_runs
 *
 * Event types emitted:
 *   NEGATIVE_NEWS_CRITICAL | NEGATIVE_NEWS_HIGH | NEGATIVE_NEWS_MEDIUM
 *
 * Rate limit: 60 minutes between runs (HTTP 429 if exceeded).
 * Demo mode:  Returns a pre-baked run log. No rows written.
 *             Controlled by DEMO_MODE=true Supabase secret.
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.98.0";
import { composeTeamsAlert } from "../_shared/skills/generative/compose-teams-alert.ts";
import { classifyNews } from "../_shared/skills/generative/classify-news.ts";
import {
  generateFingerprint,
  searchNews,
  TavilyProvider,
} from "../_shared/skills/integration/search-news.ts";

// ─── Constants ────────────────────────────────────────────────────────────────

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

const RATE_LIMIT_MINUTES = 60;
const CONFIDENCE_THRESHOLD = 0.7;
const MAX_CUSTOMERS = 10;

// ─── Handler ──────────────────────────────────────────────────────────────────

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { triggered_by } = await req.json().catch(() => ({ triggered_by: "manual" }));
  const agent_name = "news_monitor_agent";
  const DEMO_MODE = Deno.env.get("DEMO_MODE") === "true";

  // ── Demo mode (runs before rate limit check) ────────────────────────────────

  if (DEMO_MODE) {
    const SEED_RUN_ID = "cfab84c3-2a44-4c60-97a1-c0dbe50d1015";

    await supabase.from("agent_runs").insert({
      id: crypto.randomUUID(),
      agent_name: "news_monitor_agent",
      status: "completed",
      started_at: new Date().toISOString(),
      completed_at: new Date().toISOString(),
      customers_scanned: 28,
      conditions_found: 25,
      messages_composed: 5,
      actions_taken: 0,
      triggered_by: "demo",
      summary: "Scanned 28 unreviewed news items. Found 25 critical/high alerts. Composed 5 notifications.",
    });

    return new Response(
      JSON.stringify({ run_id: SEED_RUN_ID, status: "completed", demo: true }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  // ── Rate limit check ────────────────────────────────────────────────────────

  const cutoff = new Date(Date.now() - RATE_LIMIT_MINUTES * 60 * 1000).toISOString();
  const { data: recentRuns } = await supabase
    .from("agent_runs")
    .select("id, started_at, status")
    .eq("agent_name", agent_name)
    .gte("started_at", cutoff)
    .in("status", ["completed", "running"])
    .limit(1);

  if (recentRuns && recentRuns.length > 0) {
    return new Response(
      JSON.stringify({
        error: "rate_limited",
        message: "This agent was run recently. Please wait before running again.",
        last_run_at: recentRuns[0].started_at,
      }),
      { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  // ── Create run record ───────────────────────────────────────────────────────

  const run_id = crypto.randomUUID();

  await supabase.from("agent_runs").insert({
    id: run_id,
    agent_name,
    status: "running",
    started_at: new Date().toISOString(),
    triggered_by,
  });

  try {
    const tavilyKey = Deno.env.get("TAVILY_API_KEY");
    const anthropicKey = Deno.env.get("ANTHROPIC_API_KEY");

    // ── Backward-compat: no Tavily key → process existing unreviewed rows ─────

    if (!tavilyKey) {
      console.log("[news-monitor-agent] No TAVILY_API_KEY — falling back to existing unreviewed rows");
      return await legacyPath(supabase, run_id, agent_name, corsHeaders);
    }

    // ── Live pipeline ─────────────────────────────────────────────────────────

    const { data: customers, error: custError } = await supabase
      .from("customers")
      .select("id, company_name, ticker")
      .limit(MAX_CUSTOMERS);

    if (custError) throw custError;

    let customersScanned = 0;
    let conditionsFound = 0;
    let messagesComposed = 0;

    for (const customer of (customers ?? [])) {
      customersScanned++;
      console.log(`[news-monitor-agent] Customer: ${customer.company_name} (${customer.id})`);

      const articles = await searchNews({
        company_name: customer.company_name,
        ticker: customer.ticker ?? undefined,
        days_back: 7,
        max_results: 10,
        providers: [new TavilyProvider(tavilyKey)],
      });

      console.log(`[news-monitor-agent]   ${articles.length} articles found`);

      for (const article of articles) {
        const articleDate = article.published_date
          ? article.published_date.slice(0, 10)
          : new Date().toISOString().slice(0, 10);

        const fingerprint = generateFingerprint(customer.id, article.headline, articleDate);

        // Skip if already in the database
        const { data: existing } = await supabase
          .from("negative_news")
          .select("id")
          .eq("content_fingerprint", fingerprint)
          .maybeSingle();

        if (existing) {
          console.log(`[news-monitor-agent]   Duplicate — skipping: ${article.headline.slice(0, 60)}`);
          continue;
        }

        // Classify
        const classification = await classifyNews({
          headline: article.headline,
          summary: article.summary,
          source: article.source,
          company_name: customer.company_name,
          anthropic_api_key: anthropicKey,
          confidence_threshold: CONFIDENCE_THRESHOLD,
        });

        console.log(
          `[news-monitor-agent]   severity=${classification.severity}` +
          ` confidence=${classification.confidence}` +
          ` by=${classification.classified_by}`
        );

        if (classification.confidence < CONFIDENCE_THRESHOLD) {
          console.log(`[news-monitor-agent]   Low confidence — skipping`);
          continue;
        }

        // Insert to negative_news (ON CONFLICT DO NOTHING via ignoreDuplicates)
        const { error: newsError } = await supabase.from("negative_news").upsert(
          {
            customer_id: customer.id,
            headline: article.headline,
            summary: article.summary,
            source: article.source,
            url: article.url,
            news_date: articleDate,
            relevance_score: article.relevance_score,
            severity: classification.severity,
            category: classification.category,
            sentiment_score: classification.sentiment_score,
            reviewed: false,
            is_demo: false,
            content_fingerprint: fingerprint,
            classification_source: classification.classified_by,
            confidence: classification.confidence,
            provider: article.provider,
          },
          { onConflict: "content_fingerprint", ignoreDuplicates: true }
        );

        if (newsError) {
          console.log(`[news-monitor-agent]   negative_news insert error: ${newsError.message}`);
          continue;
        }

        conditionsFound++;

        // Low severity: no credit event or alert
        if (classification.severity === "low") {
          continue;
        }

        // Medium / high / critical: credit event
        const eventType =
          classification.severity === "critical" ? "NEGATIVE_NEWS_CRITICAL"
          : classification.severity === "high" ? "NEGATIVE_NEWS_HIGH"
          : "NEGATIVE_NEWS_MEDIUM";

        const { error: eventError } = await supabase.from("credit_events").insert({
          scope: "customer",
          customer_id: customer.id,
          event_type: eventType,
          source_agent: agent_name,
          severity: classification.severity,
          signal_type: "NEGATIVE_NEWS",
          title: `${customer.company_name}: ${article.headline}`,
          description: article.summary,
          payload: {
            headline: article.headline,
            source: article.source,
            url: article.url,
            news_date: articleDate,
            category: classification.category,
            sentiment_score: classification.sentiment_score,
            provider: article.provider,
            classified_by: classification.classified_by,
            triggers: [classification.category, `severity_${classification.severity}`],
          },
          is_demo: false,
          run_id,
        });

        // 23505 = unique_violation on any credit_events constraint — skip alert
        if (eventError) {
          if ((eventError as any).code === "23505") {
            console.log(`[news-monitor-agent]   Credit event conflict — skipping alert`);
          } else {
            console.log(`[news-monitor-agent]   credit_events insert error: ${eventError.message}`);
          }
          continue;
        }

        // Teams alert
        const alert = composeTeamsAlert({
          alert_type: "news_alert",
          company_name: customer.company_name,
          ticker: customer.ticker ?? undefined,
          severity: classification.severity,
          headline: article.headline,
          details: [
            `Source: ${article.source} | Date: ${articleDate} | Category: ${classification.category}`,
            `Sentiment score: ${classification.sentiment_score}`,
            article.summary ? `\n${article.summary}` : "",
          ].join("\n"),
          recommended_action: `Review and assess credit impact for ${customer.company_name}${customer.ticker ? ` (${customer.ticker})` : ""}.`,
        });

        const { error: msgError } = await supabase.from("agent_messages").insert({
          run_id,
          agent_name,
          customer_id: customer.id,
          channel: "teams",
          template_type: "news_alert",
          recipient_type: "credit_committee",
          recipient_name: "Credit Risk Team",
          subject: alert.subject,
          body: alert.body,
          status: "draft",
          is_demo: false,
        });

        if (!msgError) messagesComposed++;
      }
    }

    await supabase
      .from("agent_runs")
      .update({
        status: "completed",
        completed_at: new Date().toISOString(),
        customers_scanned: customersScanned,
        conditions_found: conditionsFound,
        messages_composed: messagesComposed,
        actions_taken: 0,
        summary:
          `Searched news for ${customersScanned} customers. ` +
          `Inserted ${conditionsFound} relevant articles. ` +
          `Composed ${messagesComposed} alerts.`,
      })
      .eq("id", run_id);

    return new Response(
      JSON.stringify({ run_id, status: "completed" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    await supabase
      .from("agent_runs")
      .update({
        status: "failed",
        completed_at: new Date().toISOString(),
        summary: `Error: ${(err as Error).message}`,
      })
      .eq("id", run_id);

    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

// ─── Legacy fallback (no Tavily key) ─────────────────────────────────────────
//
// Preserves original behaviour: reads unreviewed negative_news rows, processes
// the top 5 critical/high items, writes credit events and agent_messages.

async function legacyPath(
  supabase: ReturnType<typeof createClient>,
  run_id: string,
  agent_name: string,
  headers: Record<string, string>
): Promise<Response> {
  const { data: news } = await supabase
    .from("negative_news")
    .select("*, customers(company_name, ticker)")
    .eq("reviewed", false)
    .order("news_date", { ascending: false });

  const scanned = news?.length ?? 0;
  const critical = (news ?? []).filter(
    (n: any) => n.severity === "critical" || n.severity === "high"
  );
  let messagesComposed = 0;

  for (const item of critical.slice(0, 5)) {
    const cust = (item as any).customers;

    const alert = composeTeamsAlert({
      alert_type: "news_alert",
      company_name: cust?.company_name ?? "Unknown",
      ticker: cust?.ticker,
      severity: item.severity as "critical" | "high" | "medium" | "low",
      headline: item.headline,
      details: `Source: ${item.source} | Date: ${item.news_date} | Category: ${item.category}\nSentiment score: ${item.sentiment_score}\n\n${item.summary ?? ""}`,
      recommended_action: `Review and assess credit impact for ${cust?.company_name} (${cust?.ticker}).`,
    });

    const { error: msgError } = await supabase.from("agent_messages").insert({
      run_id,
      agent_name,
      customer_id: item.customer_id,
      channel: "teams",
      template_type: "news_alert",
      recipient_type: "credit_committee",
      recipient_name: "Credit Risk Team",
      subject: alert.subject,
      body: alert.body,
      status: "draft",
      is_demo: false,
    });
    if (!msgError) messagesComposed++;

    await supabase.from("credit_events").insert({
      scope: "customer",
      customer_id: item.customer_id,
      event_type:
        item.severity === "critical" ? "NEGATIVE_NEWS_CRITICAL"
        : item.severity === "high" ? "NEGATIVE_NEWS_HIGH"
        : "NEGATIVE_NEWS_MEDIUM",
      source_agent: agent_name,
      severity: item.severity as "critical" | "high" | "medium" | "low" | "info",
      signal_type: "NEGATIVE_NEWS",
      title: `${cust?.company_name ?? "Unknown"}: ${item.headline}`,
      description: item.summary,
      payload: {
        headline: item.headline,
        source: item.source,
        news_date: item.news_date,
        category: item.category,
        sentiment_score: item.sentiment_score,
        triggers: [item.category ?? "negative_news", `severity_${item.severity}`],
      },
      is_demo: false,
      run_id,
    });
  }

  await supabase
    .from("agent_runs")
    .update({
      status: "completed",
      completed_at: new Date().toISOString(),
      customers_scanned: scanned,
      conditions_found: critical.length,
      messages_composed: messagesComposed,
      actions_taken: 0,
      summary: `Legacy mode: scanned ${scanned} unreviewed items. Found ${critical.length} critical/high. Composed ${messagesComposed} notifications.`,
    })
    .eq("id", run_id);

  return new Response(
    JSON.stringify({ run_id, status: "completed", mode: "legacy" }),
    { headers: { ...headers, "Content-Type": "application/json" } }
  );
}
