/**
 * AR Aging Agent — Production Version
 *
 * Connects to ERP/accounting APIs (QuickBooks, NetSuite, SAP, or generic REST)
 * to fetch real AR aging data, stores snapshots, and generates alerts.
 *
 * Required secrets:
 *   - ERP_API_URL         — Base URL for your ERP/accounting API
 *   - ERP_API_KEY         — API key or Bearer token for your ERP
 *   - ERP_PROVIDER        — "quickbooks" | "netsuite" | "sap" | "generic" (default: "generic")
 *   - SUPABASE_URL        — auto-provided
 *   - SUPABASE_SERVICE_ROLE_KEY — auto-provided
 *
 * Generic API Contract:
 * If using ERP_PROVIDER=generic, your API should return:
 *   GET /ar-aging → { customers: [{ customer_id, company_name, ticker?,
 *     current, days_1_30, days_31_60, days_61_90, days_over_90,
 *     total_ar, credit_limit, dso }] }
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.98.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const RATE_LIMIT_MINUTES = 60;

interface ArAgingRecord {
  customer_id: string;
  company_name: string;
  ticker?: string;
  current: number;
  days_1_30: number;
  days_31_60: number;
  days_61_90: number;
  days_over_90: number;
  total_ar: number;
  credit_limit: number;
  dso: number;
}

// --- ERP Adapters ---

async function fetchGenericErp(apiUrl: string, apiKey: string): Promise<ArAgingRecord[]> {
  const response = await fetch(`${apiUrl}/ar-aging`, {
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
  });
  if (!response.ok) throw new Error(`ERP API error [${response.status}]: ${await response.text()}`);
  const data = await response.json();
  return data.customers ?? [];
}

async function fetchQuickBooksAging(apiUrl: string, apiKey: string): Promise<ArAgingRecord[]> {
  // QuickBooks Online — AgedReceivableDetail report
  const response = await fetch(`${apiUrl}/v3/company/YOUR_COMPANY_ID/reports/AgedReceivableDetail`, {
    headers: {
      Authorization: `Bearer ${apiKey}`,
      Accept: "application/json",
    },
  });
  if (!response.ok) throw new Error(`QuickBooks API error [${response.status}]: ${await response.text()}`);
  const data = await response.json();

  // Transform QuickBooks response to our standard format
  // NOTE: This is a simplified mapping — adjust to your QB setup
  const rows = data?.Rows?.Row ?? [];
  return rows
    .filter((r: any) => r.type === "Data")
    .map((r: any) => ({
      customer_id: r.ColData?.[0]?.id ?? "",
      company_name: r.ColData?.[0]?.value ?? "Unknown",
      current: parseFloat(r.ColData?.[1]?.value ?? "0"),
      days_1_30: parseFloat(r.ColData?.[2]?.value ?? "0"),
      days_31_60: parseFloat(r.ColData?.[3]?.value ?? "0"),
      days_61_90: parseFloat(r.ColData?.[4]?.value ?? "0"),
      days_over_90: parseFloat(r.ColData?.[5]?.value ?? "0"),
      total_ar: parseFloat(r.ColData?.[6]?.value ?? "0"),
      credit_limit: 0,
      dso: 0,
    }));
}

async function fetchErpData(provider: string, apiUrl: string, apiKey: string): Promise<ArAgingRecord[]> {
  switch (provider) {
    case "quickbooks":
      return fetchQuickBooksAging(apiUrl, apiKey);
    // Add more adapters as needed:
    // case "netsuite": return fetchNetSuiteAging(apiUrl, apiKey);
    // case "sap": return fetchSapAging(apiUrl, apiKey);
    default:
      return fetchGenericErp(apiUrl, apiKey);
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const ERP_API_URL = Deno.env.get("ERP_API_URL");
  const ERP_API_KEY = Deno.env.get("ERP_API_KEY");
  const ERP_PROVIDER = Deno.env.get("ERP_PROVIDER") ?? "generic";

  if (!ERP_API_URL || !ERP_API_KEY) {
    return new Response(JSON.stringify({
      error: "ERP_API_URL and ERP_API_KEY must be configured",
    }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

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
    // 1. Fetch AR aging data from ERP
    const erpRecords = await fetchErpData(ERP_PROVIDER, ERP_API_URL, ERP_API_KEY);
    const scanned = erpRecords.length;

    // 2. Clean up previous pending actions
    await supabase.from("pending_actions").delete().eq("agent_name", agent_name).eq("status", "pending");

    let conditionsFound = 0;
    let messagesComposed = 0;
    let actionsTaken = 0;
    const today = new Date().toISOString().split("T")[0];

    for (const record of erpRecords) {
      // 3. Upsert customer if needed (match by company_name or external ID)
      let customerId = record.customer_id;

      const { data: existingCustomer } = await supabase
        .from("customers")
        .select("id")
        .eq("company_name", record.company_name)
        .limit(1);

      if (existingCustomer && existingCustomer.length > 0) {
        customerId = existingCustomer[0].id;
      } else {
        // Create the customer
        const { data: newCustomer } = await supabase
          .from("customers")
          .insert({
            company_name: record.company_name,
            ticker: record.ticker ?? null,
            credit_limit: record.credit_limit,
            current_exposure: record.total_ar,
          })
          .select("id")
          .single();

        if (newCustomer) customerId = newCustomer.id;
      }

      // 4. Calculate derived fields
      const utilizationPct = record.credit_limit > 0
        ? Math.round((record.total_ar / record.credit_limit) * 100 * 10) / 10
        : 0;

      const riskTier = record.days_over_90 > 0 ? "CRITICAL"
        : record.days_61_90 > 0 ? "HIGH"
        : record.days_31_60 > 0 ? "MEDIUM"
        : record.days_1_30 > 0 ? "LOW"
        : "CURRENT";

      // 5. Store AR aging snapshot
      await supabase.from("ar_aging_snapshots").insert({
        customer_id: customerId,
        as_of_date: today,
        current_amount: record.current,
        days_1_30: record.days_1_30,
        days_31_60: record.days_31_60,
        days_61_90: record.days_61_90,
        days_over_90: record.days_over_90,
        total_ar: record.total_ar,
        credit_limit: record.credit_limit,
        utilization_pct: utilizationPct,
        dso: record.dso,
        risk_tier: riskTier,
      });

      // 6. Update customer exposure
      await supabase.from("customers").update({
        current_exposure: record.total_ar,
        credit_limit: record.credit_limit,
      }).eq("id", customerId);

      // 7. Check if at-risk
      const isAtRisk = record.days_over_90 > 0 || utilizationPct > 80;
      if (!isAtRisk) continue;

      conditionsFound++;
      const totalOverdue = record.days_31_60 + record.days_61_90 + record.days_over_90;

      // 8. Compose collection reminder
      await supabase.from("agent_messages").insert({
        run_id,
        agent_name,
        customer_id: customerId,
        channel: "email",
        template_type: "collection_reminder",
        recipient_type: "customer",
        recipient_name: record.company_name,
        recipient_email: `ap@${(record.ticker ?? "company").toLowerCase()}.com`,
        subject: `Payment Reminder — $${(totalOverdue / 1000).toFixed(0)}K overdue balance`,
        body: `Dear ${record.company_name} Accounts Payable,\n\nThis is a reminder regarding your outstanding balance of $${totalOverdue.toLocaleString()}.\n\nYour current AR aging:\n• 31-60 days: $${record.days_31_60.toLocaleString()}\n• 61-90 days: $${record.days_61_90.toLocaleString()}\n• Over 90 days: $${record.days_over_90.toLocaleString()}\n\nPlease arrange payment at your earliest convenience.\n\nBest regards,\nCredit Management Team`,
        status: "composed",
      });
      messagesComposed++;

      // 9. Internal alert for high exposure
      if (record.days_over_90 > 100000) {
        await supabase.from("agent_messages").insert({
          run_id,
          agent_name,
          customer_id: customerId,
          channel: "teams",
          template_type: "internal_alert",
          recipient_type: "internal",
          recipient_name: "Credit Risk Team",
          subject: `⚠️ High exposure alert: ${record.company_name}`,
          body: `Critical AR Alert\n${record.company_name} (${record.ticker ?? "N/A"}) has $${(record.days_over_90 / 1000).toFixed(0)}K over 90 days past due.\nUtilization: ${utilizationPct}% | DSO: ${record.dso} days\nRecommend immediate review and potential credit limit reduction.`,
          status: "composed",
        });
        messagesComposed++;
      }

      // 10. Propose credit limit reduction
      if (utilizationPct > 70 && record.days_over_90 > 50000) {
        const proposedLimit = Math.round(record.credit_limit * 0.6);
        await supabase.from("pending_actions").insert({
          run_id,
          agent_name,
          customer_id: customerId,
          action_type: "CREDIT_LIMIT_REDUCTION",
          rationale: `Utilization at ${utilizationPct}% with $${(record.days_over_90 / 1000).toFixed(0)}K over 90 days. DSO: ${record.dso} days. Recommend 40% limit reduction.`,
          current_value: record.credit_limit,
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
      summary: `Fetched ${scanned} records from ${ERP_PROVIDER} ERP. Found ${conditionsFound} at risk. Composed ${messagesComposed} messages. ${actionsTaken} actions pending approval.`,
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
