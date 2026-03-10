import { createClient } from "https://esm.sh/@supabase/supabase-js@2.98.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

const RATE_LIMIT_MINUTES = 60;
const TOTAL_AI_RUN_CAP = 200; // hard cap on total AI-powered runs

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { triggered_by } = await req.json().catch(() => ({ triggered_by: "manual" }));
  const agent_name = "sec_monitor_agent";

  // --- Rate limit check (1 run per hour) ---
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

  // --- Total AI run cap check ---
  const { count: totalRuns } = await supabase
    .from("agent_runs")
    .select("id", { count: "exact", head: true })
    .eq("agent_name", agent_name)
    .eq("status", "completed");

  if ((totalRuns ?? 0) >= TOTAL_AI_RUN_CAP) {
    return new Response(JSON.stringify({
      error: "token_cap_reached",
      message: "AI analysis budget has been reached. Cached results are still available.",
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
    // Get SEC monitoring data with alerts
    const { data: monitoring } = await supabase
      .from("v_sec_monitoring_dashboard")
      .select("*");

    const scanned = monitoring?.length ?? 0;
    const alerts = (monitoring ?? []).filter((m: any) => m.alert_triggered);
    const conditionsFound = alerts.length;
    let messagesComposed = 0;

    // Get filings for AI analysis
    const { data: allFilings } = await supabase
      .from("sec_filings")
      .select("*, customers(company_name, ticker)")
      .is("ai_summary", null)
      .order("filing_date", { ascending: false })
      .limit(20);

    // AI analysis of filings using Lovable AI
    const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY");
    
    if (LOVABLE_API_KEY && allFilings && allFilings.length > 0) {
      for (const filing of allFilings) {
        const cust = (filing as any).customers;
        const prompt = `You are a credit risk analyst reviewing an SEC filing.

Company: ${cust?.company_name} (${cust?.ticker})
Filing Type: ${filing.filing_type}
Filing Date: ${filing.filing_date}
Key Findings: ${filing.key_findings ?? "None provided"}
Risk Signals: ${(filing.risk_signals ?? []).join(", ") || "None"}

Analyze this filing for credit risk. Provide:
1. A risk score from 0-100 (0=no risk, 100=extreme risk)
2. A concise 2-3 sentence summary of the credit risk implications

Focus on: going concern warnings, revenue decline, debt covenant issues, auditor changes, material weaknesses, liquidity concerns.`;

        try {
          const aiResponse = await fetch("https://ai.gateway.lovable.dev/v1/chat/completions", {
            method: "POST",
            headers: {
              Authorization: `Bearer ${LOVABLE_API_KEY}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              model: "google/gemini-2.5-flash-lite",
              messages: [{ role: "user", content: prompt }],
              tools: [{
                type: "function",
                function: {
                  name: "analyze_filing",
                  description: "Return the risk analysis for an SEC filing",
                  parameters: {
                    type: "object",
                    properties: {
                      risk_score: { type: "integer", description: "Risk score 0-100" },
                      summary: { type: "string", description: "2-3 sentence credit risk summary" },
                    },
                    required: ["risk_score", "summary"],
                    additionalProperties: false,
                  },
                },
              }],
              tool_choice: { type: "function", function: { name: "analyze_filing" } },
            }),
          });

          if (aiResponse.ok) {
            const aiData = await aiResponse.json();
            const toolCall = aiData.choices?.[0]?.message?.tool_calls?.[0];
            if (toolCall) {
              const args = JSON.parse(toolCall.function.arguments);
              // Persist AI results to sec_filings
              await supabase.from("sec_filings").update({
                ai_risk_score: Math.min(100, Math.max(0, args.risk_score)),
                ai_summary: args.summary,
              }).eq("id", filing.id);
            }
          } else if (aiResponse.status === 429 || aiResponse.status === 402) {
            console.log("AI rate limit or payment required, stopping AI analysis");
            break;
          }
        } catch (aiErr) {
          console.error("AI analysis error for filing", filing.id, aiErr);
          // Continue with other filings
        }
      }

      // Update sec_monitoring with aggregate AI scores per customer
      const customerIds = [...new Set((allFilings ?? []).map((f: any) => f.customer_id))];
      for (const custId of customerIds) {
        const { data: custFilings } = await supabase
          .from("sec_filings")
          .select("ai_risk_score, ai_summary")
          .eq("customer_id", custId)
          .not("ai_risk_score", "is", null)
          .order("filing_date", { ascending: false })
          .limit(5);

        if (custFilings && custFilings.length > 0) {
          const avgScore = Math.round(
            custFilings.reduce((sum: number, f: any) => sum + (f.ai_risk_score ?? 0), 0) / custFilings.length
          );
          await supabase.from("sec_monitoring").update({
            ai_risk_score: avgScore,
            ai_summary: custFilings[0].ai_summary,
          }).eq("customer_id", custId);
        }
      }
    }

    // Compose messages for triggered alerts
    for (const item of alerts) {
      const signals = (item.risk_signals ?? []).join(", ");
      const aiInfo = item.ai_summary ? `\n\nAI Analysis (Risk Score: ${item.ai_risk_score}/100):\n${item.ai_summary}` : "";
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
        body: `SEC Filing Alert\nCompany: ${item.company_name} (${item.ticker})\nCIK: ${item.cik}\n\nRisk Signals: ${signals}\n\nLast 10-K: ${item.last_10k_date ?? "N/A"}\nLast 10-Q: ${item.last_10q_date ?? "N/A"}${aiInfo}\n\nPlease review the latest filings and assess impact on credit exposure.`,
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
      summary: `Monitored ${scanned} SEC filings. Found ${conditionsFound} alerts. AI-analyzed ${allFilings?.length ?? 0} filings. Composed ${messagesComposed} notifications.`,
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
