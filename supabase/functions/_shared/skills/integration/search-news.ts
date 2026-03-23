/**
 * @skill search-news
 * @type integration
 * @description Searches for recent news about a company using the Tavily API.
 *   Returns structured article results ready for classification. Returns an empty
 *   array if the API key is missing or the request fails — callers should handle
 *   the empty case gracefully.
 * @input SearchNewsInput — company name, optional ticker, search parameters
 * @output SearchNewsResult[] — array of found articles with relevance scores
 * @usedBy news-monitor-agent
 */

export interface SearchNewsInput {
  company_name: string;
  ticker?: string;
  days_back?: number;   // default 7
  max_results?: number; // default 5
  tavily_api_key: string;
}

export interface SearchNewsResult {
  headline: string;
  summary: string;
  url: string;
  source: string;
  published_date?: string;
  score: number; // Tavily relevance score 0–1
}

export async function searchNews(
  input: SearchNewsInput
): Promise<SearchNewsResult[]> {
  if (!input.tavily_api_key) return [];

  const query = input.ticker
    ? `${input.company_name} ${input.ticker} negative news credit risk financial`
    : `${input.company_name} negative news financial risk`;

  try {
    const response = await fetch("https://api.tavily.com/search", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        api_key: input.tavily_api_key,
        query,
        search_depth: "basic",
        include_answer: false,
        include_raw_content: false,
        max_results: input.max_results ?? 5,
        days: input.days_back ?? 7,
        topic: "news",
      }),
    });

    if (!response.ok) return [];

    const data = await response.json();
    return (data.results ?? []).map((r: Record<string, unknown>) => ({
      headline: (r.title as string) ?? "",
      summary: (r.content as string) ?? "",
      url: (r.url as string) ?? "",
      source: extractDomain((r.url as string) ?? ""),
      published_date: r.published_date as string | undefined,
      score: (r.score as number) ?? 0,
    }));
  } catch {
    return [];
  }
}

function extractDomain(url: string): string {
  try {
    return new URL(url).hostname.replace(/^www\./, "");
  } catch {
    return url;
  }
}
