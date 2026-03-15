/**
 * SEC Monitor Agent — Production Version
 *
 * Fetches real SEC filings from EDGAR API, performs AI risk analysis,
 * and stores results with alerts.
 *
 * Required secrets:
 *   - LOVABLE_API_KEY     — for AI analysis (optional but recommended)
 *   - SUPABASE_URL        — auto-provided
 *   - SUPABASE_SERVICE_ROLE_KEY — auto-provided
 *
 * Note: SEC EDGAR is free and does not require an API key,
 * but requires a User-Agent header with your contact info.
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.98.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const RATE_LIMIT_MINUTES = 60;
const TOTAL_AI_RUN_CAP = 200;
const EDGAR_BASE = "https://efts.sec.gov/LATEST";
const EDGAR_FILINGS = "https://data.sec.gov/submissions";

// IMPORTANT: SEC requires a User-Agent with your name and email
const SEC_USER_AGENT = Deno.env.get("SEC_USER_AGENT") ?? "MyCreditPilot admin@example.com";

// Known risk signals to look for in filings
const RISK_SIGNAL_PATTERNS = [
  { pattern: /going concern/i, signal: "Going Concern Warning" },
  { pattern: /material weakness/i, signal: "Material Weakness" },
  { pattern: /restatement/i, signal: "Financial Restatement" },
  { pattern: /covenant (breach|violation|default)/i, signal: "Covenant Breach" },
  { pattern: /auditor change|change.+auditor/i, signal: "Auditor Change" },
  { pattern: /liquidity (concern|risk|issue)/i, signal: "Liquidity Risk" },
  { pattern: /goodwill impairment/i, signal: "Goodwill Impairment" },
  { pattern: /debt (default|restructur)/i, signal: "Debt Default/Restructuring" },
  { pattern: /SEC (investigation|inquiry|enforcement)/i, signal: "SEC Investigation" },
  { pattern: /class action/i, signal: "Class Action Lawsuit" },
];

interface EdgarFiling {
  accessionNumber: string;
  filingDate: string;
  form: string;
  primaryDocument: string;
}

async function fetchEdgarFilings(cik: string): Promise<EdgarFiling[]> {
  // Pad CIK to 10 digits as required by SEC
  const paddedCik = cik.padStart(10, "0");

  const response = await fetch(`${EDGAR_FILINGS}/CIK${paddedCik}.json`, {
    headers: { "User-Agent": SEC_USER_AGENT },
  });

  if (!response.ok) {
    console.error(`EDGAR error for CIK ${cik}: ${response.status}`);
    return [];
  }

  const data = await response.json();
  const recent = data.filings?.recent;
  if (!recent) return [];

  const filings: EdgarFiling[] = [];
  const relevantForms = ["10-K", "10-Q", "8-K", "10-K/A", "10-Q/A"];

  for (let i = 0; i < (recent.form?.length ?? 0); i++) {
    if (relevantForms.includes(recent.form[i])) {
      filings.push({
        accessionNumber: recent.accessionNumber[i],
        filingDate: recent.filingDate[i],
        form: recent.form[i],
        primaryDocument: recent.primaryDocument[i],
      });
    }
    if (filings.length >= 10) break;
  }

  return filings;
}

async function searchEdgarFullText(companyName: string): Promise<any[]> {
  // Full-text search for risk signals
  const response = await fetch(
    `${EDGAR_BASE}/search-index?q="${encodeURIComponent(companyName)}"&dateRange=custom&startdt=${
      new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString().split("T")[0]
    }&enddt=${new Date().toISOString().split("T")[0]}&forms=10-K,10-Q,8-K`,
    { headers: { "User-Agent": SEC_USER_AGENT } }
  );

  if (!response.ok) return [];
  const data = await response.json();
  return data.hits?.hits ?? [];
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { triggered_by } = await req.json().catch(() => ({ triggered_by: "manual" }));
  const agent_name = "sec_monitor_agent";

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

  // --- Total AI run cap ---
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
    // 1. Get customers with SEC monitoring config (must have CIK)
    const { data: monitoring } = await supabase
      .from("sec_monitoring")
      .select("*, customers(id, company_name, ticker)")
      .not("cik", "is", null);

    if (!monitoring || monitoring.length === 0) {
      throw new Error("No customers with CIK numbers found in sec_monitoring table");
    }

    const scanned = monitoring.length;
    let conditionsFound = 0;
    let messagesComposed = 0;
    let filingsAnalyzed = 0;

    const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY");

    for (const entry of monitoring) {
      const cust = (entry as any).customers;
      if (!entry.cik || !cust) continue;

      // 2. Fetch real filings from EDGAR
      const filings = await fetchEdgarFilings(entry.cik);

      // Rate limit: SEC asks for max 10 requests/second
      await new Promise((r) => setTimeout(r, 150));

      let last10kDate: string | null = null;
      let last10qDate: string | null = null;
      const riskSignals: string[] = [];

      for (const filing of filings) {
        // Track latest filing dates
        if (filing.form === "10-K" || filing.form === "10-K/A") {
          if (!last10kDate || filing.filingDate > last10kDate) last10kDate = filing.filingDate;
        }
        if (filing.form === "10-Q" || filing.form === "10-Q/A") {
          if (!last10qDate || filing.filingDate > last10qDate) last10qDate = filing.filingDate;
        }

        // Check if this filing already exists
        const { data: existingFiling } = await supabase
          .from("sec_filings")
          .select("id")
          .eq("customer_id", cust.id)
          .eq("filing_type", filing.form)
          .eq("filing_date", filing.filingDate)
          .limit(1);

        if (existingFiling && existingFiling.length > 0) continue;

        // 3. Store the filing
        const { data: newFiling } = await supabase.from("sec_filings").insert({
          customer_id: cust.id,
          filing_type: filing.form,
          filing_date: filing.filingDate,
          agent_name,
          reviewed: false,
        }).select("id").single();

        if (!newFiling) continue;

        // 4. AI analysis if available
        if (LOVABLE_API_KEY) {
          try {
            const aiResponse = await fetch("https://ai.gateway.lovable.dev/v1/chat/completions", {
              method: "POST",
              headers: {
                Authorization: `Bearer ${LOVABLE_API_KEY}`,
                "Content-Type": "application/json",
              },
              body: JSON.stringify({
                model: "google/gemini-2.5-flash-lite",
                messages: [{
                  role: "user",
                  content: `You are a credit risk analyst. A new SEC ${filing.form} filing was made by ${cust.company_name} (${cust.ticker}) on ${filing.filingDate}.\n\nBased on the filing type and timing, provide:\n1. A risk score 0-100\n2. A 2-sentence credit risk assessment\n3. Any likely risk signals\n\nRespond as JSON: { "risk_score": number, "summary": string, "risk_signals": string[] }`,
                }],
              }),
            });

            if (aiResponse.ok) {
              const aiData = await aiResponse.json();
              const content = aiData.choices?.[0]?.message?.content ?? "";
              try {
                const jsonMatch = content.match(/\{[\s\S]*\}/);
                if (jsonMatch) {
                  const parsed = JSON.parse(jsonMatch[0]);
                  await supabase.from("sec_filings").update({
                    ai_risk_score: Math.min(100, Math.max(0, parsed.risk_score ?? 50)),
                    ai_summary: parsed.summary ?? null,
                    risk_signals: parsed.risk_signals ?? [],
                    key_findings: parsed.summary ?? null,
                  }).eq("id", newFiling.id);

                  riskSignals.push(...(parsed.risk_signals ?? []));
                }
              } catch { /* keep going */ }
            } else if (aiResponse.status === 429 || aiResponse.status === 402) {
              console.log("AI rate limit reached, stopping AI analysis");
              break;
            }
          } catch (aiErr) {
            console.error("AI analysis error:", aiErr);
          }
        }

        filingsAnalyzed++;
      }

      // 5. Update sec_monitoring with latest data
      const uniqueSignals = [...new Set(riskSignals)];
      const alertTriggered = uniqueSignals.length > 0;

      await supabase.from("sec_monitoring").update({
        last_10k_date: last10kDate ?? entry.last_10k_date,
        last_10q_date: last10qDate ?? entry.last_10q_date,
        risk_signals: uniqueSignals.length > 0 ? uniqueSignals : entry.risk_signals,
        alert_triggered: alertTriggered || entry.alert_triggered,
      }).eq("id", entry.id);

      // 6. Update aggregate AI scores
      const { data: custFilings } = await supabase
        .from("sec_filings")
        .select("ai_risk_score, ai_summary")
        .eq("customer_id", cust.id)
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
        }).eq("customer_id", cust.id);
      }

      // 7. Compose alert if triggered
      if (alertTriggered) {
        conditionsFound++;
        const aiInfo = entry.ai_summary
          ? `\n\nAI Analysis (Risk Score: ${entry.ai_risk_score}/100):\n${entry.ai_summary}`
          : "";

        await supabase.from("agent_messages").insert({
          run_id,
          agent_name,
          customer_id: cust.id,
          channel: "email",
          template_type: "sec_alert",
          recipient_type: "internal",
          recipient_name: "Credit Analysis Team",
          subject: `SEC Alert: ${cust.company_name} (${cust.ticker}) — Risk signals detected`,
          body: `SEC Filing Alert\nCompany: ${cust.company_name} (${cust.ticker})\nCIK: ${entry.cik}\n\nRisk Signals: ${uniqueSignals.join(", ")}\n\nLast 10-K: ${last10kDate ?? "N/A"}\nLast 10-Q: ${last10qDate ?? "N/A"}${aiInfo}\n\nPlease review the latest filings and assess impact on credit exposure.`,
          status: "composed",
        });
        messagesComposed++;
      }
    }

    await supabase.from("agent_runs").update({
      status: "completed",
      completed_at: new Date().toISOString(),
      customers_scanned: scanned,
      conditions_found: conditionsFound,
      messages_composed: messagesComposed,
      actions_taken: 0,
      summary: `Monitored ${scanned} companies via EDGAR. Analyzed ${filingsAnalyzed} new filings. Found ${conditionsFound} alerts. Composed ${messagesComposed} notifications.`,
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
