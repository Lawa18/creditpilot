# My Credit Pilot — Production Agents

Three autonomous credit risk monitoring agents that fetch real data from external APIs, analyze it with AI, and store actionable results in your Supabase database.

## Agents

| Agent | Data Source | What It Does |
|-------|-----------|-------------|
| **News Monitor** | [NewsAPI](https://newsapi.org) | Searches for negative news about your customers, runs AI sentiment analysis, composes internal alerts |
| **AR Aging** | Your ERP (QuickBooks, NetSuite, SAP, or generic REST API) | Fetches AR aging data, stores snapshots, identifies at-risk customers, proposes credit limit changes |
| **SEC Monitor** | [SEC EDGAR](https://www.sec.gov/edgar) (free, no API key) | Fetches real SEC filings, runs AI risk analysis, detects risk signals, composes alerts |

## Quick Start

### 1. Set Up Supabase

Create a [Supabase](https://supabase.com) project and run the database schema migration from the main My Credit Pilot project. You'll need these tables:

- `customers` — Your customer portfolio
- `agent_runs` — Agent execution logs
- `agent_messages` — Composed notifications
- `pending_actions` — Actions awaiting human approval
- `negative_news` — News items (News Monitor)
- `ar_aging_snapshots` — AR aging data (AR Aging)
- `sec_filings` — SEC filing records (SEC Monitor)
- `sec_monitoring` — SEC monitoring config per customer (SEC Monitor)

### 2. Configure Secrets

```bash
# Required for all agents
supabase secrets set SUPABASE_URL=https://YOUR_PROJECT.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# News Monitor Agent
supabase secrets set NEWS_API_KEY=your-newsapi-key  # from https://newsapi.org

# AR Aging Agent
supabase secrets set ERP_API_URL=https://your-erp-api.com
supabase secrets set ERP_API_KEY=your-erp-api-key
supabase secrets set ERP_PROVIDER=generic  # or "quickbooks", "netsuite", "sap"

# SEC Monitor Agent (EDGAR is free — no key needed)
supabase secrets set SEC_USER_AGENT="YourCompany admin@yourcompany.com"

# AI Analysis (optional but recommended — powers risk scoring)
supabase secrets set LOVABLE_API_KEY=your-lovable-api-key
```

### 3. Update Config

Edit `supabase/config.toml` and set your project ID:

```toml
project_id = "your-supabase-project-id"
```

### 4. Deploy

```bash
supabase functions deploy ar-aging-agent
supabase functions deploy news-monitor-agent
supabase functions deploy sec-monitor-agent
```

### 5. Test

```bash
# Invoke manually
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/news-monitor-agent \
  -H "Content-Type: application/json" \
  -d '{"triggered_by": "manual"}'
```

## ERP Integration (AR Aging Agent)

### Generic REST API

If you use `ERP_PROVIDER=generic`, your API should expose:

```
GET /ar-aging
→ {
    "customers": [
      {
        "customer_id": "ext-123",
        "company_name": "Acme Corp",
        "ticker": "ACME",
        "current": 50000,
        "days_1_30": 25000,
        "days_31_60": 10000,
        "days_61_90": 5000,
        "days_over_90": 2000,
        "total_ar": 92000,
        "credit_limit": 150000,
        "dso": 45
      }
    ]
  }
```

### QuickBooks

Set `ERP_PROVIDER=quickbooks` and configure `ERP_API_URL` to your QuickBooks API base URL. The agent will call the `AgedReceivableDetail` report endpoint.

### Adding Custom ERP Adapters

Edit `ar-aging-agent/index.ts` and add a new case to the `fetchErpData` switch statement:

```typescript
case "your_erp":
  return fetchYourErpAging(apiUrl, apiKey);
```

## SEC EDGAR Setup

The SEC Monitor uses the free EDGAR API. To monitor a customer:

1. Find the company's CIK number at [SEC EDGAR](https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany)
2. Add a row to the `sec_monitoring` table with `customer_id` and `cik`

**Important:** SEC requires a `User-Agent` header with your name and email. Set this via the `SEC_USER_AGENT` secret.

## Scheduling

Set up a cron job or Supabase scheduled function to run agents automatically:

```sql
-- Example: Run news monitor daily at 8 AM UTC
select cron.schedule(
  'news-monitor-daily',
  '0 8 * * *',
  $$
  select net.http_post(
    url := 'https://YOUR_PROJECT.supabase.co/functions/v1/news-monitor-agent',
    body := '{"triggered_by": "cron"}'::jsonb
  );
  $$
);
```

## Rate Limits

All agents have a built-in 60-minute cooldown between runs. The SEC Monitor also has a total AI run cap (200 by default) to control costs.

## Architecture

```
External APIs          → Edge Functions → Supabase DB → My Credit Pilot UI
━━━━━━━━━━━━━━           ━━━━━━━━━━━━     ━━━━━━━━━━     ━━━━━━━━━━━━━━━━
NewsAPI                  news-monitor     negative_news   Dashboard
SEC EDGAR                sec-monitor      sec_filings     Activity Feed
Your ERP                 ar-aging         ar_snapshots    Agent Observer
Lovable AI (optional)                     agent_runs
                                          agent_messages
                                          pending_actions
```

## License

MIT
