# Agent Documentation

CreditPilot has four autonomous agents. Each is a Supabase Edge Function (TypeScript/Deno). They read from and write to a shared Postgres database. A human reviews AI-proposed actions before they take effect.

---

## AR Aging Agent (`ar-aging-agent`)

### What it does

Scans all customers for overdue AR buckets and high credit utilisation. For customers in the 61–90 day and 90+ day buckets it:

- Composes dunning letters (Claude-generated, staged 1–4 by severity)
- Composes Microsoft Teams alerts for accounts with >$100K over 90 days
- Proposes credit limit reductions for human approval

### Trigger

Manual (Run Agent button in the AR Aging page) or programmatic.

### Data sources

- `v_ar_aging_current` — current AR aging snapshot per customer
- `payment_transactions` — last 24 payments per customer (used by `analyse-payment-behaviour` skill)
- `credit_metrics` — Altman Z-score per customer

### Outputs

| Table | Event / Record type | Condition |
|-------|---------------------|-----------|
| `credit_events` | `OVERDUE_BUCKET_1_30`, `OVERDUE_BUCKET_31_60`, `OVERDUE_BUCKET_61_90`, `OVERDUE_BUCKET_OVER_90` | Customer has balance in that bucket |
| `credit_events` | `CRITICAL_UTILIZATION`, `HIGH_UTILIZATION` | Credit utilisation >95% or >80% |
| `credit_events` | `CONCENTRATION_RISK` | Customer represents >20% of total AR portfolio |
| `agent_messages` | `collection_reminder` (email, dunning letter) | Top 5 at-risk customers |
| `agent_messages` | `internal_alert` (Teams) | Accounts with >$100K over 90 days |
| `pending_actions` | `CREDIT_LIMIT_REDUCTION` | `calculateCreditLimitProposal` skill recommends a reduction |
| `agent_runs` | run audit record | Every execution |

### Severity logic

| Condition | Severity |
|-----------|---------|
| Balance in 90+ day bucket | critical |
| Balance in 61–90 day bucket | high |
| Balance in 31–60 day bucket | medium |
| Balance in 1–30 day bucket | low |

### Dunning stage logic

| Condition | Stage |
|-----------|-------|
| Over-90 bucket >$100K | 4 (legal demand) |
| Over-90 bucket >$50K | 3 (final notice) |
| Balance in 61–90 bucket | 2 (second reminder) |
| Other | 1 (first reminder) |

### Rate limit

60 minutes between completed/running runs.

### Demo mode

Returns a pre-baked run log (49 customers scanned, 19 conditions found, 5 messages, 3 actions). Resets `pending_actions` for the seed run to `pending` status.

---

## News Monitor Agent (`news-monitor-agent`)

### What it does

Runs a full live news pipeline for each customer:

1. Searches for negative news via Tavily (`search-news` skill, `TavilyProvider`)
2. Deduplicates articles by content fingerprint (`btoa(customer_id|headline|date)`) against `negative_news.content_fingerprint`
3. Classifies each new article with Claude Haiku (`classify-news` skill); falls back to keyword classifier if the API key is absent or the response is invalid
4. Skips articles with `confidence < 0.7`
5. Inserts qualifying articles into `negative_news`
6. For medium/high/critical severity: writes a `credit_events` row and composes a Microsoft Teams alert

If `TAVILY_API_KEY` is not set the agent falls back to legacy mode: reads existing unreviewed rows from `negative_news` and processes the top 5 critical/high items.

### Trigger

Manual (Run Agent button in the News Monitor page) or programmatic.

### Data sources

| Source | Description |
|--------|-------------|
| `customers` | All customers (max 10 per run) — company name, ticker |
| Tavily API | Live news search via `TAVILY_API_KEY` |
| Anthropic API | Article classification via `ANTHROPIC_API_KEY` (Claude Haiku) |
| `negative_news` | Fingerprint dedup check before insert |

### Outputs

| Table | Event / Record type | Condition |
|-------|---------------------|-----------|
| `negative_news` | New article row | Passes dedup + confidence threshold |
| `credit_events` | `NEGATIVE_NEWS_CRITICAL` | `severity = 'critical'` |
| `credit_events` | `NEGATIVE_NEWS_HIGH` | `severity = 'high'` |
| `credit_events` | `NEGATIVE_NEWS_MEDIUM` | `severity = 'medium'` |
| `agent_messages` | `news_alert` (Teams) | Medium/high/critical article; credit event successfully written |
| `agent_runs` | run audit record | Every execution |

### Deduplication

Two-layer approach:

1. **Pre-check**: query `negative_news` by `content_fingerprint` before calling classify — avoids wasting API credits on known articles.
2. **Safety net**: upsert with `ON CONFLICT (content_fingerprint) DO NOTHING` to handle race conditions.

Credit events have a separate daily dedup index (`credit_events_daily_dedup_idx`) — one event per customer per event type per calendar day from this agent.

### Confidence threshold

`CONFIDENCE_THRESHOLD = 0.7`. Articles below this are inserted into `negative_news` but skipped for credit events and alerts. The `classify-news` skill never applies the threshold internally — filtering is this agent's responsibility.

### Rate limit

60 minutes between completed/running runs.

### Demo mode

Returns a pre-baked run log (28 items scanned, 25 critical/high, 5 notifications). No rows are written.

---

## SEC Filing Monitor Agent (`sec-monitor-agent`)

### What it does

Monitors companies in the `sec_monitoring` table for active SEC filing alerts. Reads the `v_sec_monitoring_dashboard` view to find companies where `alert_triggered = true`. For each, it composes an email alert to the credit analysis team and writes a credit event.

### Trigger

Manual (Run Agent button in the SEC Filings page) or programmatic.

### Data sources

- `v_sec_monitoring_dashboard` — SEC monitoring status per company with alert flags
- `customers` — lookup customer_id by ticker

### Outputs

| Table | Event / Record type | Condition |
|-------|---------------------|-----------|
| `credit_events` | `GOING_CONCERN_WARNING` | `going_concern_warning` or `cash_runway_<3_quarters` in risk signals |
| `credit_events` | `COVENANT_WAIVER` | `covenant_waiver` in risk signals |
| `credit_events` | `CEO_DEPARTURE` | `CEO_departure` in risk signals |
| `credit_events` | `SEC_ALERT` | Other risk signals |
| `agent_messages` | `sec_alert` (email) | Every alerted company |
| `agent_runs` | run audit record | Every execution |

### Severity logic

| Risk signal | Severity |
|-------------|---------|
| Going concern warning, cash runway <3 quarters | critical |
| Covenant waiver, CEO departure | high |
| Other | medium |

### Rate limit

60 minutes between completed/running runs.

### Demo mode

Returns a pre-baked run log (3 filings monitored, 2 alerts, 2 notifications). No credit_events are written.

---

## Credit Intelligence Agent (`cia-agent`)

### What it does

Synthesises signals from all three monitoring agents into structured intelligence. Operates in three modes:

| Mode | Model | Purpose |
|------|-------|---------|
| `briefing` | Claude Opus (live) | Daily portfolio summary; processes unread `credit_events` |
| `question` | Claude Sonnet (live) / Claude Haiku (demo) | Answers a specific credit question with cited sources |
| `suggestions` | Claude Haiku (live) | Generates 4 relevant follow-up questions from recent events |

### Trigger

- `briefing`: Run CIA button in the Credit Events page
- `question`: Any question submitted via the CIA chat bar or `/cia?q=...` page
- `suggestions`: On first page load (cached in sessionStorage)

### Data sources (briefing mode)

- `credit_events` where `cia_processed = false` — up to 100 most recent
- `customers` — customer context (name, type, credit limit, balance)
- `agent_runs` — cache TTL check per agent

### Data sources (question mode)

- `credit_events` — keyword-filtered on `title` and `description` (up to 3 keywords, ilike); falls back to most recent 15 if <2 results

### Outputs (briefing mode)

| Table | Event / Record type | Condition |
|-------|---------------------|-----------|
| `credit_events` | `DAILY_BRIEFING` (scope: portfolio) | Every briefing run |
| `credit_events` | `COMPOSITE_RISK_CRITICAL` or `COMPOSITE_RISK_ELEVATED` | Customer flagged by ≥2 agents |
| `credit_events` | Source events updated: `cia_processed = true` | After processing |
| `agent_runs` | run audit record | Every execution |

### Question mode response shape

```json
{
  "answer": "Markdown-formatted analysis",
  "sources": [
    {
      "event_id": "uuid",
      "customer_name": "string",
      "event_type": "string",
      "severity": "critical|high|medium|low|info",
      "date": "ISO date string",
      "agent": "string"
    }
  ],
  "confidence": "High|Medium|Low",
  "confidence_reason": "One sentence"
}
```

### Cache TTL (briefing mode staleness check)

| Agent | TTL |
|-------|-----|
| ar-aging-agent | 24 hours |
| news-monitor-agent | 4 hours |
| sec-monitor-agent | 48 hours |

### Demo mode

- `briefing`: Returns `DEMO_BRIEFING` (hardcoded markdown). Upserts a seed run record.
- `question`: Calls Claude Haiku with real credit_events from the database.
- `suggestions`: Returns `DEMO_SUGGESTIONS` (4 hardcoded questions).

---

## Event taxonomy

All `credit_events` rows share these fields relevant to filtering and display:

| Field | Description |
|-------|-------------|
| `event_type` | SCREAMING_SNAKE_CASE signal identifier (see tables above) |
| `source_agent` | `ar_aging_agent`, `news_monitor_agent`, `sec_monitor_agent`, `cia-agent` |
| `severity` | `critical`, `high`, `medium`, `low`, `info` |
| `signal_type` | `AR_AGING`, `NEGATIVE_NEWS`, `SEC_FILING`, `CONCENTRATION`, `CIA_ASSESSMENT` |
| `scope` | `customer` or `portfolio` |
| `cia_processed` | `false` until CIA has synthesised the event |
| `is_demo` | `true` for seed data; `false` for live data |
| `action_required` | `true` if the event requires a human decision |
| `action_type` | `CREDIT_LIMIT_REDUCTION`, `CREDIT_LIMIT_REVIEW`, etc. |
