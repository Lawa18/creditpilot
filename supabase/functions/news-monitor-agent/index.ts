import { createClient } from "https://esm.sh/@supabase/supabase-js@2.98.0";
import { composeTeamsAlert } from "../_shared/skills/generative/compose-teams-alert.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

const RATE_LIMIT_MINUTES = 60;
const DEMO_MODE_SEED_RUN_ID = "f933f002-acbc-4225-9b3d-22be4405a3d6";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { triggered_by } = await req.json().catch(() => ({ triggered_by: "manual" }));
  const agent_name = "news_monitor_agent";
  const DEMO_MODE = Deno.env.get("DEMO_MODE") === "true";

  // DEMO MODE: before rate limit check
  if (DEMO_MODE) {
    const SEED_RUN_ID = "cfab84c3-2a44-4c60-97a1-c0dbe50d1015";

    // Create a new run record so the log shows activity
    await supabase
      .from("agent_runs")
      .insert({
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

    return new Response(JSON.stringify({ run_id: SEED_RUN_ID, status: "completed", demo: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  // --- Rate limit check ---
  const cutoff = new Date(Date.now() - RATE_LIMIT_MINUTES * 60 * 1000).toISOString();
  const { data: recentRuns } = await supabase
    .from("agent_runs")
    .select("id, started_at, status")
    .eq("agent_name", agent_name)
    .gte("started_at", cutoff)
    .in("status", ["completed", "running"])
    .limit(1);

  if (recentRuns && recentRuns.length > 0) {
    return new Response(JSON.stringify({
      error: "rate_limited",
      message: "This agent was run recently. Please wait before running again.",
      last_run_at: recentRuns[0].started_at,
    }), {
      status: 429,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const run_id = crypto.randomUUID();

  await supabase.from("agent_runs").insert({
    id: run_id,
    agent_name,
    status: "running",
    started_at: new Date().toISOString(),
    triggered_by,
  });

  try {
    const { data: news } = await supabase
      .from("negative_news")
      .select("*, customers(company_name, ticker)")
      .eq("reviewed", false)
      .order("news_date", { ascending: false });

    const scanned = news?.length ?? 0;
    const critical = (news ?? []).filter(
      (n: any) => n.severity === "critical" || n.severity === "high"
    );
    const conditionsFound = critical.length;
    let messagesComposed = 0;

    for (const item of critical.slice(0, 5)) {
      const cust = (item as any).customers;

      const alert = composeTeamsAlert({
        alert_type: "news_alert",
        company_name: cust?.company_name ?? "Unknown",
        ticker: cust?.ticker,
        severity: item.severity as "critical" | "high" | "medium" | "low",
        headline: item.headline,
        details: `Source: ${item.source} | Date: ${item.news_date} | Category: ${item.category}\nSentiment score: ${item.sentiment_score}\n\n${item.summary}`,
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
        is_demo: DEMO_MODE,
      });
      if (!msgError) messagesComposed++;

      // Write credit event for this news item
      await supabase.from("credit_events").insert({
        scope: "customer",
        customer_id: item.customer_id,
        event_type: item.severity === "critical" ? "NEGATIVE_NEWS_CRITICAL"
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
          company_type: "public",
          triggers: [item.category ?? "negative_news", `severity_${item.severity}`],
        },
        is_demo: DEMO_MODE,
        run_id,
      });
    }

    await supabase.from("agent_runs").update({
      status: "completed",
      completed_at: new Date().toISOString(),
      customers_scanned: scanned,
      conditions_found: conditionsFound,
      messages_composed: messagesComposed,
      actions_taken: 0,
      summary: `Scanned ${scanned} unreviewed news items. Found ${conditionsFound} critical/high alerts. Composed ${messagesComposed} notifications.`,
    }).eq("id", run_id);

    return new Response(JSON.stringify({ run_id, status: "completed" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    await supabase.from("agent_runs").update({
      status: "failed",
      completed_at: new Date().toISOString(),
      summary: `Error: ${(err as Error).message}`,
    }).eq("id", run_id);

    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
