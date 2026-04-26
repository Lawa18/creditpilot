# Architecture

## System overview

```
Browser (React / Vite)
    │
    │  PostgREST (direct table queries)
    ▼
Supabase Postgres ◄──────────────────────────────┐
    │                                             │
    │  supabase.functions.invoke(...)             │ writes
    ▼                                             │
Supabase Edge Functions (Deno)                   │
    ├── ar-aging-agent   ──► Anthropic Claude API │
    ├── news-monitor-agent                        │
    ├── sec-monitor-agent                         │
    └── cia-agent        ──► Anthropic Claude API ┘
```

There is no separate API server. The React frontend queries Postgres directly via the Supabase client (PostgREST). Agents are invoked by the frontend via `supabase.functions.invoke` and write their results to shared Postgres tables.

---

## Frontend

Built with React 18, Vite, TypeScript, Tailwind CSS, and shadcn/ui. Routing is React Router v6. Data fetching uses TanStack Query (React Query).

The frontend is deployed to Vercel. It connects to Supabase via two environment variables: `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY`.

### Key pages

| Route | File | Purpose |
|-------|------|---------|
| `/events` | `CreditEvents.tsx` | Central signal log — default landing page |
| `/actions` | `Actions.tsx` | Pending and completed human approvals |
| `/aging` | `ArAging.tsx` | AR aging dashboard |
| `/news` | `NewsMonitor.tsx` | Negative news alert feed |
| `/sec` | `SecFilings.tsx` | SEC filing monitoring with EDGAR links |
| `/customers` | `Customers.tsx` | Customer directory with credit metrics |
| `/cia` | `CIA.tsx` | Perplexity-style CIA answer page |

### Key components

- **`AppSidebar.tsx`** — Navigation sidebar with live agent run status badges
- **`CIAChat.tsx`** — Fixed bottom bar; fetches AI-generated question suggestions; navigates to `/cia?q=...` on submit
- **`AgentPill.tsx`** — Coloured pill showing which agent produced an event
- **`SeverityBadge.tsx`** — Critical / high / medium / low indicator

### Key hooks and utilities

- **`useCIA.ts`** — Hook exposing `askQuestion`, `runBriefing`, `fetchSuggestions`, `clearMessages`
- **`lib/initDemo.ts`** — Demo reset logic; invoked on first page load and by the Reset Demo button
- **`lib/constants.ts`** — `DEMO_MODE` flag derived from `import.meta.env.VITE_DEMO_MODE`

---

## Edge functions

All four agents are Supabase Edge Functions written in TypeScript/Deno. They share a common pattern:

1. **OPTIONS preflight** — return CORS headers immediately.
2. **DEMO_MODE check** — if `Deno.env.get("DEMO_MODE") === "true"`, return seed data and exit. No API calls.
3. **Rate limit** — reject requests if a completed/running run exists within the past 60 minutes (HTTP 429).
4. **Insert `agent_runs` row** — status `running`.
5. **Read from Postgres** — fetch the data this agent monitors.
6. **Process and write** — insert rows to `credit_events`, `agent_messages`, `pending_actions`.
7. **Update `agent_runs`** — status `completed` or `failed`.

### Shared skills

Reusable logic in `supabase/functions/_shared/skills/`:

| Skill | Type | Purpose |
|-------|------|---------|
| `analyse-payment-behaviour` | Analytical | Calculates on-time rate, DSO, payment health score from transaction history |
| `calculate-credit-limit-proposal` | Analytical | Determines whether to reduce a credit limit and by how much |
| `compose-dunning-letter` | Generative | Calls Claude to draft a staged (1–4) dunning letter |
| `compose-teams-alert` | Generative | Composes a Microsoft Teams adaptive card alert |

---

## Database

Supabase Postgres. Schema defined in `supabase/migrations/` (14 files). PostgREST is used for all frontend queries.

### Core tables

| Table | Purpose |
|-------|---------|
| `customers` | Portfolio of monitored counterparties with credit limits |
| `credit_events` | Central event log — all agents write here |
| `agent_messages` | Composed communications (dunning letters, Teams alerts, email) |
| `pending_actions` | AI-proposed actions awaiting human approval |
| `agent_runs` | Audit log of every agent execution |
| `negative_news` | News items for the News Monitor Agent to process |
| `sec_monitoring` | Companies being watched for SEC filing alerts |
| `credit_metrics` | Altman Z-score and other financial metrics per customer |
| `payment_transactions` | Payment history used by the AR Aging Agent |

### Key views

| View | Purpose |
|------|---------|
| `v_ar_aging_current` | AR aging buckets per customer (current snapshot) |
| `v_sec_monitoring_dashboard` | SEC monitoring status with alert flags per company |

### Demo data isolation

All demo rows are tagged with `is_demo = true`. This column exists on `credit_events`, `agent_messages`, and `pending_actions`. Queries that mix demo and live modes filter by this column.

---

## Event flow

```
User clicks "Run Agent"
    │
    ▼
Frontend calls supabase.functions.invoke('ar-aging-agent', ...)
    │
    ▼
ar-aging-agent reads v_ar_aging_current + payment_transactions
    │
    ├──► writes credit_events (OVERDUE_BUCKET_*, CONCENTRATION_RISK)
    ├──► writes agent_messages (dunning letters, Teams alerts)
    └──► writes pending_actions (CREDIT_LIMIT_REDUCTION proposals)
    │
    ▼
Frontend calls supabase.functions.invoke('cia-agent', {mode:'briefing'})
    │
    ▼
cia-agent reads credit_events where cia_processed = false
    │
    ├──► calls Claude Opus (live) or returns DEMO_BRIEFING
    ├──► writes DAILY_BRIEFING event
    ├──► writes COMPOSITE_RISK events for multi-signal customers
    └──► marks source events cia_processed = true
    │
    ▼
Frontend queries credit_events, pending_actions, agent_messages
and renders results in the React dashboard
```

---

## Auth and security

The demo uses open RLS policies so anyone can interact with the demo data without signing in. Before loading real company data:

1. Remove anon write policies from `pending_actions`, `customers`, `credit_events`.
2. Add Supabase Auth.
3. Use a dedicated Supabase project — not the demo project.

See the Security section in `README.md` for full guidance.
