# CreditPilot

Open-source autonomous AI agents for B2B trade credit management.

---

## What is CreditPilot?

CreditPilot is a set of four autonomous AI agents that automate the routine work of a B2B credit analyst: monitoring overdue accounts receivable, scanning for negative news, watching SEC filings for distress signals, and synthesising all signals into a daily credit intelligence briefing.

Agents run against your AR and customer data, write their findings to a Postgres database, and surface them through a React dashboard. A human reviews AI-proposed actions (credit limit reductions, credit holds) before they take effect. Nothing changes without approval.

A live demo is available at [creditpilot.vercel.app](https://creditpilot.vercel.app) — a fictional $500M specialty alloys distributor with 49 customers across seven credit scenarios. No signup required.

---

## Architecture

```
React / Vite frontend  →  Supabase Edge Functions (Deno)
                       →  Supabase Postgres
                       →  Anthropic Claude API
```

Agents are Supabase Edge Functions written in TypeScript/Deno. They read from and write to a shared Postgres database. The frontend is a Vite/React SPA that queries Postgres directly via the Supabase client. There is no separate API server.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full system diagram and event-driven design.

---

## Agents

### AR Aging Agent (`ar-aging-agent`)
Pure signal agent — scans AR data for overdue buckets, utilization, and concentration risk. Writes `credit_events` only. Composes dunning letters (Claude-generated, staged 1–4 by severity) and Teams alerts.

### News Monitor Agent (`news-monitor-agent`)
Fetches live news via the Tavily API, classifies severity using Claude Haiku with strict JSON schema and confidence scoring, deduplicates by content fingerprint, and writes to negative_news and credit_events. Falls back to processing existing unreviewed rows if no Tavily API key is set.

### SEC Filing Monitor Agent (`sec-monitor-agent`)
Fetches live filings from the SEC EDGAR API (free, no API key required). Detects risk signals via keyword matching across 15 signal types. Deduplicates by accession number. Composes email alerts to the credit analysis team via `deliver-message.ts`.

### Credit Intelligence Agent (`cia-agent`)
Synthesises signals from all three monitoring agents into structured intelligence. Operates in three modes: `briefing` (daily portfolio summary, calls Claude Opus), `question` (answers a specific credit question with cited sources, calls Claude Sonnet), and `suggestions` (generates relevant follow-up questions, calls Claude Haiku). Writes `DAILY_BRIEFING` and `COMPOSITE_RISK` events back to `credit_events` and marks source events as processed. Owns all credit limit decisioning — runs `assessCompositeRisk` and `calculateCreditLimitProposal` skills, writes `pending_actions`.

See [docs/AGENTS.md](docs/AGENTS.md) for full agent documentation including event taxonomies.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18, Vite, TypeScript, Tailwind CSS, shadcn/ui |
| Routing | React Router v6 |
| Data fetching | TanStack Query (React Query) |
| Backend | Supabase Edge Functions (Deno) |
| Database | Supabase Postgres (PostgREST) |
| AI | Anthropic Claude API (Opus, Sonnet, Haiku) |
| Deployment | Vercel (frontend), Supabase (database + functions) |

---

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org) 18+
- [Supabase CLI](https://supabase.com/docs/guides/cli) — `npm install -g supabase`
- A Supabase project ([supabase.com](https://supabase.com), free tier works)
- An [Anthropic API key](https://console.anthropic.com)

### 1. Clone and install

```bash
git clone https://github.com/Lawa18/Creditpilot.git
cd Creditpilot
npm install
```

### 2. Configure environment variables

```bash
cp .env.example .env
```

Edit `.env` with your Supabase project URL and anon key (Settings → API in the Supabase dashboard).

### 3. Apply the database schema

```bash
supabase login
supabase link --project-ref your-project-ref
supabase db push
```

This runs all migrations in `supabase/migrations/` in order, creating the full schema and seeding the demo data.

### 4. Set Supabase function secrets

In the Supabase dashboard → Edge Functions → Manage secrets, add:

```
ANTHROPIC_API_KEY = sk-ant-...
DEMO_MODE         = true
```

### 5. Deploy the edge functions

```bash
supabase functions deploy ar-aging-agent
supabase functions deploy news-monitor-agent
supabase functions deploy sec-monitor-agent
supabase functions deploy cia-agent
```

### 6. Run the frontend

```bash
npm run dev
```

Open [http://localhost:5173](http://localhost:5173). With `DEMO_MODE=true` the demo data loads automatically on first page visit.

---

## Environment Variables

### Frontend (`.env`)

| Variable | Required | Description |
|----------|----------|-------------|
| `VITE_SUPABASE_URL` | Yes | Your Supabase project URL (e.g. `https://xxx.supabase.co`) |
| `VITE_SUPABASE_PUBLISHABLE_KEY` | Yes | Your Supabase anon/public key |
| `VITE_DEMO_MODE` | Yes | `true` to use seed data, `false` for live data |

### Supabase Function Secrets

Set these in the Supabase dashboard → Edge Functions → Manage secrets:

| Variable | Required | Description |
|----------|----------|-------------|
| `ANTHROPIC_API_KEY` | Yes (live mode) | Anthropic API key for Claude calls |
| `DEMO_MODE` | Yes | `true` replays seed data without API calls (except CIA question mode) |
| `SUPABASE_URL` | Auto | Set automatically by Supabase |
| `SUPABASE_SERVICE_ROLE_KEY` | Auto | Set automatically by Supabase |
| `CREDIT_TEAM_EMAIL` | No | Recipient for SEC alert emails (defaults to `credit-team@company.com`) |
| `SENDGRID_API_KEY` | No | Enables email delivery via SendGrid |
| `TEAMS_WEBHOOK_URL` | No | Enables Teams delivery via incoming webhook |
| `SLACK_WEBHOOK_URL` | No | Enables Slack delivery via incoming webhook |

No delivery keys are needed for demo mode — `LogProvider` fallback logs all messages to the console.

---

## Database

The schema is defined across SQL migration files in `supabase/migrations/`. Key tables:

| Table | Purpose |
|-------|---------|
| `customers` | Portfolio of monitored counterparties with credit limits |
| `credit_events` | Central event log — all agents write here |
| `agent_messages` | Composed communications (dunning letters, Teams alerts) |
| `pending_actions` | AI-proposed actions awaiting human approval |
| `agent_runs` | Audit log of every agent execution |
| `negative_news` | News items for the news monitor agent to process |
| `sec_monitoring` | Companies being watched for SEC filing alerts |

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for schema details and relationships.

---

## Demo Mode

When `DEMO_MODE=true`, agents run against pre-seeded fictional data without burning API tokens or touching real customer data. A Reset Demo button in the Actions page restores all tables to their seed state and re-runs the agents.

All demo rows are tagged with `is_demo = true`. This column exists on `credit_events`, `agent_messages`, `pending_actions`, `negative_news`, and `sec_monitoring` — queries filter by it so demo and production data never mix.

See [docs/DEMO_MODE.md](docs/DEMO_MODE.md) for the full explanation.

---

## Deployment

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for full deployment instructions including Vercel configuration, Supabase project setup, and promoting from demo to production.

---

## Project Structure

```
creditpilot/
├── src/
│   ├── components/
│   │   ├── AppSidebar.tsx         # Navigation sidebar with agent run status badges
│   │   ├── CIAChat.tsx            # CIA launcher bar — bottom of every page
│   │   ├── AgentPill.tsx          # Colored pill showing which agent produced an event
│   │   ├── SeverityBadge.tsx      # Critical/high/medium/low severity indicator
│   │   ├── SkeletonCard.tsx       # Loading skeleton components
│   │   └── ui/                    # shadcn/ui component library (do not edit)
│   ├── hooks/
│   │   └── useCIA.ts              # Hook for CIA agent — suggestions, questions, briefings
│   ├── lib/
│   │   ├── constants.ts           # DEMO_MODE flag, agent config
│   │   ├── format.ts              # Currency and date formatting
│   │   ├── initDemo.ts            # Demo reset logic — shared by Reset button and auto-init
│   │   └── utils.ts               # Tailwind class merging (cn utility)
│   ├── pages/
│   │   ├── CreditEvents.tsx       # Default landing page — unified signal log
│   │   ├── Actions.tsx            # Pending and completed human approvals
│   │   ├── ArAging.tsx            # AR aging dashboard
│   │   ├── NewsMonitor.tsx        # Negative news alert feed
│   │   ├── SecFilings.tsx         # SEC filing monitoring with EDGAR links
│   │   ├── Customers.tsx          # Customer directory with credit metrics
│   │   └── CIA.tsx                # Perplexity-style CIA answer page (/cia?q=...)
│   └── App.tsx                    # Route definitions, SidebarLayout, demo auto-init
├── supabase/
│   ├── functions/
│   │   ├── _shared/
│   │   │   └── skills/            # Reusable skill functions
│   │   │       ├── analytical/    # analyse-payment-behaviour, calculate-credit-limit-proposal,
│   │   │       │                  #   assess-composite-risk, aggregate-credit-scores,
│   │   │       │                  #   detect-rating-change, calculate-altman-z, parse-ar-csv
│   │   │       ├── integration/   # fetch-sec-filing, deliver-message, fetch-credit-score
│   │   │       └── generative/    # compose-dunning-letter, compose-teams-alert
│   │   ├── ar-aging-agent/        # AR Aging monitoring agent
│   │   ├── ar-csv-upload/         # CSV ingestion endpoint for AR data
│   │   ├── news-monitor-agent/    # Negative news monitoring agent
│   │   ├── sec-monitor-agent/     # SEC filing monitoring agent
│   │   └── cia-agent/             # Credit Intelligence Agent (synthesis + Q&A)
│   └── migrations/                # SQL migration files (schema + seed data)
├── .env.example                   # Frontend env var template
├── CONTRIBUTING.md
└── README.md
```

---

## Testing

The skill layer has **152 unit tests** across 11 test files:

```bash
npx vitest run supabase/functions/_shared/skills
```

Tests cover: `normalise-credit-signal` (42), `aggregate-credit-scores` (15), `detect-rating-change` (14), `classify-news` (12), `assess-composite-risk` (9), `calculate-credit-limit-proposal` (9), `calculate-altman-z` (9), `analyse-payment-behaviour` (7), `parse-ar-csv` (8), `fetch-sec-filing` (5), `deliver-message` (5).

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, branch conventions, how to add a new agent, and the PR checklist.

---

## Security

The demo uses intentionally open RLS policies so anyone can interact with the demo data. **Before loading real company data:**

1. Remove anon write policies from `pending_actions`, `customers`, `credit_actions`
2. Add authentication (Supabase Auth)
3. Use a dedicated Supabase project — not the same one as the demo

---

## License

MIT — use it, fork it, build on it.

---

## About

Built by Lars Wallin — Head of Financial Institutions at Coface, one of the world's largest trade credit insurance companies. This project applies domain expertise from trade credit insurance to autonomous AI agents for B2B credit managers.

Connect on [LinkedIn](https://www.linkedin.com/in/larsewallin/).

The demo company and all 49 customer accounts are entirely fictional.
