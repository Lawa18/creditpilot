/**
 * @skill classify-news
 * @type generative
 * @description Classifies a news article for credit risk relevance using Claude API.
 *   Returns severity (critical/high/medium/low), a short category label, and a
 *   sentiment score (-1.0 to 0). Falls back to keyword-based classification if
 *   the API call fails or no key is provided.
 * @input ClassifyNewsInput — article headline, optional summary, company name
 * @output ClassifyNewsResult — severity, category, sentiment_score, classified_by
 * @usedBy news-monitor-agent
 */

export type NewsSeverity = "critical" | "high" | "medium" | "low";

export interface ClassifyNewsInput {
  headline: string;
  summary?: string;
  source?: string;
  company_name: string;
  anthropic_api_key?: string;
}

export interface ClassifyNewsResult {
  severity: NewsSeverity;
  category: string;
  sentiment_score: number; // -1.0 to 0 (negative news scale)
  classified_by: "claude" | "keyword";
}

const CRITICAL_KEYWORDS = [
  "bankruptcy", "chapter 11", "chapter 7", "insolvency", "liquidation",
  "default", "receivership", "going concern", "fraud", "sec investigation",
  "delisted", "criminal charges", "class action",
];

const HIGH_KEYWORDS = [
  "layoffs", "restructuring", "downgrade", "credit rating cut", "net loss",
  "revenue decline", "profit warning", "covenant breach", "debt refinancing",
  "ceo resign", "executive departure", "material weakness",
];

export async function classifyNews(
  input: ClassifyNewsInput
): Promise<ClassifyNewsResult> {
  if (input.anthropic_api_key) {
    try {
      const response = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "x-api-key": input.anthropic_api_key,
          "anthropic-version": "2023-06-01",
          "content-type": "application/json",
        },
        body: JSON.stringify({
          model: "claude-haiku-4-5-20251001",
          max_tokens: 200,
          messages: [
            {
              role: "user",
              content: `You are a B2B credit risk analyst. Classify this news for credit risk impact on ${input.company_name}.

Headline: ${input.headline}
${input.summary ? `Summary: ${input.summary}` : ""}
Source: ${input.source ?? "Unknown"}

Respond with JSON only (no markdown):
{"severity":"critical|high|medium|low","category":"short label e.g. Bankruptcy, Fraud, Executive Change","sentiment_score":-0.5}`,
            },
          ],
        }),
      });

      if (response.ok) {
        const data = await response.json();
        const text: string = data.content?.[0]?.text ?? "";
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const parsed = JSON.parse(jsonMatch[0]);
          if (
            parsed.severity &&
            parsed.category &&
            typeof parsed.sentiment_score === "number"
          ) {
            return {
              severity: parsed.severity as NewsSeverity,
              category: parsed.category,
              sentiment_score: Math.max(-1, Math.min(0, parsed.sentiment_score)),
              classified_by: "claude",
            };
          }
        }
      }
    } catch {
      // fall through to keyword classifier
    }
  }

  return keywordClassify(`${input.headline} ${input.summary ?? ""}`.toLowerCase());
}

function keywordClassify(text: string): ClassifyNewsResult {
  const isCritical = CRITICAL_KEYWORDS.some((kw) => text.includes(kw));
  const isHigh = HIGH_KEYWORDS.some((kw) => text.includes(kw));

  if (isCritical) {
    return {
      severity: "critical",
      category: detectCategory(text, "Bankruptcy / Legal"),
      sentiment_score: -0.9,
      classified_by: "keyword",
    };
  }
  if (isHigh) {
    return {
      severity: "high",
      category: detectCategory(text, "Financial Distress"),
      sentiment_score: -0.6,
      classified_by: "keyword",
    };
  }
  return {
    severity: "medium",
    category: detectCategory(text, "Business News"),
    sentiment_score: -0.3,
    classified_by: "keyword",
  };
}

function detectCategory(text: string, fallback: string): string {
  if (text.includes("bankrupt") || text.includes("chapter 11")) return "Bankruptcy";
  if (text.includes("fraud") || text.includes("sec investigation")) return "Fraud / Legal";
  if (text.includes("layoff") || text.includes("restructur")) return "Restructuring";
  if (text.includes("revenue") || text.includes("profit") || text.includes("loss"))
    return "Financial Results";
  if (text.includes("ceo") || text.includes("executive")) return "Executive Change";
  return fallback;
}
