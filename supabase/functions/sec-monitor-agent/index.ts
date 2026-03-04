import { createClient } from "https://esm.sh/@supabase/supabase-js@2.98.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { triggered_by } = await req.json().catch(() => ({ triggered_by: "manual" }));
  const run_id = crypto.randomUUID();
  const agent_name = "sec_monitor_agent";

  await supabase.from("agent_runs").insert({
    run_id,
    agent_name,
    status: "running",
    started_at: new Date().toISOString(),
    triggered_by,
  });

  try {
    // Get SEC monitoring data with alerts
    const { data: monitoring } = await supabase
      .from("v_sec_monitoring_dashboard")
      .select("*");

    const scanned = monitoring?.length ?? 0;
    const alerts = (monitoring ?? []).filter((m: any) => m.alert_triggered);
    const conditionsFound = alerts.length;
    let messagesComposed = 0;

    // Compose messages for triggered alerts
    for (const item of alerts) {
      const signals = (item.risk_signals ?? []).join(", ");
      await supabase.from("agent_messages").insert({
        run_id,
        agent_name,
        customer_id: item.customer_id,
        channel: "email",
        template_type: "sec_alert",
        recipient_type: "internal",
        recipient_name: "Credit Analysis Team",
        recipient_email: "credit-analysis@globaltrading.com",
        subject: `SEC Alert: ${item.company_name} (${item.ticker}) — Risk signals detected`,
        body: `SEC Filing Alert\nCompany: ${item.company_name} (${item.ticker})\nCIK: ${item.cik}\n\nRisk Signals: ${signals}\n\nLast 10-K: ${item.last_10k_date ?? "N/A"}\nLast 10-Q: ${item.last_10q_date ?? "N/A"}\n\nPlease review the latest filings and assess impact on credit exposure.`,
        status: "composed",
      });
      messagesComposed++;
    }

    await supabase.from("agent_runs").update({
      status: "completed",
      completed_at: new Date().toISOString(),
      customers_scanned: scanned,
      conditions_found: conditionsFound,
      messages_composed: messagesComposed,
      actions_taken: 0,
      summary: `Monitored ${scanned} SEC filings. Found ${conditionsFound} alerts. Composed ${messagesComposed} notifications.`,
    }).eq("run_id", run_id);

    return new Response(JSON.stringify({ run_id, status: "completed" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    await supabase.from("agent_runs").update({
      status: "failed",
      completed_at: new Date().toISOString(),
      summary: `Error: ${(err as Error).message}`,
    }).eq("run_id", run_id);

    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
