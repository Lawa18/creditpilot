/**
 * News Monitor Agent — Production Version
 *
 * Fetches real negative news for monitored customers using NewsAPI,
 * performs AI-powered sentiment analysis, and stores results.
 *
 * Required secrets:
 *   - NEWS_API_KEY        — from https://newsapi.org (or GNews, etc.)
 *   - LOVABLE_API_KEY     — for AI sentiment analysis (optional)
 *   - SUPABASE_URL        — auto-provided
 *   - SUPABASE_SERVICE_ROLE_KEY — auto-provided
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.98.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const RATE_LIMIT_MINUTES = 60;
const NEWS_API_BASE = "https://newsapi.org/v2";

// Keywords that signal negative/risk-relevant news
const RISK_KEYWORDS = [
  "bankruptcy", "lawsuit", "fraud", "investigation", "default",
  "downgrade", "layoffs", "restructuring", "SEC inquiry", "delisted",
  "recall", "data breach", "regulatory action", "class action",
];

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const NEWS_API_KEY = Deno.env.get("NEWS_API_KEY");
  if (!NEWS_API_KEY) {
    return new Response(JSON.stringify({ error: "NEWS_API_KEY is not configured" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const { triggered_by } = await req.json().catch(() => ({ triggered_by: "manual" }));
  const agent_name = "news_monitor_agent";

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
    // 1. Get all monitored customers
    const { data: customers } = await supabase
      .from("customers")
      .select("id, company_name, ticker")
      .order("company_name");

    if (!customers || customers.length === 0) {
      throw new Error("No customers found to monitor");
    }

    let totalScanned = 0;
    let conditionsFound = 0;
    let messagesComposed = 0;

    const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY");

    // 2. For each customer, search for negative news
    for (const customer of customers) {
      const searchQuery = `"${customer.company_name}" OR "${customer.ticker}" ${RISK_KEYWORDS.slice(0, 5).join(" OR ")}`;

      const newsUrl = `${NEWS_API_BASE}/everything?` + new URLSearchParams({
        q: searchQuery,
        language: "en",
        sortBy: "publishedAt",
        pageSize: "10",
        from: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split("T")[0],
      });

      const newsResponse = await fetch(newsUrl, {
        headers: { "X-Api-Key": NEWS_API_KEY },
      });

      if (!newsResponse.ok) {
        console.error(`NewsAPI error for ${customer.company_name}: ${newsResponse.status}`);
        continue;
      }

      const newsData = await newsResponse.json();
      const articles = newsData.articles ?? [];
      totalScanned += articles.length;

      // 3. Analyze each article for severity
      for (const article of articles) {
        // Check if we already have this headline
        const { data: existing } = await supabase
          .from("negative_news")
          .select("id")
          .eq("customer_id", customer.id)
          .eq("headline", article.title)
          .limit(1);

        if (existing && existing.length > 0) continue;

        // Determine severity via keyword matching (fast fallback)
        let severity = "low";
        let sentimentScore = 0;
        let category = "general";
        const titleLower = (article.title ?? "").toLowerCase();
        const descLower = (article.description ?? "").toLowerCase();
        const combined = `${titleLower} ${descLower}`;

        const criticalTerms = ["bankruptcy", "fraud", "default", "delisted"];
        const highTerms = ["lawsuit", "investigation", "SEC inquiry", "class action"];
        const mediumTerms = ["downgrade", "layoffs", "restructuring", "recall"];

        if (criticalTerms.some((t) => combined.includes(t))) {
          severity = "critical";
          sentimentScore = -0.9;
          category = criticalTerms.find((t) => combined.includes(t)) ?? "general";
        } else if (highTerms.some((t) => combined.includes(t))) {
          severity = "high";
          sentimentScore = -0.7;
          category = highTerms.find((t) => combined.includes(t)) ?? "general";
        } else if (mediumTerms.some((t) => combined.includes(t))) {
          severity = "medium";
          sentimentScore = -0.4;
          category = mediumTerms.find((t) => combined.includes(t)) ?? "general";
        }

        // Optional: AI-powered sentiment analysis for more accuracy
        if (LOVABLE_API_KEY && (severity === "critical" || severity === "high")) {
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
                  content: `Analyze this news headline for credit risk sentiment. Return JSON with: sentiment_score (-1 to 0, where -1 is most negative), category (one of: bankruptcy, fraud, litigation, regulatory, financial_distress, operational, reputational), severity (critical/high/medium/low).\n\nHeadline: ${article.title}\nDescription: ${article.description ?? "N/A"}\nCompany: ${customer.company_name}`,
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
                  sentimentScore = parsed.sentiment_score ?? sentimentScore;
                  category = parsed.category ?? category;
                  severity = parsed.severity ?? severity;
                }
              } catch { /* keep keyword-based values */ }
            }
          } catch (aiErr) {
            console.error("AI analysis error:", aiErr);
          }
        }

        // 4. Store the news item
        await supabase.from("negative_news").insert({
          customer_id: customer.id,
          headline: article.title,
          summary: article.description ?? null,
          source: article.source?.name ?? "Unknown",
          news_date: article.publishedAt?.split("T")[0] ?? new Date().toISOString().split("T")[0],
          severity,
          sentiment_score: sentimentScore,
          category,
          agent_name,
          reviewed: false,
        });

        if (severity === "critical" || severity === "high") {
          conditionsFound++;
        }
      }
    }

    // 5. Compose internal alerts for critical/high items found this run
    const { data: criticalNews } = await supabase
      .from("negative_news")
      .select("*, customers(company_name, ticker)")
      .eq("reviewed", false)
      .in("severity", ["critical", "high"])
      .order("news_date", { ascending: false })
      .limit(10);

    for (const item of (criticalNews ?? []).slice(0, 5)) {
      const cust = (item as any).customers;
      await supabase.from("agent_messages").insert({
        run_id,
        agent_name,
        customer_id: item.customer_id,
        channel: "teams",
        template_type: "news_alert",
        recipient_type: "internal",
        recipient_name: "Credit Risk Team",
        subject: `📰 ${item.severity?.toUpperCase()} news: ${cust?.company_name}`,
        body: `News Alert — ${item.severity?.toUpperCase()}\n${item.headline}\n\nSource: ${item.source} | Date: ${item.news_date}\nCategory: ${item.category}\nSentiment: ${item.sentiment_score}\n\nSummary: ${item.summary}\n\nAction required: Review and assess credit impact for ${cust?.company_name} (${cust?.ticker}).`,
        status: "composed",
      });
      messagesComposed++;
    }

    await supabase.from("agent_runs").update({
      status: "completed",
      completed_at: new Date().toISOString(),
      customers_scanned: totalScanned,
      conditions_found: conditionsFound,
      messages_composed: messagesComposed,
      actions_taken: 0,
      summary: `Scanned ${totalScanned} articles for ${customers.length} customers. Found ${conditionsFound} critical/high alerts. Composed ${messagesComposed} notifications.`,
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
