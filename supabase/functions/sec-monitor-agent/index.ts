import { createClient } from "https://esm.sh/@supabase/supabase-js@2.98.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

const RATE_LIMIT_MINUTES = 60;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { triggered_by } = await req.json().catch(() => ({ triggered_by: "manual" }));
  const agent_name = "sec_monitor_agent";
  const DEMO_MODE = Deno.env.get("DEMO_MODE") === "true";

  // DEMO MODE: before rate limit check
  if (DEMO_MODE) {
    const SEED_RUN_ID = "04238087-3999-4aac-a368-5a820a603194";

    await supabase
      .from("agent_runs")
      .insert({
        id: crypto.randomUUID(),
        agent_name,
        status: "completed",
        started_at: new Date().toISOString(),
        completed_at: new Date().toISOString(),
        customers_scanned: 3,
        conditions_found: 2,
        messages_composed: 2,
        actions_taken: 0,
        triggered_by: "demo",
        summary: "Monitored 3 SEC filings. Found 2 alerts. Composed 2 notifications.",
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
    const { data: monitoring } = await supabase
      .from("v_sec_monitoring_dashboard")
      .select("*");

    const scanned = monitoring?.length ?? 0;
    const alerts = (monitoring ?? []).filter((m: any) => m.alert_triggered);
    const conditionsFound = alerts.length;
    let messagesComposed = 0;

    for (const item of alerts) {
      const signals = (item.risk_signals_detected ?? []).join(", ");

      // Look up customer_id by ticker
      const { data: customer } = await supabase
        .from("customers")
        .select("id")
        .eq("ticker", item.ticker)
        .single();

      const { error: msgError } = await supabase.from("agent_messages").insert({
        run_id,
        agent_name,
        customer_id: customer?.id ?? null,
        channel: "email",
        template_type: "sec_alert",
        recipient_type: "credit_committee",
        recipient_name: "Credit Analysis Team",
        recipient_email: "credit-analysis@globaltrading.com",
        subject: `SEC Alert: ${item.company_name} (${item.ticker}) — Risk signals detected`,
        body: `SEC Filing Alert\nCompany: ${item.company_name} (${item.ticker})\nCIK: ${item.cik}\n\nRisk Signals: ${signals}\n\nLast 10-K: ${item.last_10k_date ?? "N/A"}\nLast 10-Q: ${item.last_10q_date ?? "N/A"}\nAlert Date: ${item.alert_date ?? "N/A"}\n\nAction Taken: ${item.alert_action_taken ?? "None"}\n\nPlease review the latest filings and assess impact on credit exposure.`,
        status: "draft",
      });
      if (!msgError) messagesComposed++;

      // Write credit event for this SEC alert
      const riskSignals = item.risk_signals_detected ?? [];

      // Map risk signals to event type
      const eventType = riskSignals.includes("going_concern_warning") ? "GOING_CONCERN_WARNING"
        : riskSignals.includes("covenant_waiver") ? "COVENANT_WAIVER"
        : riskSignals.includes("CEO_departure") ? "CEO_DEPARTURE"
        : riskSignals.includes("cash_runway_<3_quarters") ? "GOING_CONCERN_WARNING"
        : "SEC_ALERT";

      const severity = riskSignals.includes("going_concern_warning")
        || riskSignals.includes("cash_runway_<3_quarters") ? "critical"
        : riskSignals.includes("covenant_waiver")
        || riskSignals.includes("CEO_departure") ? "high"
        : "medium";

      await supabase.from("credit_events").insert({
        scope: "customer",
        customer_id: customer?.id ?? null,
        event_type: eventType,
        source_agent: agent_name,
        severity,
        signal_type: "SEC_FILING",
        title: `${item.company_name}: ${eventType.replace(/_/g, " ")}`,
        description: `Risk signals detected in SEC filing: ${riskSignals.join(", ")}`,
        payload: {
          filing_type: item.last_10q_date ? "10-Q" : "10-K",
          cik: item.cik,
          risk_signals: riskSignals,
          last_10k_date: item.last_10k_date,
          last_10q_date: item.last_10q_date,
          alert_action_taken: item.alert_action_taken,
          company_type: "public",
          triggers: riskSignals,
        },
        action_required: false,
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
      summary: `Monitored ${scanned} SEC filings. Found ${conditionsFound} alerts. Composed ${messagesComposed} notifications.`,
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
