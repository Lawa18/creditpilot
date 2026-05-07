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

### `aggregate-credit-scores.ts`
**Purpose:** Combines multiple credit signals from different providers into one authoritative 0-100 score. Simple average — no provider weighting, keeping it transparent and auditable.
**Called by:** CIA agent (question and briefing modes — credit context for customers)
**Inputs:**
- `CreditSignal[]` — any mix of providers (S&P, Coface, D&B, Experian, internal etc)

**Key design decisions:**
- No provider weighting — simple average. Every rating source treated equally to keep the score transparent and auditable.
- Empty input returns `final_score: null`, `interpretation: 'NR'` (No Rating) — never assumes a score of 50 for unrated customers
- `source_providers[]` field makes it clear which providers contributed to the score
- Frontend shows 'NR' and 'Provider: N/A' for unrated customers — never shows a dash that looks like missing data

**Interpretation bands:**
- very_safe ≥80, safe ≥60, watch ≥40, concern ≥20, high_risk <20, NR = no data

**Outputs:** `final_score` (0-100 or null), `interpretation`, `source_count`, `source_providers[]`, `sources[]`
**Connection to other skills:** calls `normalise-credit-signal` internally for each signal
**Tests:** 15 tests — NR for empty, simple average verification, source_providers accuracy

---

### `detect-rating-change.ts`
**Purpose:** Detects meaningful credit rating upgrades and downgrades by comparing current normalised score to previous score. Returns null if change is not significant.
**Called by:** CIA agent (planned — should fire when a new credit score is received)
**Inputs:**
- `previousScore: number` — prior normalised score (0-100)
- `currentScore: number` — new normalised score (0-100)

**Downgrade severity thresholds (absolute delta):**
- ≥30 points → critical
- ≥20 points → high
- ≥10 points → medium
- ≥5 points → low
- <5 points → no significant change (returns null type)

**Key design decisions:**
- Upgrades return severity 'info' and action_required=false — informational only
- Downgrades ≥10 points set action_required=true
- <5 point changes ignored — normal score fluctuation

**Outputs:** `type` (CREDIT_RATING_DOWNGRADE / CREDIT_RATING_UPGRADE / null), `severity`, `delta`, `action_required`
**Connection to other skills:** output should feed CREDIT_RATING_DOWNGRADE into `assess-composite-risk` active_event_types
**Tests:** 14 tests — all severity thresholds, upgrade vs downgrade, null for small changes

**Status:** Built, tested, and wired into CIA briefing mode via `syntheticEvents` pattern.
- CIA reads `credit_rating_score` and `credit_rating_previous_score` from the customers table after step 3
- For each customer with both scores, `detectRatingChange` is called; downgrades with `action_required=true` are injected as `CREDIT_RATING_DOWNGRADE` into `activeEventTypes` and `activeSignalSeverities` in step 6b
- This means a rating downgrade feeds into `assess-composite-risk` even if no agent has filed a `CREDIT_RATING_DOWNGRADE` credit_event

**To activate:** Any agent receiving a new credit score must write the previous score first:
1. Read `credit_rating_score` from the customers table
2. Write it to `credit_rating_previous_score`
3. Write the new score to `credit_rating_score`
CIA will detect the delta automatically on the next briefing run.

---

### `normalise-credit-signal.ts`
**Purpose:** Converts any credit score from any supported provider to a common 0-100 scale where higher = lower risk. The foundation for all credit scoring in CreditPilot — called by `aggregate-credit-scores` internally.
**Called by:** `aggregate-credit-scores.ts` (internally)
**Supported providers:** dnb_paydex, dnb_failure_score, experian_intelliscore, equifax_business, moodys, sp_fitch, coface, atradius, euler_hermes, internal_payment_score, manual, estimated
**Key design decisions:**
- Never throws — unknown inputs return score 50, confidence 'low'
- Euler Hermes: 1-10 scale, 1=best (reversed) — (10-value)/9×100
- Moody's and S&P/Fitch: full letter grade lookup tables including notches (AA+, AA, AA-)
- D&B Failure Score is inverted (higher raw = higher risk, so normalised = 100 - value)

**Interpretation bands:** very_safe ≥80, safe ≥60, watch ≥40, concern ≥20, high_risk <20
**Outputs:** `normalised_score` (0-100), `interpretation`, `confidence`, original signal fields
**Tests:** 36 tests — all providers, edge cases, fallback behaviour

---

### `parse-ar-csv.ts`
**Purpose:** Parses AR aging CSV exports from any ERP system into standardised invoice records. Auto-maps 40+ column name aliases. Used by the CSV upload flow.
**Called by:** `ar-csv-upload` edge function
**Inputs:**
- `csvText: string` — raw CSV content
- `columnMap?: Record<string, string>` — manual column overrides (from mapping UI)
- `as_of_date?: string` — report date for days_overdue calculation (defaults to today)
- `customer_currency?: string` — expected currency for mismatch detection

**Required fields:** invoice_number, customer_name, invoice_date, due_date, outstanding_amount

**Key design decisions:**
- Auto-maps common ERP column names (40+ aliases) — handles SAP, NetSuite, QuickBooks, Dynamics exports
- Returns HTTP 422 with unmapped_columns when required fields cannot be auto-mapped — triggers column mapping UI
- `as_of_date` parameter ensures days_overdue is correct for historical uploads (not calculated from today)
- UTC arithmetic for days_overdue — eliminates timezone off-by-one errors
- Validation warnings (non-blocking): outstanding > amount, >365 days overdue, zero/negative amounts
- Currency warnings: flags invoices where currency differs from customer credit limit currency
- Never throws — all errors collected in errors[] array, valid rows still returned

**Outputs:** `invoices[]`, `errors[]`, `validation_warnings[]`, `currency_warnings[]`, `column_map`, `unmapped_columns`, `available_columns`
**Tests:** 29 tests — required fields, as_of_date relative calculation, validation warnings, currency mismatch, delimiter detection

---

## Removed Skills

### `calculate-altman-z.ts` (removed May 2026)
Calculated Altman Z-score from 5 financial statement inputs. Removed because financial statement data (working capital, retained earnings, EBIT, equity, revenue) is not available via API for most customers. If financial statement data becomes available in future, this skill can be reintroduced.
