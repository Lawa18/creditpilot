/**
 * SEC Filing Monitor Agent — supabase/functions/sec-monitor-agent/index.ts
 *
 * Actively fetches and analyses recent SEC filings for all monitored customers
 * via the SEC EDGAR API (free, no API key required). Detects risk signals in
 * filing text and writes credit_events for the CIA agent to synthesise.
 *
 * Request body: { triggered_by?: string }
 * Response:     { run_id: string, status: "completed" }
 *
 * Tables read:  sec_monitoring (with customers join), sec_filings (dedup check)
 * Tables written: sec_filings, credit_events, agent_messages, agent_runs,
 *                 sec_monitoring (last_checked_at, alert_triggered, alert_date, risk_signals)
 *
 * Skills used: fetch-sec-filing.ts (EdgarProvider — EDGAR API, free, no key)
 *
 * Event types emitted:
 *   GOING_CONCERN_WARNING | COVENANT_WAIVER | CEO_DEPARTURE | SEC_ALERT
 *
 * Severity mapping:
 *   going_concern_warning / cash_runway_<3_quarters → critical
 *   covenant_waiver / CEO_departure                → high
 *   other                                          → medium
 *
 * Deduplication: accession_number per customer (sec_filings unique index).
 *   Skips filings already in sec_filings.
 *
 * Rate limit: 60 minutes between runs (HTTP 429 if exceeded).
 * Demo mode:  Returns a pre-baked run log. No rows written.
 *             Controlled by DEMO_MODE=true Supabase secret.
 * Max customers per run: 10.
 */
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.98.0";
import { fetchSecFilings } from "../_shared/skills/integration/fetch-sec-filing.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

const RATE_LIMIT_MINUTES = 60;
const MAX_CUSTOMERS_PER_RUN = 10;
const CREDIT_TEAM_EMAIL = Deno.env.get("CREDIT_TEAM_EMAIL") ?? "credit-team@company.com";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { triggered_by } = await req.json().catch(() => ({ triggered_by: "manual" }));
  const agent_name = "sec_monitor_agent";
  const DEMO_MODE = Deno.env.get("DEMO_MODE") === "true";

  // DEMO MODE: create a log entry, no EDGAR calls
  if (DEMO_MODE) {
    const SEED_RUN_ID = "04238087-3999-4aac-a368-5a820a603194";

    await supabase.from("agent_runs").insert({
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
    // 1. Load monitored customers (with customer join, is_demo filter, max 10)
    const { data: monitoring } = await supabase
      .from("sec_monitoring")
      .select("id, customer_id, cik, risk_signals, customers!inner(company_name, ticker)")
      .eq("is_demo", DEMO_MODE)
      .limit(MAX_CUSTOMERS_PER_RUN);

    const scanned = monitoring?.length ?? 0;
    let conditionsFound = 0;
    let messagesComposed = 0;
    const now = new Date().toISOString();

    // 2. Process each monitored customer
    for (const row of (monitoring ?? [])) {
      const monitoringId = row.id as string;
      const customerId   = row.customer_id as string;
      const cik          = row.cik as string | null;
      const customer     = row.customers as { company_name: string; ticker: string | null };
      const companyName  = customer.company_name;

      if (!cik) {
        console.warn(`No CIK for customer ${customerId} (${companyName}) — skipping`);
        await supabase.from("sec_monitoring")
          .update({ last_checked_at: now })
          .eq("id", monitoringId);
        continue;
      }

      try {
        const filings = await fetchSecFilings({ cik, company_name: companyName, days_back: 90 });

        const newRiskSignals: string[] = [];
        let hasNewAlerts = false;

        for (const filing of filings) {
          // Dedup: skip if this accession number already processed for this customer
          const { data: existing } = await supabase
            .from("sec_filings")
            .select("id")
            .eq("customer_id", customerId)
            .eq("accession_number", filing.accession_number)
            .limit(1);

          if (existing && existing.length > 0) continue;

          // Insert to sec_filings
          await supabase.from("sec_filings").insert({
            customer_id:      customerId,
            filing_type:      filing.filing_type,
            filing_date:      filing.filing_date,
            key_findings:     filing.key_findings,
            risk_signals:     filing.risk_signals,
            accession_number: filing.accession_number,
            agent_name,
            is_demo:          DEMO_MODE,
          });

          if (filing.risk_signals.length === 0) continue;

          // New alert filing
          hasNewAlerts = true;
          conditionsFound++;
          newRiskSignals.push(...filing.risk_signals);

          // Map risk signals to event type + severity
          const eventType = filing.risk_signals.includes("going_concern_warning") ? "GOING_CONCERN_WARNING"
            : filing.risk_signals.includes("covenant_waiver") ? "COVENANT_WAIVER"
            : filing.risk_signals.includes("CEO_departure") ? "CEO_DEPARTURE"
            : filing.risk_signals.includes("cash_runway_<3_quarters") ? "GOING_CONCERN_WARNING"
            : "SEC_ALERT";

          const severity = (
            filing.risk_signals.includes("going_concern_warning") ||
            filing.risk_signals.includes("cash_runway_<3_quarters")
          ) ? "critical"
            : (
              filing.risk_signals.includes("covenant_waiver") ||
              filing.risk_signals.includes("CEO_departure")
            ) ? "high"
            : "medium";

          // Write credit_event (pure signal — CIA agent owns pending_actions)
          await supabase.from("credit_events").insert({
            scope:        "customer",
            customer_id:  customerId,
            event_type:   eventType,
            source_agent: agent_name,
            severity,
            signal_type:  "SEC_FILING",
            title:        `${companyName}: ${eventType.replace(/_/g, " ")}`,
            description:  `Risk signals in ${filing.filing_type} (${filing.filing_date}): ${filing.risk_signals.join(", ")}`,
            payload: {
              filing_type:      filing.filing_type,
              filing_date:      filing.filing_date,
              accession_number: filing.accession_number,
              document_url:     filing.document_url,
              cik,
              risk_signals:     filing.risk_signals,
              key_findings:     filing.key_findings,
              provider:         filing.provider,
            },
            action_required: severity === "critical" || severity === "high",
            action_type:     null,
            action_status:   "none",
            is_demo:         DEMO_MODE,
            run_id,
          });

          // Compose email alert
          const { error: msgError } = await supabase.from("agent_messages").insert({
            run_id,
            agent_name,
            customer_id:     customerId,
            channel:         "email",
            template_type:   "sec_alert",
            recipient_type:  "credit_committee",
            recipient_name:  "Credit Analysis Team",
            recipient_email: CREDIT_TEAM_EMAIL,
            subject:         `SEC Alert: ${companyName} (${customer.ticker ?? cik}) — ${filing.risk_signals.length} risk signal(s) in ${filing.filing_type}`,
            body: [
              `SEC Filing Alert`,
              `Company: ${companyName} (${customer.ticker ?? "N/A"})`,
              `CIK: ${cik}`,
              `Filing Type: ${filing.filing_type}`,
              `Filing Date: ${filing.filing_date}`,
              ``,
              `Risk Signals: ${filing.risk_signals.join(", ")}`,
              ``,
              `Key Findings: ${filing.key_findings}`,
              ``,
              `Filing URL: ${filing.document_url}`,
              ``,
              `Please review the filing and assess impact on credit exposure.`,
            ].join("\n"),
            status:  "draft",
            is_demo: DEMO_MODE,
          });
          if (!msgError) messagesComposed++;
        }

        // Update sec_monitoring with latest alert state + last_checked_at
        const updatePayload: Record<string, unknown> = { last_checked_at: now };
        if (hasNewAlerts) {
          updatePayload.alert_triggered = true;
          updatePayload.alert_date      = now.slice(0, 10);
          updatePayload.risk_signals    = [...new Set(newRiskSignals)];
        }
        await supabase.from("sec_monitoring")
          .update(updatePayload)
          .eq("id", monitoringId);

      } catch (err) {
        console.error(`Failed to process ${companyName} (CIK: ${cik}):`, (err as Error).message);
        // Non-fatal — continue with next customer
        await supabase.from("sec_monitoring")
          .update({ last_checked_at: now })
          .eq("id", monitoringId);
      }
    }

    await supabase.from("agent_runs").update({
      status:            "completed",
      completed_at:      now,
      customers_scanned: scanned,
      conditions_found:  conditionsFound,
      messages_composed: messagesComposed,
      actions_taken:     0,
      summary: `Scanned ${scanned} customers via EDGAR. Found ${conditionsFound} new risk signals. Composed ${messagesComposed} alerts.`,
    }).eq("id", run_id);

    return new Response(JSON.stringify({ run_id, status: "completed" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (err) {
    await supabase.from("agent_runs").update({
      status:       "failed",
      completed_at: new Date().toISOString(),
      summary:      `Error: ${(err as Error).message}`,
    }).eq("id", run_id);

    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
