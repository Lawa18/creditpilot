/**
 * @skill search-news
 * @type integration
 * @description Provider-agnostic news search with deduplication support.
 *   Searches for recent negative news about a company using one or more
 *   provider implementations. Results are deduplicated by URL, sorted by
 *   relevance score descending, and normalised to a common RawArticle shape.
 *   Returns [] on complete failure — never throws.
 *
 *   Also exports generateFingerprint for stable deduplication keys used in
 *   the negative_news.content_fingerprint column.
 *
 * @input { company_name, ticker?, days_back?, max_results?, providers: NewsProvider[] }
 * @output RawArticle[] — deduplicated, sorted by relevance_score desc
 * @usedBy news-monitor-agent
 */

// ─── Types ────────────────────────────────────────────────────────────────────

/** Provider-agnostic raw article shape */
export interface RawArticle {
  headline: string;
  summary: string;
  url: string;
  source: string;
  published_date?: string;
  relevance_score: number; // 0–1, normalised from provider
  provider: string;        // 'tavily' | 'google_news' | 'manual'
}

/** Provider interface — implement this to add new search providers */
export interface NewsProvider {
  name: string;
  search(
    companyName: string,
    ticker?: string,
    daysBack?: number,
    maxResults?: number
  ): Promise<RawArticle[]>;
}

// ─── Fingerprint ──────────────────────────────────────────────────────────────

/**
 * Generates a deterministic deduplication fingerprint for a news article.
 * Same article always produces the same key regardless of which provider found it.
 * Stored in negative_news.content_fingerprint and used for ON CONFLICT checks.
 */
export function generateFingerprint(
  customerId: string,
  headline: string,
  date: string
): string {
  const raw = `${customerId}|${headline.toLowerCase().trim()}|${date}`;
  try {
    return btoa(raw);
  } catch {
    // btoa fails on non-Latin characters — fall back to a simple deterministic hash
    let h = 0;
    for (let i = 0; i < raw.length; i++) {
      h = (Math.imul(31, h) + raw.charCodeAt(i)) | 0;
    }
    return `fp_${Math.abs(h).toString(36)}`;
  }
}

// ─── Tavily provider ──────────────────────────────────────────────────────────

export class TavilyProvider implements NewsProvider {
  readonly name = "tavily";

  constructor(private readonly apiKey: string) {}

  async search(
    companyName: string,
    ticker?: string,
    daysBack = 7,
    maxResults = 5
  ): Promise<RawArticle[]> {
    if (!this.apiKey) return [];

    const query = ticker
      ? `${companyName} ${ticker} negative news credit risk financial`
      : `${companyName} negative news financial risk`;

    try {
      const response = await fetch("https://api.tavily.com/search", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          api_key: this.apiKey,
          query,
          search_depth: "basic",
          include_answer: false,
          include_raw_content: false,
          max_results: maxResults,
          days: daysBack,
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
        relevance_score: (r.score as number) ?? 0,
        provider: "tavily",
      }));
    } catch {
      return [];
    }
  }
}

// ─── Main search function ─────────────────────────────────────────────────────

/**
 * Searches for news using all provided providers in parallel.
 * Deduplicates by URL, sorts by relevance_score descending.
 * Returns [] if all providers fail.
 */
export async function searchNews(input: {
  company_name: string;
  ticker?: string;
  days_back?: number;
  max_results?: number;
  providers: NewsProvider[];
}): Promise<RawArticle[]> {
  if (!input.providers || input.providers.length === 0) return [];

  const settled = await Promise.allSettled(
    input.providers.map((p) =>
      p.search(
        input.company_name,
        input.ticker,
        input.days_back,
        input.max_results
      )
    )
  );

  const all: RawArticle[] = [];
  for (const result of settled) {
    if (result.status === "fulfilled") {
      all.push(...result.value);
    }
  }

  // Deduplicate by URL
  const seen = new Set<string>();
  const deduped = all.filter((a) => {
    if (!a.url || seen.has(a.url)) return false;
    seen.add(a.url);
    return true;
  });

  // Sort by relevance score descending
  return deduped.sort((a, b) => b.relevance_score - a.relevance_score);
}

// ─── Internal helpers ─────────────────────────────────────────────────────────

function extractDomain(url: string): string {
  try {
    return new URL(url).hostname.replace(/^www\./, "");
  } catch {
    return url;
  }
}
