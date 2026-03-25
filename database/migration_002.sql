-- ============================================================
-- MIGRATION 002 — Schema additions for agents 4–8
-- Run this in Supabase SQL Editor after migration_001.sql
--
-- Adds tables, columns, and enum values for:
--   Agent 4: Trade Reference Agent
--   Agent 5: Payment Behaviour Monitor
--   Agent 6: Credit Limit Review Agent
--   Agent 7: Bankruptcy & Distress Monitor (extends existing)
--   Agent 8: Onboarding & Credit Scoring Agent
-- ============================================================

-- ============================================================
-- AGENT 4 — TRADE REFERENCE AGENT
-- TradeRef generates outbound credit reference letters when
-- your customers ask you to vouch for them to a new supplier.
-- 
-- New table: trade_reference_requests
--   Tracks incoming requests and the generated letters.
-- ============================================================

CREATE TABLE trade_reference_requests (
  id                  UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id         UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,

  -- Who is requesting the reference
  requesting_company  TEXT    NOT NULL,  -- the new supplier our customer is applying to
  requesting_contact  TEXT,
  requesting_email    TEXT,
  request_date        DATE    NOT NULL DEFAULT CURRENT_DATE,

  -- What they asked for
  requested_terms     TEXT,              -- e.g. "Net 60, $500K limit"
  purpose             TEXT,              -- e.g. "new supplier account", "credit line increase"

  -- Generated letter
  status              TEXT    NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending','generated','sent','declined')),
  letter_subject      TEXT,
  letter_body         TEXT,              -- the full generated reference letter
  letter_generated_at TIMESTAMPTZ,
  letter_sent_at      TIMESTAMPTZ,
  sent_by             TEXT,              -- who approved and sent it

  -- Payment summary snapshot at time of generation
  -- (captured so the letter reflects data at a point in time)
  snapshot_credit_limit       BIGINT,
  snapshot_current_exposure   BIGINT,
  snapshot_payment_terms      INTEGER,
  snapshot_customer_since     DATE,
  snapshot_on_time_rate       NUMERIC(5,4),
  snapshot_avg_days_early_late INTEGER,
  snapshot_total_invoices     INTEGER,
  snapshot_high_credit        BIGINT,    -- highest single invoice amount extended

  agent_name          TEXT    DEFAULT 'trade_reference_agent',
  notes               TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_trade_ref_customer  ON trade_reference_requests(customer_id);
CREATE INDEX idx_trade_ref_status    ON trade_reference_requests(status);
CREATE INDEX idx_trade_ref_date      ON trade_reference_requests(request_date DESC);

-- Add new action types for trade reference agent
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'TRADE_REFERENCE_GENERATED';
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'TRADE_REFERENCE_DECLINED';

-- ============================================================
-- AGENT 5 — PAYMENT BEHAVIOUR MONITOR
-- Detects deteriorating payment patterns before invoices go
-- overdue. Writes findings to a dedicated table so trend
-- history is preserved over time.
--
-- New table: payment_behaviour_snapshots
--   One row per customer per agent run. Builds a timeline of
--   payment health that agents and the UI can trend against.
-- ============================================================

CREATE TABLE payment_behaviour_snapshots (
  id                    UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id           UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  snapshot_date         DATE    NOT NULL DEFAULT CURRENT_DATE,
  agent_run_id          UUID    REFERENCES agent_runs(id) ON DELETE SET NULL,

  -- Computed from last N payment_transactions
  sample_size           INTEGER NOT NULL DEFAULT 0,  -- number of transactions analysed
  avg_days_early_late   NUMERIC(6,2),  -- positive = early, negative = late
  on_time_rate          NUMERIC(5,4),  -- 0.0–1.0
  partial_payment_count INTEGER DEFAULT 0,
  trend                 TEXT    CHECK (trend IN ('improving','stable','deteriorating')),
  trend_delta           NUMERIC(6,2),  -- days shift vs previous window (neg = getting later)

  -- Risk classification
  risk_signal           TEXT    CHECK (risk_signal IN ('none','watch','concern','serious')),

  -- What the agent did as a result
  action_taken          TEXT,          -- 'watch_list_proposed' | 'alert_sent' | 'none'
  notes                 TEXT,

  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE (customer_id, snapshot_date)  -- one snapshot per customer per day
);

CREATE INDEX idx_pbsnap_customer  ON payment_behaviour_snapshots(customer_id);
CREATE INDEX idx_pbsnap_date      ON payment_behaviour_snapshots(snapshot_date DESC);
CREATE INDEX idx_pbsnap_risk      ON payment_behaviour_snapshots(risk_signal)
  WHERE risk_signal IN ('concern','serious');

-- Add new action types for payment behaviour agent
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'PAYMENT_BEHAVIOUR_ALERT';
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'PAYMENT_TREND_IMPROVING';

-- Add new scenario type for payment deterioration (proactive, not yet overdue)
ALTER TYPE scenario_type ADD VALUE IF NOT EXISTS 'payment_deterioration';

-- ============================================================
-- AGENT 6 — CREDIT LIMIT REVIEW AGENT
-- Periodically reviews all credit limits for staleness,
-- over-exposure, and growth opportunities. Proposes both
-- increases and reductions with written rationale.
--
-- New table: credit_limit_reviews
--   Structured record of each formal review with full context.
--   Different from credit_actions (which is the action log) —
--   this is the analysis that precedes the action.
-- ============================================================

CREATE TABLE credit_limit_reviews (
  id                    UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id           UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  agent_run_id          UUID    REFERENCES agent_runs(id) ON DELETE SET NULL,
  review_date           DATE    NOT NULL DEFAULT CURRENT_DATE,

  -- Current state at time of review
  current_limit         BIGINT  NOT NULL,
  current_exposure      BIGINT  NOT NULL,
  utilization_pct       NUMERIC(6,2),
  altman_z_score        NUMERIC(6,2),
  credit_score          INTEGER,
  on_time_rate          NUMERIC(5,4),
  payment_trend         TEXT,
  days_since_last_review INTEGER,

  -- Recommendation
  recommendation        TEXT    NOT NULL
                          CHECK (recommendation IN (
                            'increase','decrease','maintain','urgent_decrease','flag_for_review'
                          )),
  proposed_limit        BIGINT,
  proposed_change_pct   NUMERIC(6,2),  -- positive = increase, negative = decrease
  rationale             TEXT    NOT NULL,

  -- Trigger reason
  trigger_reason        TEXT    NOT NULL
                          CHECK (trigger_reason IN (
                            'scheduled_annual',
                            'scheduled_quarterly',
                            'stale_limit',          -- not reviewed in 12+ months
                            'high_utilization',     -- exposure > 85% of limit
                            'deteriorating_metrics',
                            'improving_metrics',
                            'growth_signal',
                            'news_triggered',
                            'overdue_triggered'
                          )),

  -- Outcome
  status                TEXT    NOT NULL DEFAULT 'pending'
                          CHECK (status IN ('pending','approved','rejected','superseded')),
  reviewed_by           TEXT,
  reviewed_at           TIMESTAMPTZ,
  outcome_notes         TEXT,

  agent_name            TEXT    DEFAULT 'credit_limit_review_agent',
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_clr_customer    ON credit_limit_reviews(customer_id);
CREATE INDEX idx_clr_date        ON credit_limit_reviews(review_date DESC);
CREATE INDEX idx_clr_status      ON credit_limit_reviews(status) WHERE status = 'pending';
CREATE INDEX idx_clr_trigger     ON credit_limit_reviews(trigger_reason);

-- Add next_review_date to customers so the agent knows when to next run
ALTER TABLE customers ADD COLUMN IF NOT EXISTS next_review_date DATE;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS review_frequency TEXT
  DEFAULT 'annual'
  CHECK (review_frequency IN ('monthly','quarterly','annual','triggered_only'));

-- Seed next_review_date for existing customers (1 year from now)
UPDATE customers SET next_review_date = CURRENT_DATE + INTERVAL '1 year'
WHERE next_review_date IS NULL;

-- Customers with payment issues or credit deterioration get quarterly reviews
UPDATE customers SET
  review_frequency = 'quarterly',
  next_review_date = CURRENT_DATE + INTERVAL '3 months'
WHERE scenario IN ('payment_issues','credit_deterioration','negative_news');

-- Add action type
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'CREDIT_REVIEW_COMPLETED';

-- ============================================================
-- AGENT 7 — BANKRUPTCY & DISTRESS MONITOR
-- Extends existing bankruptcy_details table with fields needed
-- for active case monitoring and claim management.
-- Also adds a distress_signals table for pre-bankruptcy alerts.
-- ============================================================

-- Extend bankruptcy_details with monitoring fields
ALTER TABLE bankruptcy_details
  ADD COLUMN IF NOT EXISTS last_checked_date         DATE,
  ADD COLUMN IF NOT EXISTS next_check_date           DATE,
  ADD COLUMN IF NOT EXISTS claim_deadline            DATE,      -- bar date
  ADD COLUMN IF NOT EXISTS claim_deadline_alert_sent BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS distribution_dates        DATE[],    -- known distribution dates
  ADD COLUMN IF NOT EXISTS last_distribution_date    DATE,
  ADD COLUMN IF NOT EXISTS last_distribution_amount  BIGINT,
  ADD COLUMN IF NOT EXISTS total_recovered           BIGINT     DEFAULT 0,
  ADD COLUMN IF NOT EXISTS case_url                  TEXT,      -- PACER/court link
  ADD COLUMN IF NOT EXISTS monitoring_active         BOOLEAN    DEFAULT true;

-- Distress signals table — pre-bankruptcy early warning
-- Agent writes here when multiple risk signals converge
-- before an actual bankruptcy filing
CREATE TABLE distress_signals (
  id                  UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id         UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  agent_run_id        UUID    REFERENCES agent_runs(id) ON DELETE SET NULL,
  signal_date         DATE    NOT NULL DEFAULT CURRENT_DATE,

  -- Signal composition
  altman_z_score      NUMERIC(6,2),
  signals_detected    TEXT[]  DEFAULT '{}',
  -- Examples: 'going_concern_opinion', 'covenant_breach', 'credit_rating_junk',
  --           'negative_cash_flow_3q', 'revolving_credit_drawn_100pct',
  --           'auditor_change', 'cfo_departure', 'dividend_suspended'

  severity            TEXT    NOT NULL
                        CHECK (severity IN ('elevated','high','critical')),
  distress_score      NUMERIC(6,2),  -- composite 0–100
  summary             TEXT    NOT NULL,

  -- Recommended action
  recommended_action  TEXT,
  -- e.g. 'reduce_limit_immediately', 'request_security_deposit',
  --      'require_parent_guarantee', 'stop_shipments_pending_review'

  reviewed            BOOLEAN DEFAULT false,
  reviewed_by         TEXT,
  reviewed_at         TIMESTAMPTZ,

  agent_name          TEXT    DEFAULT 'bankruptcy_monitor_agent',
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_distress_customer  ON distress_signals(customer_id);
CREATE INDEX idx_distress_date      ON distress_signals(signal_date DESC);
CREATE INDEX idx_distress_severity  ON distress_signals(severity);
CREATE INDEX idx_distress_unreviewed ON distress_signals(reviewed) WHERE reviewed = false;

-- Add action types for bankruptcy agent
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'DISTRESS_SIGNAL_DETECTED';
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'CLAIM_DEADLINE_ALERT';
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'DISTRIBUTION_RECEIVED';
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'SECURITY_DEPOSIT_REQUESTED';

-- Add new scenario type for distress (pre-bankruptcy)
ALTER TYPE scenario_type ADD VALUE IF NOT EXISTS 'distress';

-- Seed monitoring fields for existing bankruptcy customers
UPDATE bankruptcy_details SET
  monitoring_active = true,
  next_check_date = CURRENT_DATE + INTERVAL '7 days'
WHERE monitoring_active IS NULL;

-- ============================================================
-- AGENT 8 — ONBOARDING & CREDIT SCORING AGENT
-- Handles new customer credit assessments. Triggered when a
-- customer is added with status 'pending_onboarding'.
--
-- New table: credit_applications
--   Structured onboarding record — the agent populates this,
--   a human reviews and approves the initial limit.
-- ============================================================

CREATE TABLE credit_applications (
  id                    UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id           UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  agent_run_id          UUID    REFERENCES agent_runs(id) ON DELETE SET NULL,
  application_date      DATE    NOT NULL DEFAULT CURRENT_DATE,

  -- What the customer requested
  requested_limit       BIGINT,
  requested_terms_days  INTEGER,
  requested_by          TEXT,            -- contact who submitted the application

  -- Agent research findings
  business_description  TEXT,
  years_in_business     INTEGER,
  estimated_revenue     BIGINT,
  industry_risk_rating  TEXT    CHECK (industry_risk_rating IN ('low','medium','high','very_high')),

  -- Financial assessment
  altman_z_score        NUMERIC(6,2),
  credit_score_assessed INTEGER,
  debt_to_equity        NUMERIC(8,2),
  current_ratio         NUMERIC(6,2),
  financials_source     TEXT,           -- 'sec_edgar' | 'customer_supplied' | 'estimated'
  financials_as_of      DATE,

  -- News & background check
  negative_news_found   BOOLEAN DEFAULT false,
  negative_news_summary TEXT,
  sec_filings_reviewed  BOOLEAN DEFAULT false,

  -- Trade references (from TradeRef agent or manual)
  trade_refs_requested  INTEGER DEFAULT 0,
  trade_refs_received   INTEGER DEFAULT 0,
  trade_refs_positive   INTEGER DEFAULT 0,
  trade_ref_summary     TEXT,

  -- Agent recommendation
  recommendation        TEXT    NOT NULL DEFAULT 'pending'
                          CHECK (recommendation IN (
                            'pending',
                            'approve',
                            'approve_reduced',     -- approve at lower limit than requested
                            'approve_with_conditions', -- e.g. personal guarantee required
                            'decline',
                            'more_info_needed'
                          )),
  recommended_limit     BIGINT,
  recommended_terms_days INTEGER,
  conditions            TEXT[],         -- e.g. ['personal_guarantee','quarterly_financials']
  risk_rating           TEXT    CHECK (risk_rating IN ('A','B','C','D','F')),
  credit_memo           TEXT    NOT NULL DEFAULT '', -- full written credit memo

  -- Human decision
  status                TEXT    NOT NULL DEFAULT 'pending'
                          CHECK (status IN (
                            'pending','approved','approved_modified',
                            'declined','more_info_requested','withdrawn'
                          )),
  decided_by            TEXT,
  decided_at            TIMESTAMPTZ,
  approved_limit        BIGINT,         -- final approved limit (may differ from recommendation)
  approved_terms_days   INTEGER,
  decision_notes        TEXT,

  agent_name            TEXT    DEFAULT 'onboarding_agent',
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_app_customer  ON credit_applications(customer_id);
CREATE INDEX idx_app_date      ON credit_applications(application_date DESC);
CREATE INDEX idx_app_status    ON credit_applications(status) WHERE status = 'pending';
CREATE INDEX idx_app_rec       ON credit_applications(recommendation);

-- Add onboarding status to customers
ALTER TABLE customers ADD COLUMN IF NOT EXISTS onboarding_status TEXT
  DEFAULT 'active'
  CHECK (onboarding_status IN (
    'pending_onboarding',  -- triggers the onboarding agent
    'active',              -- fully onboarded
    'suspended',           -- temporarily suspended
    'closed'               -- relationship ended
  ));

-- Set existing customers to active
UPDATE customers SET onboarding_status = 'active' WHERE onboarding_status IS NULL;

-- Add action types for onboarding agent
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'CREDIT_APPLICATION_RECEIVED';
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'CREDIT_APPLICATION_APPROVED';
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'CREDIT_APPLICATION_DECLINED';
ALTER TYPE credit_action_type ADD VALUE IF NOT EXISTS 'ONBOARDING_COMPLETED';

-- Add new scenario type for onboarding
ALTER TYPE scenario_type ADD VALUE IF NOT EXISTS 'onboarding';

-- ============================================================
-- DEMO DATA — Seed realistic records for new tables
-- ============================================================

-- ── Trade Reference Requests ─────────────────────────────────
-- Two completed requests (Boeing and Haynes asked for references)
-- One pending (Triumph Group has a new request)

INSERT INTO trade_reference_requests (
  customer_id, requesting_company, requesting_contact, requesting_email,
  request_date, requested_terms, purpose, status,
  letter_subject, letter_body,
  letter_generated_at, letter_sent_at, sent_by,
  snapshot_credit_limit, snapshot_current_exposure, snapshot_payment_terms,
  snapshot_customer_since, snapshot_on_time_rate, snapshot_avg_days_early_late,
  snapshot_total_invoices, snapshot_high_credit
) VALUES

-- Boeing — reference for Alcoa (completed)
(
  'c0000001-0000-0000-0000-000000000001',
  'Alcoa Corporation', 'Jennifer Walsh, Credit Manager', 'j.walsh@alcoa.com',
  '2025-11-15', 'Net 45, $5,000,000', 'new supplier account',
  'sent',
  'Credit Reference: The Boeing Company — Global Trading Solutions Inc',
  E'November 15, 2025\n\nJennifer Walsh\nCredit Manager\nAlcoa Corporation\n\nRe: Credit Reference for The Boeing Company\n\nDear Ms. Walsh,\n\nWe are pleased to provide this credit reference for The Boeing Company (NYSE: BA) in response to your request dated November 14, 2025.\n\nGlobal Trading Solutions Inc has maintained a trade credit relationship with The Boeing Company since March 2008 — a relationship spanning over 17 years. During this period, we have extended credit facilities for the supply of specialty alloys including titanium 6Al-4V plate, Inconel 718 bar stock, and related high-performance materials used in Boeing\'s commercial and defense manufacturing operations.\n\nCredit Facility Summary (as of November 15, 2025):\n  • Approved Credit Limit: $5,000,000\n  • Current Outstanding Balance: $3,245,000\n  • Payment Terms: Net 45\n  • High Credit Extended (12-month): $4,890,000\n\nPayment Performance:\n  • On-time payment rate: 96% over the past 36 months\n  • Average days early/late: +3.2 days (consistently early)\n  • No instances of default, dispute, or collections referral\n  • No partial payments or returned items on record\n\nWe regard The Boeing Company as one of our most valued and financially reliable customers. Their finance team maintains professional communication and their payment process is efficient and consistent.\n\nWe have no hesitation in recommending The Boeing Company for the credit facility you are considering. Should you require any additional information, please do not hesitate to contact our credit department.\n\nYours sincerely,\n\nSarah Chen\nCredit Manager\nGlobal Trading Solutions Inc\ncredit@globaltradingsolutions.com',
  '2025-11-15 09:23:00+00', '2025-11-15 10:45:00+00', 'Sarah Chen',
  5000000, 3245000, 45, '2008-03-15', 0.96, 3, 48, 4890000
),

-- Haynes International — reference for a private metals distributor (completed)
(
  'c0000001-0000-0000-0000-000000000048',
  'Precision Metals Direct LLC', 'Robert Kwan', 'rkwan@precisionmetalsdirect.com',
  '2025-12-03', 'Net 30, $250,000', 'new supplier account',
  'sent',
  'Credit Reference: Haynes International Inc — Global Trading Solutions Inc',
  E'December 3, 2025\n\nRobert Kwan\nPrecision Metals Direct LLC\n\nRe: Credit Reference for Haynes International Inc\n\nDear Mr. Kwan,\n\nThis letter serves as a credit reference for Haynes International Inc (NASDAQ: HAYN) at their request.\n\nGlobal Trading Solutions Inc has maintained a trade credit relationship with Haynes International since January 2015. Haynes is a manufacturer of high-performance nickel and cobalt alloys and purchases specialty raw materials and intermediate products from us for use in their own manufacturing processes.\n\nCredit Facility Summary (as of December 3, 2025):\n  • Approved Credit Limit: $750,000\n  • Payment Terms: Net 30\n  • High Credit Extended (12-month): $680,000\n\nPayment Performance:\n  • On-time payment rate: 100% over the past 24 months\n  • Average days to payment: 28 days (consistently within terms)\n  • No disputes, deductions, or collections activity on record\n\nHaynes International is a financially sound, professionally managed company with an excellent payment record with our organisation. We recommend them without reservation.\n\nSincerely,\n\nSarah Chen\nCredit Manager\nGlobal Trading Solutions Inc',
  '2025-12-03 14:10:00+00', '2025-12-03 15:30:00+00', 'Sarah Chen',
  750000, 480000, 30, '2015-01-20', 1.00, 2, 24, 680000
),

-- Triumph Group — pending request (new, not yet generated)
(
  'c0000001-0000-0000-0000-000000000021',
  'Carpenter Technology Corporation', 'Lisa Huang, Credit & Collections', 'l.huang@cartech.com',
  CURRENT_DATE - 2, 'Net 45, $1,500,000', 'credit limit increase request',
  'pending',
  NULL, NULL, NULL, NULL, NULL,
  2000000, 1847000, 45, '2017-06-01', NULL, NULL, NULL, NULL
);

-- ── Payment Behaviour Snapshots ───────────────────────────────
-- Seed historical snapshots for the customers with payment issues
-- so the trend chart has data from day one

INSERT INTO payment_behaviour_snapshots (
  customer_id, snapshot_date, sample_size,
  avg_days_early_late, on_time_rate, partial_payment_count,
  trend, trend_delta, risk_signal, action_taken
) VALUES

-- Triumph Group — deteriorating trend over 6 months
('c0000001-0000-0000-0000-000000000021', CURRENT_DATE - 180, 8, 2.5, 0.88, 0, 'stable', 0.0, 'none', 'none'),
('c0000001-0000-0000-0000-000000000021', CURRENT_DATE - 120, 8, -1.2, 0.75, 1, 'deteriorating', -3.7, 'watch', 'alert_sent'),
('c0000001-0000-0000-0000-000000000021', CURRENT_DATE - 60,  8, -8.4, 0.63, 2, 'deteriorating', -7.2, 'concern', 'watch_list_proposed'),
('c0000001-0000-0000-0000-000000000021', CURRENT_DATE,       8, -14.1, 0.50, 3, 'deteriorating', -5.7, 'serious', 'watch_list_proposed'),

-- Orbital Energy — rapid deterioration
('c0000001-0000-0000-0000-000000000023', CURRENT_DATE - 90,  6, 1.0, 0.83, 0, 'stable', 0.5, 'none', 'none'),
('c0000001-0000-0000-0000-000000000023', CURRENT_DATE - 30,  6, -12.3, 0.50, 2, 'deteriorating', -13.3, 'serious', 'watch_list_proposed'),
('c0000001-0000-0000-0000-000000000023', CURRENT_DATE,       6, -18.7, 0.33, 3, 'deteriorating', -6.4, 'serious', 'watch_list_proposed'),

-- Kaman — slow drift
('c0000001-0000-0000-0000-000000000022', CURRENT_DATE - 120, 10, 4.2, 0.90, 0, 'stable', 1.2, 'none', 'none'),
('c0000001-0000-0000-0000-000000000022', CURRENT_DATE - 60,  10, 0.8, 0.80, 1, 'deteriorating', -3.4, 'watch', 'none'),
('c0000001-0000-0000-0000-000000000022', CURRENT_DATE,       10, -3.1, 0.70, 1, 'deteriorating', -3.9, 'watch', 'alert_sent'),

-- Boeing — consistently healthy (positive reference)
('c0000001-0000-0000-0000-000000000001', CURRENT_DATE - 90,  12, 3.8, 0.97, 0, 'stable', 0.3, 'none', 'none'),
('c0000001-0000-0000-0000-000000000001', CURRENT_DATE,       12, 4.1, 0.97, 0, 'improving', 0.3, 'none', 'none');

-- ── Credit Limit Reviews ──────────────────────────────────────
-- Seed a mix of pending, approved, and stale reviews

INSERT INTO credit_limit_reviews (
  customer_id, review_date, current_limit, current_exposure,
  utilization_pct, altman_z_score, credit_score, on_time_rate, payment_trend,
  days_since_last_review, recommendation, proposed_limit, proposed_change_pct,
  rationale, trigger_reason, status
) VALUES

-- Arconic — urgent decrease recommended, pending
(
  'c0000001-0000-0000-0000-000000000031',
  CURRENT_DATE - 5,
  2500000, 2180000, 87.2, 1.65, 520, 0.72, 'deteriorating',
  14,
  'urgent_decrease', 1500000, -40.0,
  'Arconic presents multiple concurrent risk factors requiring immediate limit reduction. Altman Z-score of 1.65 places the company firmly in the distress zone. Utilization at 87.2% combined with deteriorating payment behaviour (on-time rate declined from 89% to 72% over 6 months) creates unacceptable concentration risk. Q3 EBITDA missed consensus by 22% and 2025 guidance has been lowered. Recommend reducing limit to $1.5M (40% reduction) immediately. Review again in 90 days or upon receipt of Q4 financials.',
  'deteriorating_metrics',
  'pending'
),

-- Haynes International — increase recommended (growth signal)
(
  'c0000001-0000-0000-0000-000000000048',
  CURRENT_DATE - 3,
  750000, 480000, 64.0, 3.82, 710, 1.00, 'improving',
  365,
  'increase', 1250000, 66.7,
  'Haynes International merits a significant credit limit increase. 100% on-time payment rate over 24 months. Altman Z-score of 3.82 is comfortably in the safe zone. The company recently announced a $180M backlog increase driven by aerospace demand recovery. Revenue growing 12% YoY. Current limit of $750K is constraining the commercial relationship — account manager reports several orders have been declined due to limit exhaustion. Recommend increasing to $1.25M, which represents 1.8x current exposure, appropriate for this risk profile.',
  'growth_signal',
  'pending'
),

-- Lockheed Martin — annual review, maintain
(
  'c0000001-0000-0000-0000-000000000003',
  CURRENT_DATE - 30,
  4000000, 2950000, 73.8, 4.21, 780, 0.95, 'stable',
  370,
  'maintain', 4000000, 0.0,
  'Annual review of Lockheed Martin credit facility. All metrics remain strong. Altman Z-score 4.21 (safe zone). On-time payment rate 95%. No negative news. Defense backlog remains robust. Current limit of $4M remains appropriate. No change recommended. Schedule next review in 12 months.',
  'scheduled_annual',
  'approved'
),

-- Triumph Group — overdue triggered, decrease approved
(
  'c0000001-0000-0000-0000-000000000021',
  CURRENT_DATE - 45,
  2000000, 1847000, 92.4, 1.45, 480, 0.50, 'deteriorating',
  180,
  'urgent_decrease', 1000000, -50.0,
  'Triggered by 69-day overdue status. Altman Z-score 1.45 (distress zone). Utilization 92.4% — critically high. On-time rate deteriorated to 50% from 88% six months ago. Multiple partial payments. Recommend 50% limit reduction to $1M immediately pending payment resolution.',
  'overdue_triggered',
  'approved'
);

-- ── Distress Signals ──────────────────────────────────────────
-- Seed distress signals for the most at-risk customers

INSERT INTO distress_signals (
  customer_id, signal_date, altman_z_score, signals_detected,
  severity, distress_score, summary, recommended_action, reviewed
) VALUES

-- Arconic — elevated distress
(
  'c0000001-0000-0000-0000-000000000031',
  CURRENT_DATE - 14,
  1.65,
  ARRAY['altman_z_distress_zone', 'earnings_miss_consecutive', 'guidance_lowered', 'payment_deterioration'],
  'high', 72.0,
  'Arconic shows four concurrent distress signals. Altman Z of 1.65 in the distress zone. Two consecutive quarterly earnings misses with downward guidance revision. Payment behaviour deteriorating over 6 months. Not yet at critical threshold but requires active monitoring and limit reduction.',
  'reduce_limit_immediately',
  true
),

-- Triumph Group — high distress, already in collections
(
  'c0000001-0000-0000-0000-000000000021',
  CURRENT_DATE - 7,
  1.45,
  ARRAY['altman_z_distress_zone', 'invoices_90_days_overdue', 'payment_deterioration', 'partial_payments_multiple'],
  'critical', 88.0,
  'Triumph Group has reached critical distress threshold. Altman Z 1.45. Invoices 69 days overdue with $1.85M at risk. On-time rate collapsed to 50%. Multiple partial payments. Immediate credit hold and collections engagement required.',
  'stop_shipments_pending_review',
  true
),

-- McDermott — elevated pre-distress signals
(
  'c0000001-0000-0000-0000-000000000032',
  CURRENT_DATE - 21,
  1.72,
  ARRAY['altman_z_distress_zone', 'restructuring_announcement', 'management_change'],
  'elevated', 58.0,
  'McDermott International showing early distress signals. Altman Z 1.72 in distress zone. Recent restructuring announcement and CFO departure. No payment issues yet but risk profile has materially worsened. Recommend watch list placement and quarterly financial monitoring.',
  'reduce_limit_immediately',
  false
);

-- ── Credit Applications ───────────────────────────────────────
-- Two demo onboarding records — one approved historical, one pending

INSERT INTO credit_applications (
  customer_id, application_date,
  requested_limit, requested_terms_days, requested_by,
  business_description, years_in_business, estimated_revenue,
  industry_risk_rating, altman_z_score, credit_score_assessed,
  financials_source, financials_as_of,
  negative_news_found, sec_filings_reviewed,
  trade_refs_requested, trade_refs_received, trade_refs_positive, trade_ref_summary,
  recommendation, recommended_limit, recommended_terms_days,
  risk_rating, credit_memo,
  status, decided_by, decided_at, approved_limit, approved_terms_days
) VALUES

-- GE Vernova — new customer, approved (historical)
(
  'c0000001-0000-0000-0000-000000000049',
  '2024-04-01',
  3000000, 45, 'Michael Torres, VP Procurement',
  'GE Vernova Inc is a global energy technology company spun off from General Electric in April 2024. The company operates across three segments: Power, Wind, and Electrification. It serves electric utilities, independent power producers, and industrial customers in over 100 countries.',
  1, 35000000000,
  'low', 3.45, 680,
  'sec_edgar', '2024-03-31',
  false, true,
  3, 3, 3,
  'Three trade references received, all positive. Honeywell confirmed 5-year relationship, on-time rate 98%. Siemens Energy confirmed $8M credit facility, no issues. ABB confirmed 3-year relationship, payments consistently early. All references rate GE Vernova as a top-tier credit customer.',
  'approve', 3000000, 45,
  'A',
  E'CREDIT MEMORANDUM — GE Vernova Inc\nDate: April 1, 2024\nPrepared by: Onboarding Agent\n\nEXECUTIVE SUMMARY\nRecommend approval of $3,000,000 credit facility on Net 45 terms. GE Vernova is a newly independent public company spun off from General Electric with strong fundamentals, investment-grade credit profile, and excellent trade references from three established suppliers.\n\nCOMPANY OVERVIEW\nGE Vernova Inc (NYSE: GEV) was incorporated as an independent entity in April 2024 following the completion of GE\'s strategic separation plan. The company had $34.9B in revenue in 2023 as part of GE and maintains its global customer relationships and operational infrastructure. It is publicly traded with a market cap of approximately $18B at time of application.\n\nFINANCIAL ASSESSMENT\nAltman Z-Score: 3.45 (safe zone). Credit score: 680. Current ratio: 1.42. Financials sourced from SEC 10-K filing (Q1 2024 10-Q not yet available as newly public). Revenue trajectory positive with strong order backlog in power generation segment.\n\nTRADE REFERENCES\nAll three references confirmed positive payment experiences. No adverse information identified.\n\nRISK FACTORS\n- Newly independent entity: limited standalone track record (mitigated by GE heritage and retained management team)\n- Wind segment facing near-term headwinds (offshore project delays)\n\nRECOMMENDATION\nApprove $3,000,000 credit facility, Net 45 terms. Risk rating: A. Annual review scheduled.',
  'approved', 'Sarah Chen', '2024-04-03 09:00:00+00', 3000000, 45
),

-- Joby Aviation — pending new application
(
  'c0000001-0000-0000-0000-000000000046',
  CURRENT_DATE - 7,
  500000, 30, 'Amanda Foster, Head of Supply Chain',
  'Joby Aviation Inc is a California-based air taxi company developing an all-electric vertical take-off and landing (eVTOL) aircraft for commercial passenger service. Currently in FAA certification phase with commercial operations planned for 2025-2026.',
  6, 85000000,
  'high', 1.82, 410,
  'sec_edgar', CURRENT_DATE - 30,
  false, true,
  3, 1, 1,
  'Three trade references requested. One received from Toray Industries confirming $2M composite materials relationship, payments on time. Two references outstanding from Joby''s other suppliers. Insufficient references to complete assessment — more info needed.',
  'more_info_needed', 250000, 30,
  'C',
  E'CREDIT MEMORANDUM — Joby Aviation Inc (DRAFT — PENDING)\nDate: ' || CURRENT_DATE::TEXT || E'\nPrepared by: Onboarding Agent\nStatus: PENDING — additional trade references required\n\nEXECUTIVE SUMMARY\nRecommend approval of reduced $250,000 facility on Net 30 terms, subject to receipt of outstanding trade references. Full $500,000 requested limit not supportable at this time given pre-revenue status and high industry risk.\n\nCOMPANY OVERVIEW\nJoby Aviation Inc (NYSE: JOBY) is a pre-revenue eVTOL developer. The company has received $1.6B in funding including a $394M investment from Toyota. FAA Part 135 Air Carrier Certificate received. Commercial launch timeline is 2025-2026 subject to FAA type certification completion.\n\nFINANCIAL ASSESSMENT\nAltman Z-Score: 1.82 (grey zone — pre-revenue company, standard Z-score has limited applicability). Burn rate approximately $60M per quarter. Cash on hand $780M (sufficient runway through 2026). No revenue to assess payment capacity from operations.\n\nKEY RISK FACTORS\n- Pre-revenue: payment capacity dependent on continued investor funding\n- Regulatory risk: commercial launch contingent on FAA certification\n- High cash burn: monitoring required\n- Industry risk: eVTOL sector unproven at commercial scale\n\nPENDING ITEMS\n- 2 of 3 trade references outstanding\n- Await Q3 financials for updated cash position\n\nRECOMMENDATION\nApprove reduced $250,000 facility, Net 30 terms, subject to satisfactory trade references. Full limit may be reconsidered after 6 months of payment history established. Risk rating: C.',
  'pending', NULL, NULL, NULL, NULL
);

-- ── Update customers.onboarding_status ───────────────────────
UPDATE customers SET onboarding_status = 'active'
WHERE onboarding_status IS NULL;

-- ── RLS policies for new tables ───────────────────────────────
DO $$
DECLARE t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'trade_reference_requests',
    'payment_behaviour_snapshots',
    'credit_limit_reviews',
    'distress_signals',
    'credit_applications'
  ]) LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format(
      'CREATE POLICY "anon_select" ON %I FOR SELECT USING (auth.role() = ''anon'')', t
    );
    EXECUTE format(
      'CREATE POLICY "service_all" ON %I USING (auth.role() = ''service_role'')', t
    );
  END LOOP;
END $$;

-- ── Realtime ──────────────────────────────────────────────────
ALTER PUBLICATION supabase_realtime ADD TABLE distress_signals;
ALTER PUBLICATION supabase_realtime ADD TABLE credit_limit_reviews;

-- ── Verify ────────────────────────────────────────────────────
SELECT
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns c
   WHERE c.table_name = t.table_name
   AND c.table_schema = 'public') AS columns,
  (SELECT COUNT(*) FROM information_schema.tables t2
   WHERE t2.table_name = t.table_name) AS exists
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_name IN (
    'trade_reference_requests',
    'payment_behaviour_snapshots',
    'credit_limit_reviews',
    'distress_signals',
    'credit_applications'
  )
ORDER BY table_name;
