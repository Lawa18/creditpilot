# CreditPilot — AI Agents for Trade Credit Management

CreditPilot is an open-source set of autonomous AI agents that automate the day-to-day work of B2B credit management — dunning letters, news monitoring, SEC filing alerts, credit limit reviews, and more.

I built this over a weekend to explore what's possible when you apply modern AI agents to trade credit — a domain that has been largely untouched by automation compared to consumer finance.

**Try the live demo →** https://mycreditpilot.lovable.app
A fictional $500M specialty alloys distributor with 49 customers across 7 credit scenarios — bankruptcies, payment issues, credit deterioration, negative news. Run the agents yourself. No signup required.

**Deploy it yourself →** https://github.com/Lawa18/Creditpilot
The agents connect to your own ERP or AR data instead of the demo company. Straightforward to deploy locally. Four environment variables and you're running.

---

## What it does

Three agents run against your accounts receivable portfolio:

| Agent | What it monitors | What it does |
|-------|-----------------|-------------|
| **AR Aging** | Overdue invoices | Sends dunning letters (stages 1–4), proposes credit limit reductions for 60+ day accounts, proposes credit holds for 90+ day accounts |
| **News Monitor** | Web news via Tavily | Finds negative news about customers, classifies severity with Claude, sends internal alerts, proposes credit reviews for high/critical findings |
| **SEC Filing Monitor** | EDGAR filings | Monitors 10-K/10-Q/8-K for going concern warnings, covenant breaches, management changes |

Agents write their findings and composed messages to a Supabase database. A web UI shows what the agents found, renders the messages they composed, and lets a human approve or reject proposed actions.

No email provider required. No Teams webhook required. Messages are stored in the database and shown in the UI — external delivery is optional.

---

## Quick start

### Prerequisites
- [Supabase](https://supabase.com) account (free tier works)
- [Anthropic API key](https://console.anthropic.com) — for news agent classification
- [Tavily API key](https://tavily.com) — for news agent web search (1,000 searches/month free)

### 1. Create a Supabase project
Go to supabase.com → New project. Note your project URL and anon key from Settings → API.

### 2. Apply the schema
In Supabase → SQL Editor, run schema.sql in full.

### 3. Load demo data
Run seed.sql in Supabase SQL Editor to load the demo company — Global Trading Solutions Inc, a fictional $500M specialty alloys distributor with 49 customers across 7 credit scenarios.

### 4. Deploy the agents
In Supabase dashboard → Edge Functions → New Function:
- Create function named ar-aging-agent, paste contents of supabase/functions/ar-aging-agent/index.ts, deploy
- Create function named news-monitor-agent, paste contents of supabase/functions/news-monitor-agent/index.ts, deploy

### 5. Set environment variables
In Supabase → Edge Functions → Manage secrets:
ANTHROPIC_API_KEY   = sk-ant-...
TAVILY_API_KEY      = tvly-...

### 6. Run the UI
```bash
cd ui
npm install
cp .env.example .env
# Add your VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY
npm run dev
```

---

## Repository structure
creditpilot/
├── schema.sql                          # Full database schema
├── seed.sql                            # Demo company data (49 customers)
├── migration_001.sql                   # Agent infrastructure tables
├── migration_002.sql                   # Agent 4-8 tables
│
├── supabase/
│   └── functions/
│       ├── _shared/                    # Shared utilities
│       ├── ar-aging-agent/             # AR Aging Agent
│       └── news-monitor-agent/         # News Monitor Agent
│
└── src/                                # React UI (built with Lovable)
    ├── pages/
    │   ├── ActivityFeed.tsx
    │   ├── NewsMonitor.tsx
    │   ├── ARaging.tsx
    │   ├── SECFilings.tsx
    │   ├── Customers.tsx
    │   └── Demo.tsx
    └── components/

---

## Agent roster — current and planned

| # | Agent | Status | What it does |
|---|-------|--------|-------------|
| 1 | AR Aging | ✅ Built | Dunning letters, credit limit proposals, credit holds |
| 2 | News Monitor | ✅ Built | Web news search, Claude classification, credit alerts |
| 3 | SEC Filing Monitor | ✅ Built | EDGAR filing alerts, risk signal detection |
| 4 | Trade Reference | 🔜 Planned | Automates outbound credit reference letters |
| 5 | Payment Behaviour Monitor | 🔜 Planned | Detects deterioration before invoices go overdue |
| 6 | Credit Limit Review | 🔜 Planned | Stale limit detection, increase/decrease proposals |
| 7 | Bankruptcy & Distress Monitor | 🔜 Planned | Court filings, claim deadlines, recovery tracking |
| 8 | Onboarding & Credit Scoring | 🔜 Planned | Initial credit memo, limit proposal, risk rating |

---

## Skills

Agents are built from reusable skills — composable functions that do one thing well. Skills live in supabase/functions/_shared/skills/ and are called by multiple agents.

With a poor prompt you get a poor response. With poor skills you get poor agents. The quality of your agents is a direct reflection of the domain expertise encoded in their skills.

Current skills embedded in agents (extraction in progress):
- analyse-payment-behaviour
- calculate-credit-limit-proposal
- compose-dunning-letter
- compose-teams-alert
- classify-news
- search-news

---

## Environment variables
In Supabase secrets (for the agents):
ANTHROPIC_API_KEY=sk-ant-...
TAVILY_API_KEY=tvly-...
In the UI .env file (for the frontend):
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...

---

## Security

### For the public demo (fictional data)
The demo page at /demo is intentionally public and unauthenticated. Anyone can run agents, approve/reject pending actions, and reset the demo. This is by design.

### Before loading real company data
1. Remove anon write policies from pending_actions, customers, credit_actions
2. Add authentication to the main UI (Supabase Auth)
3. Use a dedicated Supabase project — not the same one as the demo
4. Upgrade from Supabase free tier (free tier pauses after 1 week of inactivity)

---

## Contributing

Agents follow a consistent pattern. To add a new agent:
1. Create supabase/functions/your-agent-name/index.ts
2. Create an agent_runs record at the start
3. Write findings to the appropriate table
4. Write messages to agent_messages
5. Write proposed actions to pending_actions
6. Update agent_runs with stats and summary at the end
7. Add a Run button on the /demo page

To contribute a skill, add it to supabase/functions/_shared/skills/ following the skill contract in CONTRIBUTING.md.

---

## License

MIT — use it, fork it, build on it.

---

## About

Built by Lars Wallin — Head of Financial Institutions at Coface, one of the world's largest trade credit insurance companies. This project applies that domain expertise to autonomous AI agents for B2B credit managers.

Connect on LinkedIn: https://www.linkedin.com/in/larsewallin/

The demo company (Global Trading Solutions Inc) and all 49 customer accounts are entirely fictional.
