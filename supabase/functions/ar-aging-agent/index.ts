/**
 * AR Aging Agent — supabase/functions/ar-aging-agent/index.ts
 *
 * Pure signal agent — writes credit_events only. Credit limit decisions are
 * made by the CIA agent based on synthesised signals.
 *
 * Scans all customers for overdue AR buckets and high credit utilisation.
 * For at-risk customers the agent:
 *   - Writes credit events for each overdue bucket and utilization threshold
 *   - Composes staged dunning letters (stages 1–4) via the compose-dunning-letter skill
 *   - Composes Microsoft Teams alerts for accounts with >$100K over 90 days
 *
 * Request body: { triggered_by?: string }
 * Response:     { run_id: string, status: "completed" }
 *
 * Tables read:  v_ar_aging_current, payment_transactions
 * Tables written: credit_events, agent_messages, agent_runs
 *
 * Event types emitted:
 *   OVERDUE_BUCKET_1_30 | OVERDUE_BUCKET_31_60 | OVERDUE_BUCKET_61_90 |
 *   OVERDUE_BUCKET_OVER_90 | CRITICAL_UTILIZATION | HIGH_UTILIZATION |
 *   CONCENTRATION_RISK
 *
 * Rate limit: 60 minutes between runs (HTTP 429 if exceeded).
 * Demo mode:  Returns a pre-baked run log. No rows written.
 *             Controlled by DEMO_MODE=true Supabase secret.
 */
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.98.0";
import { analysePaymentBehaviour } from "../_shared/skills/analytical/analyse-payment-behaviour.ts";
import { composeDunningLetter } from "../_shared/skills/generative/compose-dunning-letter.ts";
import { composeTeamsAlert } from "../_shared/skills/generative/compose-teams-alert.ts";

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
  const agent_name = "ar_aging_agent";
  const anthropic_api_key = Deno.env.get("ANTHROPIC_API_KEY");
  const DEMO_MODE = Deno.env.get("DEMO_MODE") === "true";

  // DEMO MODE: create a log entry, no AI calls
  if (DEMO_MODE) {
    const SEED_RUN_ID = "0aa07788-5801-48ad-b070-384389296dee";

    await supabase.from("agent_runs").insert({
      id: crypto.randomUUID(),
      agent_name: "ar_aging_agent",
      status: "completed",
      started_at: new Date().toISOString(),
      completed_at: new Date().toISOString(),
      customers_scanned: 49,
      conditions_found: 19,
      messages_composed: 5,
      triggered_by: "demo",
      summary: "Scanned 49 customers. Found 19 at risk. Composed 5 messages.",
    });

    return new Response(JSON.stringify({ run_id: SEED_RUN_ID, status: "completed", demo: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  // --- Rate limit check ---
  const cutoff = new Date(Date.now() - RATE_LIMIT_MINUTES * 60 * 1000).toISOString();
  const { data: recentRuns } = await supabase
    .from("agent_runs")
    .select("run_id, started_at, status")
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
    // Get customers with AR aging data
    const { data: customers } = await supabase
      .from("v_ar_aging_current")
      .select("*")
      .order("total_outstanding", { ascending: false });

    const scanned = customers?.length ?? 0;
    let conditionsFound = 0;
    let messagesComposed = 0;

    // Find at-risk customers
    const atRisk = (customers ?? []).filter(
      (c: any) => (c.bucket_over_90 ?? 0) > 0 || (c.utilization_pct ?? 0) > 80
    );
    conditionsFound = atRisk.length;

    // Calculate total portfolio for concentration check
    const totalPortfolio = (customers ?? []).reduce(
      (sum: number, c: any) => sum + (Number(c.total_outstanding) || 0), 0
    );

    // Process top 5 at-risk customers
    for (const cust of atRisk.slice(0, 5)) {
      const customerId: string = cust.customer_id;

      // Fetch payment transactions for this customer
      const { data: transactions } = await supabase
        .from("payment_transactions")
        .select("payment_date, days_to_pay, days_early_late, on_time, amount")
        .eq("customer_id", customerId)
        .order("payment_date", { ascending: false })
        .limit(24);

      const behaviour = analysePaymentBehaviour(transactions ?? []);

      // Write payment behaviour to customers table for CIA agent to read
      await supabase.from("customers").update({
        payment_on_time_rate: behaviour.on_time_rate,
        payment_avg_days_early_late: behaviour.avg_days_early_late,
        payment_trend: behaviour.trend,
        payment_health: behaviour.health,
        payment_behaviour_updated_at: new Date().toISOString(),
      }).eq("id", customerId);

      // Determine severity and event types for credit_events
      const creditRatingScore = cust.credit_rating_score ?? null;
      const creditRatingSource = cust.credit_rating_source ?? null;
      const creditRatingRaw = cust.credit_rating_raw ?? null;

      const overdueBuckets: string[] = [];
      if ((cust.bucket_1_30 ?? 0) > 0) overdueBuckets.push("OVERDUE_BUCKET_1_30");
      if ((cust.bucket_31_60 ?? 0) > 0) overdueBuckets.push("OVERDUE_BUCKET_31_60");
      if ((cust.bucket_61_90 ?? 0) > 0) overdueBuckets.push("OVERDUE_BUCKET_61_90");
      if ((cust.bucket_over_90 ?? 0) > 0) overdueBuckets.push("OVERDUE_BUCKET_OVER_90");
      if ((cust.utilization_pct ?? 0) > 95) overdueBuckets.push("CRITICAL_UTILIZATION");
      else if ((cust.utilization_pct ?? 0) > 80) overdueBuckets.push("HIGH_UTILIZATION");

      const eventSeverity = (cust.bucket_over_90 ?? 0) > 0 ? "critical"
        : (cust.bucket_61_90 ?? 0) > 0 ? "high"
        : (cust.bucket_31_60 ?? 0) > 0 ? "medium" : "low";

      // Use most severe bucket as primary event type
      const primaryEventType = overdueBuckets.includes("OVERDUE_BUCKET_OVER_90") ? "OVERDUE_BUCKET_OVER_90"
        : overdueBuckets.includes("OVERDUE_BUCKET_61_90") ? "OVERDUE_BUCKET_61_90"
        : overdueBuckets.includes("OVERDUE_BUCKET_31_60") ? "OVERDUE_BUCKET_31_60"
        : overdueBuckets.includes("OVERDUE_BUCKET_1_30") ? "OVERDUE_BUCKET_1_30"
        : "HIGH_UTILIZATION";

      // Concentration check
      const concentrationPct = totalPortfolio > 0
        ? (Number(cust.total_outstanding) / totalPortfolio) * 100 : 0;

      // Compose dunning letter via skill (Claude API with template fallback)
      const dunningStage: 1 | 2 | 3 | 4 =
        (cust.bucket_over_90 ?? 0) > 100_000 ? 4
        : (cust.bucket_over_90 ?? 0) > 50_000 ? 3
        : (cust.bucket_61_90 ?? 0) > 0 ? 2
        : 1;

      // Write AR aging credit event
      await supabase.from("credit_events").insert({
        scope: "customer",
        customer_id: customerId,
        event_type: primaryEventType,
        source_agent: agent_name,
        severity: eventSeverity,
        signal_type: "AR_AGING",
        title: `${cust.company_name}: ${primaryEventType.replace(/_/g, " ")}`,
        description: `Overdue buckets: ${overdueBuckets.join(", ")}. Utilization: ${cust.utilization_pct ?? 0}%. DSO: ${cust.dso_days ?? 0} days.`,
        payload: {
          buckets: {
            bucket_1_30: cust.bucket_1_30 ?? 0,
            bucket_31_60: cust.bucket_31_60 ?? 0,
            bucket_61_90: cust.bucket_61_90 ?? 0,
            bucket_over_90: cust.bucket_over_90 ?? 0,
          },
          utilization_pct: cust.utilization_pct ?? 0,
          dso_days: cust.dso_days ?? 0,
          dunning_stage: dunningStage,
          on_time_rate: behaviour.on_time_rate,
          altman_z_zone: null,
        },
        previous_value: null,
        new_value: cust.bucket_over_90 ?? 0,
        value_type: "USD",
        credit_rating_score: creditRatingScore,
        credit_rating_raw: creditRatingRaw,
        credit_rating_source: creditRatingSource,
        action_required: eventSeverity === "critical" || eventSeverity === "high",
        action_type: null,
        action_status: "none",
        is_demo: DEMO_MODE,
        run_id,
      });

      // Concentration risk event if >20% of portfolio
      if (concentrationPct > 20) {
        await supabase.from("credit_events").insert({
          scope: "customer",
          customer_id: customerId,
          event_type: "CONCENTRATION_RISK",
          source_agent: agent_name,
          severity: concentrationPct > 30 ? "high" : "medium",
          signal_type: "CONCENTRATION",
          title: `${cust.company_name}: High portfolio concentration (${concentrationPct.toFixed(1)}%)`,
          description: `Customer represents ${concentrationPct.toFixed(1)}% of total AR portfolio.`,
          payload: { concentration_pct: concentrationPct, total_portfolio: totalPortfolio },
          new_value: concentrationPct,
          value_type: "PCT",
          credit_rating_score: creditRatingScore,
          credit_rating_raw: creditRatingRaw,
          credit_rating_source: creditRatingSource,
          action_required: false,
          action_type: null,
          action_status: "none",
          is_demo: DEMO_MODE,
          run_id,
        });
      }

      const letter = await composeDunningLetter({
        company_name: cust.company_name,
        ticker: cust.ticker,
        days_31_60: cust.bucket_1_30 ?? 0,
        days_61_90: cust.bucket_61_90 ?? 0,
        days_over_90: cust.bucket_over_90 ?? 0,
        credit_limit: cust.credit_limit ?? 0,
        utilization_pct: cust.utilization_pct ?? 0,
        on_time_rate: behaviour.on_time_rate,
        avg_days_early_late: behaviour.avg_days_early_late,
        dunning_stage: dunningStage,
        anthropic_api_key,
      });

      const { error: msgError } = await supabase.from("agent_messages").insert({
        run_id,
        agent_name,
        customer_id: customerId,
        channel: "email",
        template_type: "collection_reminder",
        recipient_type: "customer",
        recipient_name: cust.company_name,
        recipient_email: `ap@${(cust.ticker ?? "company").toLowerCase()}.com`,
        subject: letter.subject,
        body: letter.body,
        status: "draft",
        is_demo: DEMO_MODE,
      });
      if (msgError) {
        console.error("agent_messages insert failed:", JSON.stringify(msgError));
      } else {
        messagesComposed++;
      }

      // Teams alert for high-exposure accounts (>$100K over 90 days)
      if ((cust.bucket_over_90 ?? 0) > 100_000) {
        const alert = composeTeamsAlert({
          alert_type: "high_overdue_exposure",
          company_name: cust.company_name,
          ticker: cust.ticker,
          severity: (creditRatingScore !== null && creditRatingScore < 20) ? "critical" : "high",
          headline: `$${((cust.bucket_over_90 ?? 0) / 1000).toFixed(0)}K over 90 days past due`,
          details: `Utilization: ${cust.utilization_pct}% | DSO: ${cust.dso} days | Payment health: ${behaviour.health}`,
          metric_label: "Over 90 days",
          metric_value: `$${((cust.bucket_over_90 ?? 0) / 1000).toFixed(0)}K`,
          recommended_action: "Immediate review and potential credit limit reduction.",
        });

        const { error: teamsError } = await supabase.from("agent_messages").insert({
          run_id,
          agent_name,
          customer_id: customerId,
          channel: "teams",
          template_type: "internal_alert",
          recipient_type: "credit_committee",
          recipient_name: "Credit Risk Team",
          subject: alert.subject,
          body: alert.body,
          status: "draft",
          is_demo: DEMO_MODE,
        });
        if (teamsError) {
          console.error("agent_messages insert failed:", JSON.stringify(teamsError));
        } else {
          messagesComposed++;
        }
      }
    }

    await supabase.from("agent_runs").update({
      status: "completed",
      completed_at: new Date().toISOString(),
      customers_scanned: scanned,
      conditions_found: conditionsFound,
      messages_composed: messagesComposed,
      summary: `Scanned ${scanned} customers. Found ${conditionsFound} at risk. Composed ${messagesComposed} messages.`,
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
