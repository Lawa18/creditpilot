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
