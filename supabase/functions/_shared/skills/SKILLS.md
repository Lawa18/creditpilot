# CreditPilot Skills

Reusable analytical, generative, and integration functions shared across all agents.
Skills are pure functions — no database access, no side effects, fully unit tested.

---

## Analytical Skills

### `calculate-credit-limit-proposal.ts`
**Purpose:** Proposes a revised credit limit once CIA has determined action is needed.
**Called by:** CIA agent (briefing mode, step 6b) — runs after `assess-composite-risk`
**Inputs:**
- `current_limit` — current credit limit in base currency
- `current_exposure` — current outstanding balance
- `days_over_90` — amount overdue more than 90 days
- `utilization_pct` — current balance as % of credit limit (0-100)
- `credit_score` — normalised 0-100 score (100=lowest risk), null if unavailable
- `is_strategic_account` — strategic accounts get 10pp more latitude on thresholds
- `on_time_rate` — payment on-time rate (0-1), from `analyse-payment-behaviour`

**Decision logic:**
- `highOverdue` = days_over_90 > credit_limit × 10% (relative threshold)
- Payment behaviour adjusts utilization thresholds: <50% on-time → -15pp, <70% → -10pp, <85% → -5pp
- Reduction factors: 25-50% depending on severity combination
- Minimum 25% reduction enforced for non-strategic accounts once triggered

**Outputs:** `proposed_limit`, `reduction_pct`, `action` (reduce/no_action), `rationale`
**Tests:** 13 tests — coverage includes relative overdue threshold, payment penalty bands, strategic account latitude, minimum reduction floor

---

### `assess-composite-risk.ts`
**Purpose:** Determines WHETHER a credit limit action is needed by combining all active signals. Runs before `calculate-credit-limit-proposal`.
**Called by:** CIA agent (briefing mode, step 6b)
**Inputs:**
- `utilization_pct` — current utilization (0-100)
- `credit_score` — normalised 0-100 score, null if unavailable
- `active_event_types` — list of active credit_event types for this customer
- `active_signal_severities` — severity of each active signal
- `agents_flagging` — which agents have flagged this customer
- `on_time_rate` — payment on-time rate (0-1), from `analyse-payment-behaviour`

**Decision logic:**
Base threshold: 75% utilization. Adjusted downward by active signals:
- GOING_CONCERN_WARNING: -15pp
- NEGATIVE_NEWS_HIGH/CRITICAL: -10pp
- COVENANT_WAIVER: -12pp
- CREDIT_RATING_DOWNGRADE: -10pp
- CEO_DEPARTURE: -5pp
- Credit score distress (<20): -15pp
- Credit score concern (20-40): -5pp
- Payment on-time <50%: -15pp, <70%: -10pp, <85%: -5pp
- Floor at 40%

Action recommended if: utilization >= adjusted threshold, OR distress score + active signals, OR 3+ agents flagging

Severity weighted by signal severity and agent count — not just agent count alone.

**Outputs:** `adjusted_threshold`, `recommend_action`, `severity`, `rationale`, `adjustments`
**Tests:** 13 tests — coverage includes all signal adjustments, payment penalty, severity weighting, multi-agent convergence

---

### `analyse-payment-behaviour.ts`
**Purpose:** Derives behavioural metrics from payment transaction history. Called by AR aging agent after every run — results written to customers table for CIA agent to read.
**Called by:** AR aging agent (writes to customers table) → CIA agent reads from customers table
**Inputs:**
- `PaymentTransaction[]` — payment records with date, days_to_pay, days_early_late, on_time flag, amount

**Key design decisions:**
- All metrics are amount-weighted — a $500K late payment counts more than a $5K late payment
- Empty/no history returns `health: 'unknown'` — new customers are unknown risk, not assumed healthy
- `at_risk` requires a deteriorating trend AND on_time_rate < 85% — consistently-late-but-stable payers (e.g. government entities) are `watch` not `at_risk`
- Trend threshold: 3+ days shift between first and second half of history = deteriorating

**Health classification:**
- `healthy` — on time rate acceptable, stable or improving trend
- `watch` — consistently late but stable, OR slight deterioration
- `at_risk` — deteriorating trend AND on_time_rate < 85%
- `unknown` — no payment history available

**Outputs:** `on_time_rate`, `avg_days_early_late`, `avg_days_to_pay`, `trend`, `recent_on_time_rate`, `health`, `total_transactions`

**Connection to other skills:**
- `on_time_rate` → fed into `assess-composite-risk` (adjusts utilization threshold)
- `on_time_rate` → fed into `calculate-credit-limit-proposal` (adjusts action thresholds)

**Tests:** 11 tests — empty input, amount weighting, always-late-stable vs deteriorating, trend threshold boundary

---
