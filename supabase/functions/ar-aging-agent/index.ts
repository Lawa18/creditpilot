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
  const agent_name = "ar_aging_agent";

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
      message: `This agent was run recently. Please wait before running again.`,
      last_run_at: recentRuns[0].started_at,
    }), {
      status: 429,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const run_id = crypto.randomUUID();

  // 1. Insert running run
  await supabase.from("agent_runs").insert({
    run_id,
    agent_name,
    status: "running",
    started_at: new Date().toISOString(),
    triggered_by,
  });

  try {
    // 2. Clean up previous pending actions for this agent
    await supabase.from("pending_actions").delete().eq("agent_name", agent_name).eq("status", "pending");

    // 3. Get customers with AR aging data
    const { data: customers } = await supabase
      .from("v_ar_aging_current")
      .select("*")
      .order("total_ar", { ascending: false });

    const scanned = customers?.length ?? 0;
    let conditionsFound = 0;
    let messagesComposed = 0;
    let actionsTaken = 0;

    // 3. Find at-risk customers (high utilization or overdue)
    const atRisk = (customers ?? []).filter(
      (c: any) => (c.days_over_90 ?? 0) > 0 || (c.utilization_pct ?? 0) > 80
    );
    conditionsFound = atRisk.length;

    // 4. Compose messages for top at-risk customers (max 5)
    for (const cust of atRisk.slice(0, 5)) {
      const totalOverdue = (cust.days_31_60 ?? 0) + (cust.days_61_90 ?? 0) + (cust.days_over_90 ?? 0);

      await supabase.from("agent_messages").insert({
        run_id,
        agent_name,
        customer_id: cust.customer_id,
        channel: "email",
        template_type: "collection_reminder",
        recipient_type: "customer",
        recipient_name: cust.company_name,
        recipient_email: `ap@${(cust.ticker ?? "company").toLowerCase()}.com`,
        subject: `Payment Reminder — $${(totalOverdue / 1000).toFixed(0)}K overdue balance`,
        body: `Dear ${cust.company_name} Accounts Payable,\n\nThis is a reminder regarding your outstanding balance of $${(totalOverdue).toLocaleString()}.\n\nYour current AR aging:\n• 31-60 days: $${(cust.days_31_60 ?? 0).toLocaleString()}\n• 61-90 days: $${(cust.days_61_90 ?? 0).toLocaleString()}\n• Over 90 days: $${(cust.days_over_90 ?? 0).toLocaleString()}\n\nPlease arrange payment at your earliest convenience.\n\nBest regards,\nCredit Management Team`,
        status: "composed",
      });
      messagesComposed++;

      if ((cust.days_over_90 ?? 0) > 100000) {
        await supabase.from("agent_messages").insert({
          run_id,
          agent_name,
          customer_id: cust.customer_id,
          channel: "teams",
          template_type: "internal_alert",
          recipient_type: "internal",
          recipient_name: "Credit Risk Team",
          subject: `⚠️ High exposure alert: ${cust.company_name}`,
          body: `Critical AR Alert\n${cust.company_name} (${cust.ticker}) has $${((cust.days_over_90 ?? 0) / 1000).toFixed(0)}K over 90 days past due.\nUtilization: ${cust.utilization_pct}% | DSO: ${cust.dso} days\nRecommend immediate review and potential credit limit reduction.`,
          status: "composed",
        });
        messagesComposed++;
      }

      if ((cust.utilization_pct ?? 0) > 70 && (cust.days_over_90 ?? 0) > 50000) {
        const proposedLimit = Math.round((cust.credit_limit ?? 0) * 0.6);
        await supabase.from("pending_actions").insert({
          run_id,
          agent_name,
          customer_id: cust.customer_id,
          action_type: "CREDIT_LIMIT_REDUCTION",
          rationale: `Utilization at ${cust.utilization_pct}% with $${((cust.days_over_90 ?? 0) / 1000).toFixed(0)}K over 90 days. DSO: ${cust.dso} days. Recommend 40% limit reduction.`,
          current_value: cust.credit_limit,
          proposed_value: proposedLimit,
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
