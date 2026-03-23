import { createClient } from "https://esm.sh/@supabase/supabase-js@2.98.0";
import { analysePaymentBehaviour } from "../_shared/skills/analytical/analyse-payment-behaviour.ts";
import { calculateCreditLimitProposal } from "../_shared/skills/analytical/calculate-credit-limit-proposal.ts";
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
    run_id,
    agent_name,
    status: "running",
    started_at: new Date().toISOString(),
    triggered_by,
  });

  try {
    // Clean up previous pending actions for this agent
    await supabase.from("pending_actions").delete().eq("agent_name", agent_name).eq("status", "pending");

    // Get customers with AR aging data
    const { data: customers } = await supabase
      .from("v_ar_aging_current")
      .select("*")
      .order("total_ar", { ascending: false });

    // Get credit metrics for Altman Z zones
    const { data: creditMetrics } = await supabase
      .from("credit_metrics")
      .select("customer_id, altman_z_score");

    const zoneMap = new Map<string, "safe" | "grey" | "distress">();
    for (const m of creditMetrics ?? []) {
      const z = m.altman_z_score ?? 0;
      zoneMap.set(
        m.customer_id,
        z > 2.99 ? "safe" : z >= 1.81 ? "grey" : "distress"
      );
    }

    const scanned = customers?.length ?? 0;
    let conditionsFound = 0;
    let messagesComposed = 0;
    let actionsTaken = 0;

    // Find at-risk customers
    const atRisk = (customers ?? []).filter(
      (c: any) => (c.days_over_90 ?? 0) > 0 || (c.utilization_pct ?? 0) > 80
    );
    conditionsFound = atRisk.length;

    // Process top 5 at-risk customers
    for (const cust of atRisk.slice(0, 5)) {
      const customerId: string = cust.customer_id;
      const altman_z_zone = zoneMap.get(customerId) ?? null;

      // Fetch payment transactions for this customer
      const { data: transactions } = await supabase
        .from("payment_transactions")
        .select("payment_date, days_to_pay, days_early_late, on_time, amount")
        .eq("customer_id", customerId)
        .order("payment_date", { ascending: false })
        .limit(24);

      const behaviour = analysePaymentBehaviour(transactions ?? []);

      // Compose dunning letter via skill (Claude API with template fallback)
      const dunningStage: 1 | 2 | 3 | 4 =
        (cust.days_over_90 ?? 0) > 100_000 ? 4
        : (cust.days_over_90 ?? 0) > 50_000 ? 3
        : (cust.days_61_90 ?? 0) > 0 ? 2
        : 1;

      const letter = await composeDunningLetter({
        company_name: cust.company_name,
        ticker: cust.ticker,
        days_31_60: cust.days_31_60 ?? 0,
        days_61_90: cust.days_61_90 ?? 0,
        days_over_90: cust.days_over_90 ?? 0,
        credit_limit: cust.credit_limit ?? 0,
        utilization_pct: cust.utilization_pct ?? 0,
        on_time_rate: behaviour.on_time_rate,
        avg_days_early_late: behaviour.avg_days_early_late,
        dunning_stage: dunningStage,
        anthropic_api_key,
      });

      await supabase.from("agent_messages").insert({
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
        status: "composed",
      });
      messagesComposed++;

      // Teams alert for high-exposure accounts (>$100K over 90 days)
      if ((cust.days_over_90 ?? 0) > 100_000) {
        const alert = composeTeamsAlert({
          alert_type: "high_overdue_exposure",
          company_name: cust.company_name,
          ticker: cust.ticker,
          severity: altman_z_zone === "distress" ? "critical" : "high",
          headline: `$${((cust.days_over_90 ?? 0) / 1000).toFixed(0)}K over 90 days past due`,
          details: `Utilization: ${cust.utilization_pct}% | DSO: ${cust.dso} days | Payment health: ${behaviour.health}`,
          metric_label: "Over 90 days",
          metric_value: `$${((cust.days_over_90 ?? 0) / 1000).toFixed(0)}K`,
          recommended_action: "Immediate review and potential credit limit reduction.",
        });

        await supabase.from("agent_messages").insert({
          run_id,
          agent_name,
          customer_id: customerId,
          channel: "teams",
          template_type: "internal_alert",
          recipient_type: "internal",
          recipient_name: "Credit Risk Team",
          subject: alert.subject,
          body: alert.body,
          status: "composed",
        });
        messagesComposed++;
      }

      // Credit limit proposal via skill
      const proposal = calculateCreditLimitProposal({
        current_limit: cust.credit_limit ?? 0,
        current_exposure: cust.current_exposure ?? 0,
        days_over_90: cust.days_over_90 ?? 0,
        utilization_pct: cust.utilization_pct ?? 0,
        altman_z_zone,
        on_time_rate: behaviour.on_time_rate,
      });

      if (proposal.action === "reduce") {
        await supabase.from("pending_actions").insert({
          run_id,
          agent_name,
          customer_id: customerId,
          action_type: "CREDIT_LIMIT_REDUCTION",
          rationale: proposal.rationale,
          current_value: cust.credit_limit,
          proposed_value: proposal.proposed_limit,
          status: "pending",
        });
        actionsTaken++;
      }
    }

    await supabase.from("agent_runs").update({
      status: "completed",
      completed_at: new Date().toISOString(),
      customers_scanned: scanned,
      conditions_found: conditionsFound,
      messages_composed: messagesComposed,
      actions_taken: actionsTaken,
      summary: `Scanned ${scanned} customers. Found ${conditionsFound} at risk. Composed ${messagesComposed} messages. ${actionsTaken} actions pending approval.`,
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
