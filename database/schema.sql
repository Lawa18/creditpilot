-- ============================================================
-- Global Trading Solutions Inc - Credit Monitoring System
-- Supabase PostgreSQL Schema  v2.0
--
-- DESIGN PRINCIPLES:
--   1. Every table links to `customers` via customer_id FK —
--      no orphan rows anywhere
--   2. `payment_transactions` = real ledger of individual payments
--      (replaces the old single-row payment_history summary)
--   3. AR aging is a first-class table + views (current + portfolio)
--   4. Schema is intentionally portable — swap the seller company
--      and this works for any B2B credit monitoring deployment
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE market_cap_tier AS ENUM (
  'large_cap', 'mid_cap', 'small_cap', 'private', 'private_subsidiary'
);

CREATE TYPE scenario_type AS ENUM (
  'normal_operations', 'payment_issues', 'credit_deterioration',
  'negative_news', 'bankruptcy', 'growth_opportunity', 'sec_filing_monitoring'
);

CREATE TYPE invoice_status AS ENUM (
  'current', 'overdue', 'pre_petition', 'paid', 'written_off', 'disputed'
);

CREATE TYPE dunning_stage AS ENUM ('1', '2', '3', '4');

CREATE TYPE payment_method AS ENUM (
  'wire_transfer', 'ach', 'check', 'credit_card', 'offset', 'partial', 'other'
);

CREATE TYPE credit_action_type AS ENUM (
  'PLACED_ON_WATCH_LIST', 'REMOVED_FROM_WATCH_LIST',
  'CREDIT_HOLD_PLACED', 'CREDIT_HOLD_RELEASED',
  'CREDIT_LIMIT_REDUCTION', 'CREDIT_LIMIT_INCREASE', 'CREDIT_LIMIT_REVIEW',
  'DUNNING_LETTER_STAGE_1', 'DUNNING_LETTER_STAGE_2',
  'DUNNING_LETTER_STAGE_3', 'DUNNING_LETTER_STAGE_4',
  'REFERRED_TO_COLLECTIONS', 'PROOF_OF_CLAIM_FILED', 'COD_ONLY_POLICY_SET',
  'PARENT_GUARANTEE_REQUEST_SENT', 'CREDIT_REVIEW_INITIATED',
  'LEGAL_COUNSEL_ENGAGED', 'PAYMENT_PLAN_DISCUSSION', 'PAYMENT_PLAN_AGREED',
  'SEC_ALERT_TRIGGERED', 'NEWS_ALERT_TRIGGERED', 'NEWS_MONITORING_INCREASED',
  'FINANCIALS_REQUEST_SENT', 'EXECUTIVE_ESCALATION', 'OTHER'
);

CREATE TYPE bankruptcy_status AS ENUM (
  'FILED', 'CONFIRMED_PLAN', 'CHAPTER_7_CONVERTED',
  'ASSETS_SOLD', 'EMERGED', 'DISMISSED'
);

CREATE TYPE credit_event_type AS ENUM (
  'RATING_DOWNGRADE', 'RATING_UPGRADE', 'OUTLOOK_CHANGE',
  'EARNINGS_MISS', 'EARNINGS_BEAT',
  'COVENANT_WAIVER', 'COVENANT_BREACH',
  'RESTRUCTURING_ANNOUNCEMENT', 'MANAGEMENT_CHANGE', 'OWNERSHIP_CHANGE',
  'SEC_INVESTIGATION', 'GOODWILL_IMPAIRMENT', 'CAPITAL_RAISE',
  'LOAN_AMENDMENT', 'CONTRACT_LOSS', 'CONTRACT_WIN',
  'GOING_CONCERN', 'CREDIT_FACILITY_AMENDMENT', 'OTHER'
);

-- ============================================================
-- TABLE: company
-- The seller — Global Trading Solutions Inc (or any company
-- in production). Single row. Holds credit policy settings
-- that agents read as thresholds.
-- ============================================================
CREATE TABLE company (
  id                                UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  name                              TEXT    NOT NULL,
  ticker                            TEXT,
  industry                          TEXT,
  annual_revenue                    BIGINT,
  description                       TEXT,
  headquarters                      TEXT,
  founded                           INTEGER,
  employees                         INTEGER,
  -- Credit Policy (agents read these as configurable thresholds)
  max_single_customer_exposure_pct  NUMERIC(5,2)  DEFAULT 10.0,
  standard_payment_terms_days       INTEGER       DEFAULT 45,
  review_trigger_days_overdue       INTEGER       DEFAULT 30,
  watch_list_trigger_days_overdue   INTEGER       DEFAULT 60,
  total_portfolio_limit             BIGINT        DEFAULT 130000000,
  base_currency                     TEXT          DEFAULT 'USD',
  fiscal_year_end_month             INTEGER       DEFAULT 12,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- TABLE: customers
-- Buyer counterparties. Every other table FKs here.
-- ============================================================
CREATE TABLE customers (
  id                  UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_name        TEXT    NOT NULL,
  ticker              TEXT,
  sec_cik             TEXT,             -- SEC EDGAR CIK for filing lookups
  scenario            scenario_type     NOT NULL DEFAULT 'normal_operations',
  industry            TEXT,
  market_cap_tier     market_cap_tier,
  market_cap_usd      BIGINT,
  headquarters        TEXT,
  -- Credit
  credit_limit        BIGINT  NOT NULL DEFAULT 0,
  current_exposure    BIGINT  NOT NULL DEFAULT 0,  -- maintained by trigger
  payment_terms_days  INTEGER NOT NULL DEFAULT 45,
  -- Relationship
  customer_since      DATE,
  account_manager     TEXT,
  primary_contact     TEXT,
  primary_products    TEXT[]  DEFAULT '{}',
  contract_expiry     DATE,
  preferred_customer  BOOLEAN DEFAULT false,
  -- Agent-managed status flags
  flags               TEXT[]  DEFAULT '{}',
  notes               TEXT,
  last_reviewed       DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- TABLE: invoices
-- Open/closed AR — one row per invoice.
-- `amount_outstanding` is computed from invoice_amount - amount_paid.
-- ============================================================
CREATE TABLE invoices (
  id                       UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id              UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  invoice_number           TEXT    NOT NULL UNIQUE,
  -- Amounts
  invoice_amount           BIGINT  NOT NULL,
  amount_paid              BIGINT  NOT NULL DEFAULT 0,
  amount_outstanding       BIGINT  GENERATED ALWAYS AS (invoice_amount - amount_paid) STORED,
  -- Dates
  invoice_date             DATE,
  due_date                 DATE    NOT NULL,
  days_overdue             INTEGER NOT NULL DEFAULT 0,
  -- Status & collections
  status                   invoice_status NOT NULL DEFAULT 'current',
  dunning_stage            dunning_stage,
  dunning_sent_date        DATE,
  next_dunning_date        DATE,
  escalated_to_collections BOOLEAN DEFAULT false,
  -- Bankruptcy
  claimable                BOOLEAN DEFAULT false,
  -- Line item metadata
  product_description      TEXT,
  purchase_order_number    TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- TABLE: payment_transactions
-- Historical ledger of every payment received.
-- This is the SOURCE OF TRUTH for DSO, on-time rate, and
-- payment behaviour trend analysis.
-- Agents query this table directly to compute:
--   - avg days to pay
--   - on-time payment rate
--   - 6-month vs 12-month trend
--   - DSO
-- ============================================================
CREATE TABLE payment_transactions (
  id                  UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id         UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  invoice_id          UUID    REFERENCES invoices(id) ON DELETE SET NULL,
  invoice_number      TEXT,             -- denormalized for easy reporting
  -- Payment details
  payment_date        DATE    NOT NULL,
  amount_paid         BIGINT  NOT NULL,
  payment_method      payment_method DEFAULT 'wire_transfer',
  reference_number    TEXT,             -- bank ref / check number
  -- Timing (computed at insert by load script or trigger)
  invoice_date        DATE,
  invoice_due_date    DATE,
  days_to_pay         INTEGER,          -- payment_date - invoice_date
  days_early_late     INTEGER,          -- >0 = paid early, <0 = paid late
  paid_on_time        BOOLEAN,          -- days_early_late >= 0
  -- Partial payment
  is_partial_payment  BOOLEAN DEFAULT false,
  notes               TEXT,
  posted_by           TEXT DEFAULT 'system',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- TABLE: ar_aging_snapshots
-- Point-in-time AR aging buckets per customer.
-- A nightly agent inserts one row per customer per day,
-- creating an aging timeline. The views below always show
-- the latest snapshot.
-- ============================================================
CREATE TABLE ar_aging_snapshots (
  id                    UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id           UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  snapshot_date         DATE    NOT NULL DEFAULT CURRENT_DATE,
  -- Standard aging buckets
  current_amount        BIGINT  NOT NULL DEFAULT 0,
  bucket_1_30           BIGINT  NOT NULL DEFAULT 0,
  bucket_31_60          BIGINT  NOT NULL DEFAULT 0,
  bucket_61_90          BIGINT  NOT NULL DEFAULT 0,
  bucket_over_90        BIGINT  NOT NULL DEFAULT 0,
  total_outstanding     BIGINT  GENERATED ALWAYS AS (
    current_amount + bucket_1_30 + bucket_31_60 + bucket_61_90 + bucket_over_90
  ) STORED,
  -- Invoice counts per bucket
  current_count         INTEGER DEFAULT 0,
  bucket_1_30_count     INTEGER DEFAULT 0,
  bucket_31_60_count    INTEGER DEFAULT 0,
  bucket_61_90_count    INTEGER DEFAULT 0,
  bucket_over_90_count  INTEGER DEFAULT 0,
  total_invoice_count   INTEGER GENERATED ALWAYS AS (
    current_count + bucket_1_30_count + bucket_31_60_count +
    bucket_61_90_count + bucket_over_90_count
  ) STORED,
  -- Pre-petition (bankruptcy) tracked separately
  pre_petition_amount   BIGINT  NOT NULL DEFAULT 0,
  -- Metrics at snapshot time
  credit_limit          BIGINT,
  utilization_pct       NUMERIC(6,2),
  dso_days              NUMERIC(6,1),
  generated_by          TEXT DEFAULT 'system',
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (customer_id, snapshot_date)
);

-- ============================================================
-- TABLE: credit_metrics
-- Latest financial health snapshot per customer.
-- One row per customer; updated by credit monitoring agent.
-- ============================================================
CREATE TABLE credit_metrics (
  id                        UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id               UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  credit_score              INTEGER CHECK (credit_score BETWEEN 0 AND 850),
  d_and_b_rating            TEXT,
  d_and_b_failure_score     INTEGER,
  altman_z_score            NUMERIC(6,2),
  debt_to_equity            NUMERIC(8,2),
  current_ratio             NUMERIC(6,2),
  quick_ratio               NUMERIC(6,2),
  interest_coverage         NUMERIC(6,2),
  cash_on_hand              BIGINT,
  total_debt                BIGINT,
  burn_rate_quarterly       BIGINT,
  private_company           BOOLEAN DEFAULT false,
  parent_company_guarantee  BOOLEAN,
  last_financials_date      DATE,
  financials_source         TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (customer_id)
);

-- ============================================================
-- TABLE: credit_metric_changes
-- Audit trail every time a score/ratio changes.
-- ============================================================
CREATE TABLE credit_metric_changes (
  id            UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id   UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  change_date   DATE    NOT NULL,
  metric_name   TEXT    NOT NULL,
  old_value     NUMERIC,
  new_value     NUMERIC,
  source        TEXT,
  agent_name    TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- TABLE: credit_actions
-- Full audit log of every credit decision (human or agent).
-- ============================================================
CREATE TABLE credit_actions (
  id              UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id     UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  action_date     DATE    NOT NULL,
  action_type     credit_action_type NOT NULL,
  description     TEXT,
  old_limit       BIGINT,
  new_limit       BIGINT,
  claim_amount    BIGINT,
  performed_by    TEXT,
  agent_name      TEXT,
  requires_review BOOLEAN DEFAULT false,
  reviewed_by     TEXT,
  reviewed_at     TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- TABLE: credit_events
-- External events affecting credit standing.
-- Agents write here when SEC / news feeds surface material events.
-- ============================================================
CREATE TABLE credit_events (
  id            UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id   UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  event_date    DATE    NOT NULL,
  event_type    credit_event_type NOT NULL,
  detail        TEXT,
  source        TEXT,
  source_url    TEXT,
  agent_name    TEXT,
  reviewed      BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- TABLE: negative_news
-- News articles with negative sentiment about a CUSTOMER.
-- All rows MUST have customer_id — no orphan news rows.
-- Populated by the news monitoring agent.
-- ============================================================
CREATE TABLE negative_news (
  id              UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id     UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  news_date       DATE    NOT NULL,
  headline        TEXT    NOT NULL,
  source          TEXT,
  sentiment_score NUMERIC(4,2) CHECK (sentiment_score BETWEEN -1 AND 1),
  url             TEXT,
  summary         TEXT,
  category        TEXT,   -- 'bankruptcy','regulatory','management','financial','operational'
  severity        TEXT    CHECK (severity IN ('critical','high','medium','low')) DEFAULT 'medium',
  reviewed        BOOLEAN DEFAULT false,
  reviewed_by     TEXT,
  reviewed_at     TIMESTAMPTZ,
  action_taken    TEXT,
  agent_name      TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- TABLE: bankruptcy_details
-- Bankruptcy case details for customers that have filed.
-- ============================================================
CREATE TABLE bankruptcy_details (
  id                          UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id                 UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  filing_date                 DATE    NOT NULL,
  case_number                 TEXT    NOT NULL,
  court                       TEXT,
  chapter                     INTEGER NOT NULL CHECK (chapter IN (7, 11, 13)),
  status                      bankruptcy_status NOT NULL DEFAULT 'FILED',
  plan_confirmation_date      DATE,
  emergence_date_estimated    TEXT,
  chapter7_conversion_date    DATE,
  asset_sale_date             DATE,
  asset_buyer                 TEXT,
  trustee                     TEXT,
  reorganization_advisor      TEXT,
  legal_counsel               TEXT,
  proof_of_claim_filed        BOOLEAN DEFAULT false,
  proof_of_claim_date         DATE,
  proof_of_claim_amount       BIGINT,
  estimated_recovery_rate     NUMERIC(5,4) CHECK (estimated_recovery_rate BETWEEN 0 AND 1),
  estimated_recovery_amount   BIGINT,
  total_pre_petition_claim    BIGINT,
  notes                       TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (customer_id)
);

-- ============================================================
-- TABLE: growth_signals
-- Positive signals warranting credit limit increases or
-- preferred supplier conversations.
-- ============================================================
CREATE TABLE growth_signals (
  id                                UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id                       UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  growth_trajectory                 TEXT,
  revenue_growth_yoy                NUMERIC(6,4),
  backlog_amount                    BIGINT,
  backlog_description               TEXT,
  recent_milestones                 TEXT[]  DEFAULT '{}',
  credit_limit_increase_recommended BOOLEAN DEFAULT false,
  recommended_new_limit             BIGINT,
  rationale                         TEXT,
  upsell_opportunity                TEXT,
  agent_name                        TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (customer_id)
);

-- ============================================================
-- TABLE: sec_monitoring
-- Per-customer SEC EDGAR monitoring config + state.
-- ============================================================
CREATE TABLE sec_monitoring (
  id                      UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id             UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  cik                     TEXT    NOT NULL,
  monitoring_active       BOOLEAN DEFAULT true,
  filing_types_monitored  TEXT[]  DEFAULT ARRAY['10-K','10-Q','8-K'],
  last_10k_date           DATE,
  last_10q_date           DATE,
  last_8k_date            DATE,
  risk_signals_detected   TEXT[]  DEFAULT '{}',
  alert_triggered         BOOLEAN DEFAULT false,
  alert_date              DATE,
  alert_action_taken      TEXT,
  next_scheduled_review   DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (customer_id)
);

-- ============================================================
-- TABLE: sec_filings
-- Individual SEC filing records reviewed by agent.
-- ============================================================
CREATE TABLE sec_filings (
  id               UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id      UUID    NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  filing_date      DATE    NOT NULL,
  filing_type      TEXT    NOT NULL,
  accession_number TEXT,
  url              TEXT,
  key_findings     TEXT,
  risk_signals     TEXT[]  DEFAULT '{}',
  reviewed         BOOLEAN DEFAULT false,
  reviewed_by      TEXT,
  reviewed_at      TIMESTAMPTZ,
  agent_name       TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION fn_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$;

-- Recalculate current_exposure from open invoices
CREATE OR REPLACE FUNCTION fn_recalculate_exposure(p_customer_id UUID)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
  UPDATE customers SET
    current_exposure = (
      SELECT COALESCE(SUM(amount_outstanding), 0)
      FROM invoices
      WHERE customer_id = p_customer_id
        AND status NOT IN ('paid', 'written_off')
    ),
    updated_at = now()
  WHERE id = p_customer_id;
END;
$$;

-- Trigger wrapper for exposure recalc
CREATE OR REPLACE FUNCTION fn_trg_recalculate_exposure()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  PERFORM fn_recalculate_exposure(
    CASE WHEN TG_OP = 'DELETE' THEN OLD.customer_id ELSE NEW.customer_id END
  );
  RETURN NULL;
END;
$$;

-- Compute and upsert AR aging snapshot for one customer
CREATE OR REPLACE FUNCTION fn_refresh_ar_aging(
  p_customer_id UUID,
  p_as_of       DATE DEFAULT CURRENT_DATE
) RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE
  v_cur BIGINT; v_b1  BIGINT; v_b2 BIGINT; v_b3 BIGINT; v_b4 BIGINT; v_pp BIGINT;
  v_cc  INT;    v_c1  INT;    v_c2 INT;    v_c3 INT;    v_c4 INT;
  v_lim BIGINT; v_util NUMERIC;
BEGIN
  SELECT
    COALESCE(SUM(amount_outstanding) FILTER (WHERE days_overdue = 0 AND status = 'current'), 0),
    COALESCE(SUM(amount_outstanding) FILTER (WHERE days_overdue BETWEEN 1  AND 30),  0),
    COALESCE(SUM(amount_outstanding) FILTER (WHERE days_overdue BETWEEN 31 AND 60),  0),
    COALESCE(SUM(amount_outstanding) FILTER (WHERE days_overdue BETWEEN 61 AND 90),  0),
    COALESCE(SUM(amount_outstanding) FILTER (WHERE days_overdue > 90 AND status != 'pre_petition'), 0),
    COALESCE(SUM(amount_outstanding) FILTER (WHERE status = 'pre_petition'), 0),
    COUNT(*) FILTER (WHERE days_overdue = 0  AND status = 'current'),
    COUNT(*) FILTER (WHERE days_overdue BETWEEN 1  AND 30),
    COUNT(*) FILTER (WHERE days_overdue BETWEEN 31 AND 60),
    COUNT(*) FILTER (WHERE days_overdue BETWEEN 61 AND 90),
    COUNT(*) FILTER (WHERE days_overdue > 90 AND status != 'pre_petition')
  INTO v_cur, v_b1, v_b2, v_b3, v_b4, v_pp,
       v_cc, v_c1, v_c2, v_c3, v_c4
  FROM invoices
  WHERE customer_id = p_customer_id AND status NOT IN ('paid','written_off');

  SELECT credit_limit INTO v_lim FROM customers WHERE id = p_customer_id;
  v_util := CASE WHEN v_lim > 0
    THEN ROUND(((v_cur+v_b1+v_b2+v_b3+v_b4+v_pp)::NUMERIC / v_lim)*100, 2)
    ELSE NULL END;

  INSERT INTO ar_aging_snapshots (
    customer_id, snapshot_date,
    current_amount, bucket_1_30, bucket_31_60, bucket_61_90, bucket_over_90,
    current_count, bucket_1_30_count, bucket_31_60_count, bucket_61_90_count, bucket_over_90_count,
    pre_petition_amount, credit_limit, utilization_pct
  ) VALUES (
    p_customer_id, p_as_of,
    v_cur, v_b1, v_b2, v_b3, v_b4,
    v_cc, v_c1, v_c2, v_c3, v_c4,
    v_pp, v_lim, v_util
  )
  ON CONFLICT (customer_id, snapshot_date) DO UPDATE SET
    current_amount      = EXCLUDED.current_amount,
    bucket_1_30         = EXCLUDED.bucket_1_30,
    bucket_31_60        = EXCLUDED.bucket_31_60,
    bucket_61_90        = EXCLUDED.bucket_61_90,
    bucket_over_90      = EXCLUDED.bucket_over_90,
    current_count       = EXCLUDED.current_count,
    bucket_1_30_count   = EXCLUDED.bucket_1_30_count,
    bucket_31_60_count  = EXCLUDED.bucket_31_60_count,
    bucket_61_90_count  = EXCLUDED.bucket_61_90_count,
    bucket_over_90_count= EXCLUDED.bucket_over_90_count,
    pre_petition_amount = EXCLUDED.pre_petition_amount,
    credit_limit        = EXCLUDED.credit_limit,
    utilization_pct     = EXCLUDED.utilization_pct;
END;
$$;

-- Refresh aging for ALL customers
CREATE OR REPLACE FUNCTION fn_refresh_all_ar_aging(p_as_of DATE DEFAULT CURRENT_DATE)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v_n INT := 0; v_id UUID;
BEGIN
  FOR v_id IN SELECT id FROM customers LOOP
    PERFORM fn_refresh_ar_aging(v_id, p_as_of);
    v_n := v_n + 1;
  END LOOP;
  RETURN v_n;
END;
$$;

-- ============================================================
-- TRIGGERS
-- ============================================================

CREATE TRIGGER trg_company_upd           BEFORE UPDATE ON company            FOR EACH ROW EXECUTE FUNCTION fn_updated_at();
CREATE TRIGGER trg_customers_upd         BEFORE UPDATE ON customers          FOR EACH ROW EXECUTE FUNCTION fn_updated_at();
CREATE TRIGGER trg_invoices_upd          BEFORE UPDATE ON invoices           FOR EACH ROW EXECUTE FUNCTION fn_updated_at();
CREATE TRIGGER trg_credit_metrics_upd    BEFORE UPDATE ON credit_metrics     FOR EACH ROW EXECUTE FUNCTION fn_updated_at();
CREATE TRIGGER trg_bankruptcy_upd        BEFORE UPDATE ON bankruptcy_details FOR EACH ROW EXECUTE FUNCTION fn_updated_at();
CREATE TRIGGER trg_growth_signals_upd    BEFORE UPDATE ON growth_signals     FOR EACH ROW EXECUTE FUNCTION fn_updated_at();
CREATE TRIGGER trg_sec_monitoring_upd    BEFORE UPDATE ON sec_monitoring     FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

CREATE TRIGGER trg_exposure_recalc
  AFTER INSERT OR UPDATE OR DELETE ON invoices
  FOR EACH ROW EXECUTE FUNCTION fn_trg_recalculate_exposure();

-- ============================================================
-- VIEWS
-- ============================================================

-- Current AR Aging Report (latest snapshot per customer)
CREATE OR REPLACE VIEW v_ar_aging_current AS
SELECT
  c.id                  AS customer_id,
  c.company_name,
  c.ticker,
  c.account_manager,
  c.scenario,
  c.payment_terms_days,
  a.snapshot_date,
  -- Amounts
  a.current_amount,
  a.bucket_1_30,
  a.bucket_31_60,
  a.bucket_61_90,
  a.bucket_over_90,
  a.pre_petition_amount,
  a.total_outstanding,
  -- Counts
  a.current_count,
  a.bucket_1_30_count,
  a.bucket_31_60_count,
  a.bucket_61_90_count,
  a.bucket_over_90_count,
  a.total_invoice_count,
  -- Metrics
  a.credit_limit,
  a.utilization_pct,
  a.dso_days,
  -- Risk tier (worst bucket)
  CASE
    WHEN a.bucket_over_90 > 0 OR a.pre_petition_amount > 0 THEN 'CRITICAL'
    WHEN a.bucket_61_90   > 0                               THEN 'HIGH'
    WHEN a.bucket_31_60   > 0                               THEN 'MEDIUM'
    WHEN a.bucket_1_30    > 0                               THEN 'LOW'
    ELSE 'CURRENT'
  END AS risk_tier
FROM customers c
JOIN LATERAL (
  SELECT * FROM ar_aging_snapshots s
  WHERE s.customer_id = c.id
  ORDER BY s.snapshot_date DESC LIMIT 1
) a ON true
ORDER BY
  CASE
    WHEN a.bucket_over_90 > 0 OR a.pre_petition_amount > 0 THEN 1
    WHEN a.bucket_61_90   > 0 THEN 2
    WHEN a.bucket_31_60   > 0 THEN 3
    WHEN a.bucket_1_30    > 0 THEN 4
    ELSE 5
  END,
  a.total_outstanding DESC;

-- Portfolio-level aging totals (the "summary row" at the bottom of the report)
CREATE OR REPLACE VIEW v_ar_aging_portfolio AS
SELECT
  COUNT(DISTINCT customer_id)                                                          AS customer_count,
  SUM(current_amount)                                                                  AS total_current,
  SUM(bucket_1_30)                                                                     AS total_1_30,
  SUM(bucket_31_60)                                                                    AS total_31_60,
  SUM(bucket_61_90)                                                                    AS total_61_90,
  SUM(bucket_over_90)                                                                  AS total_over_90,
  SUM(pre_petition_amount)                                                             AS total_pre_petition,
  SUM(total_outstanding)                                                               AS total_outstanding,
  ROUND(SUM(current_amount)::NUMERIC  / NULLIF(SUM(total_outstanding),0)*100, 1)     AS pct_current,
  ROUND(SUM(bucket_1_30)::NUMERIC    / NULLIF(SUM(total_outstanding),0)*100, 1)      AS pct_1_30,
  ROUND(SUM(bucket_31_60)::NUMERIC   / NULLIF(SUM(total_outstanding),0)*100, 1)      AS pct_31_60,
  ROUND(SUM(bucket_61_90)::NUMERIC   / NULLIF(SUM(total_outstanding),0)*100, 1)      AS pct_61_90,
  ROUND(SUM(bucket_over_90)::NUMERIC / NULLIF(SUM(total_outstanding),0)*100, 1)      AS pct_over_90,
  snapshot_date
FROM (
  SELECT DISTINCT ON (customer_id) * FROM ar_aging_snapshots
  ORDER BY customer_id, snapshot_date DESC
) latest
GROUP BY snapshot_date;

-- Portfolio KPI dashboard
CREATE OR REPLACE VIEW v_portfolio_overview AS
SELECT
  COUNT(*)                                                           AS total_customers,
  SUM(credit_limit)                                                  AS total_credit_limits,
  SUM(current_exposure)                                              AS total_exposure,
  ROUND(AVG(credit_limit))                                           AS avg_credit_limit,
  ROUND(SUM(current_exposure)::NUMERIC/NULLIF(SUM(credit_limit),0)*100,1) AS portfolio_utilization_pct,
  COUNT(*) FILTER (WHERE scenario = 'normal_operations')             AS normal_count,
  COUNT(*) FILTER (WHERE scenario = 'payment_issues')                AS payment_issues_count,
  COUNT(*) FILTER (WHERE scenario = 'credit_deterioration')          AS credit_deterioration_count,
  COUNT(*) FILTER (WHERE scenario = 'negative_news')                 AS negative_news_count,
  COUNT(*) FILTER (WHERE scenario = 'bankruptcy')                    AS bankruptcy_count,
  COUNT(*) FILTER (WHERE scenario = 'growth_opportunity')            AS growth_count,
  COUNT(*) FILTER (WHERE scenario = 'sec_filing_monitoring')         AS sec_monitoring_count,
  COUNT(*) FILTER (WHERE 'WATCH_LIST' = ANY(flags))                  AS watch_list_count,
  COUNT(*) FILTER (WHERE 'CREDIT_HOLD' = ANY(flags))                 AS credit_hold_count
FROM customers;

-- Customers at risk
CREATE OR REPLACE VIEW v_customers_at_risk AS
SELECT
  c.id,
  c.company_name,
  c.ticker,
  c.scenario,
  c.credit_limit,
  c.current_exposure,
  ROUND(c.current_exposure::NUMERIC/NULLIF(c.credit_limit,0)*100,1) AS utilization_pct,
  c.flags,
  c.notes,
  c.account_manager,
  cm.credit_score,
  cm.altman_z_score,
  -- Derived from payment_transactions (the real source)
  (SELECT ROUND(AVG(days_early_late))
   FROM payment_transactions pt WHERE pt.customer_id = c.id) AS avg_days_early_late,
  (SELECT ROUND(AVG(CASE WHEN paid_on_time THEN 1.0 ELSE 0.0 END)*100,1)
   FROM payment_transactions pt WHERE pt.customer_id = c.id) AS on_time_pct,
  -- Overdue summary
  (SELECT COUNT(*) FROM invoices i WHERE i.customer_id = c.id AND i.days_overdue > 0) AS overdue_invoice_count,
  (SELECT COALESCE(SUM(amount_outstanding),0) FROM invoices i WHERE i.customer_id = c.id AND i.days_overdue > 0) AS overdue_amount,
  (SELECT MAX(days_overdue) FROM invoices i WHERE i.customer_id = c.id) AS max_days_overdue
FROM customers c
LEFT JOIN credit_metrics cm ON cm.customer_id = c.id
WHERE c.scenario IN ('payment_issues','credit_deterioration','negative_news','bankruptcy')
   OR 'WATCH_LIST' = ANY(c.flags)
   OR 'CREDIT_HOLD' = ANY(c.flags)
ORDER BY
  CASE c.scenario
    WHEN 'bankruptcy'           THEN 1
    WHEN 'credit_deterioration' THEN 2
    WHEN 'payment_issues'       THEN 3
    WHEN 'negative_news'        THEN 4
    ELSE 5
  END, c.current_exposure DESC;

-- Overdue invoices with risk tier
CREATE OR REPLACE VIEW v_overdue_invoices AS
SELECT
  c.company_name,
  c.ticker,
  c.scenario,
  c.account_manager,
  i.invoice_number,
  i.invoice_amount,
  i.amount_paid,
  i.amount_outstanding,
  i.invoice_date,
  i.due_date,
  i.days_overdue,
  i.status,
  i.dunning_stage,
  i.next_dunning_date,
  i.escalated_to_collections,
  i.claimable,
  CASE
    WHEN i.days_overdue >= 90 THEN 'CRITICAL'
    WHEN i.days_overdue >= 60 THEN 'SEVERE'
    WHEN i.days_overdue >= 30 THEN 'WARNING'
    ELSE 'MONITOR'
  END AS risk_tier
FROM invoices i
JOIN customers c ON c.id = i.customer_id
WHERE i.days_overdue > 0
ORDER BY i.days_overdue DESC;

-- Payment behaviour analytics (computed from payment_transactions)
CREATE OR REPLACE VIEW v_payment_behaviour AS
SELECT
  c.id                  AS customer_id,
  c.company_name,
  c.ticker,
  c.payment_terms_days,
  c.account_manager,
  COUNT(pt.id)                                                         AS total_payments,
  COALESCE(SUM(pt.amount_paid),0)                                      AS total_paid_all_time,
  COALESCE(SUM(pt.amount_paid) FILTER (WHERE pt.payment_date >= CURRENT_DATE - INTERVAL '12 months'),0) AS total_paid_12mo,
  ROUND(AVG(pt.days_to_pay),1)                                         AS avg_days_to_pay,
  ROUND(AVG(pt.days_early_late),1)                                     AS avg_days_early_late,
  ROUND(AVG(CASE WHEN pt.paid_on_time THEN 1.0 ELSE 0.0 END)*100,1)   AS on_time_payment_pct,
  MAX(pt.payment_date)                                                  AS last_payment_date,
  (SELECT amount_paid FROM payment_transactions WHERE customer_id = c.id ORDER BY payment_date DESC LIMIT 1) AS last_payment_amount,
  -- Trend comparison
  ROUND(AVG(pt.days_to_pay) FILTER (WHERE pt.payment_date >= CURRENT_DATE - INTERVAL '6 months'),1) AS avg_days_to_pay_last_6mo,
  ROUND(AVG(pt.days_to_pay) FILTER (WHERE pt.payment_date BETWEEN CURRENT_DATE - INTERVAL '12 months' AND CURRENT_DATE - INTERVAL '6 months'),1) AS avg_days_to_pay_prior_6mo
FROM customers c
LEFT JOIN payment_transactions pt ON pt.customer_id = c.id
GROUP BY c.id, c.company_name, c.ticker, c.payment_terms_days, c.account_manager;

-- Growth opportunities
CREATE OR REPLACE VIEW v_growth_opportunities AS
SELECT
  c.id, c.company_name, c.ticker, c.credit_limit, c.current_exposure, c.account_manager,
  gs.growth_trajectory, gs.revenue_growth_yoy, gs.backlog_amount,
  gs.recommended_new_limit, gs.rationale, gs.upsell_opportunity, gs.recent_milestones
FROM customers c
JOIN growth_signals gs ON gs.customer_id = c.id
WHERE gs.credit_limit_increase_recommended = true
ORDER BY gs.recommended_new_limit DESC;

-- Bankruptcy claims
CREATE OR REPLACE VIEW v_bankruptcy_claims AS
SELECT
  c.company_name, c.ticker,
  bd.filing_date, bd.case_number, bd.court, bd.chapter, bd.status,
  bd.proof_of_claim_filed, bd.proof_of_claim_amount,
  bd.estimated_recovery_rate, bd.estimated_recovery_amount,
  bd.total_pre_petition_claim, bd.emergence_date_estimated,
  (SELECT COUNT(*)             FROM invoices i WHERE i.customer_id = c.id AND i.claimable = true) AS claimable_invoice_count,
  (SELECT COALESCE(SUM(amount_outstanding),0) FROM invoices i WHERE i.customer_id = c.id AND i.claimable = true) AS claimable_total
FROM customers c
JOIN bankruptcy_details bd ON bd.customer_id = c.id
ORDER BY bd.filing_date DESC;

-- SEC monitoring dashboard
CREATE OR REPLACE VIEW v_sec_monitoring_dashboard AS
SELECT
  c.company_name, c.ticker,
  sm.cik, sm.monitoring_active,
  sm.last_10k_date, sm.last_10q_date, sm.last_8k_date,
  sm.risk_signals_detected, sm.alert_triggered, sm.alert_date, sm.alert_action_taken,
  sm.next_scheduled_review,
  (SELECT COUNT(*) FROM sec_filings sf WHERE sf.customer_id = c.id) AS total_filings,
  (SELECT COUNT(*) FROM sec_filings sf WHERE sf.customer_id = c.id AND sf.reviewed = false) AS unreviewed_filings
FROM customers c
JOIN sec_monitoring sm ON sm.customer_id = c.id
WHERE sm.monitoring_active = true
ORDER BY sm.alert_triggered DESC, sm.last_10q_date DESC;

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_customers_scenario    ON customers(scenario);
CREATE INDEX idx_customers_acct_mgr    ON customers(account_manager);
CREATE INDEX idx_customers_flags       ON customers USING GIN(flags);
CREATE INDEX idx_customers_ticker      ON customers(ticker) WHERE ticker IS NOT NULL;
CREATE INDEX idx_customers_cik         ON customers(sec_cik) WHERE sec_cik IS NOT NULL;
CREATE INDEX idx_customers_name_trgm   ON customers USING GIN(company_name gin_trgm_ops);

CREATE INDEX idx_invoices_customer     ON invoices(customer_id);
CREATE INDEX idx_invoices_status       ON invoices(status);
CREATE INDEX idx_invoices_overdue      ON invoices(days_overdue) WHERE days_overdue > 0;
CREATE INDEX idx_invoices_due_date     ON invoices(due_date);

CREATE INDEX idx_pmttxn_customer       ON payment_transactions(customer_id);
CREATE INDEX idx_pmttxn_invoice        ON payment_transactions(invoice_id) WHERE invoice_id IS NOT NULL;
CREATE INDEX idx_pmttxn_date           ON payment_transactions(payment_date);
CREATE INDEX idx_pmttxn_on_time        ON payment_transactions(paid_on_time);

CREATE INDEX idx_aging_cust_date       ON ar_aging_snapshots(customer_id, snapshot_date DESC);
CREATE INDEX idx_aging_date            ON ar_aging_snapshots(snapshot_date);

CREATE INDEX idx_actions_customer      ON credit_actions(customer_id);
CREATE INDEX idx_actions_date          ON credit_actions(action_date);
CREATE INDEX idx_actions_type          ON credit_actions(action_type);

CREATE INDEX idx_events_customer       ON credit_events(customer_id);
CREATE INDEX idx_events_type           ON credit_events(event_type);

CREATE INDEX idx_news_customer         ON negative_news(customer_id);
CREATE INDEX idx_news_date             ON negative_news(news_date);
CREATE INDEX idx_news_severity         ON negative_news(severity);
CREATE INDEX idx_news_unreviewed       ON negative_news(reviewed) WHERE reviewed = false;

CREATE INDEX idx_cm_customer           ON credit_metrics(customer_id);
CREATE INDEX idx_cm_score              ON credit_metrics(credit_score);
CREATE INDEX idx_cm_altman             ON credit_metrics(altman_z_score);
CREATE INDEX idx_cmc_customer_date     ON credit_metric_changes(customer_id, change_date);

CREATE INDEX idx_sec_mon_cik           ON sec_monitoring(cik);
CREATE INDEX idx_sec_mon_alert         ON sec_monitoring(alert_triggered) WHERE alert_triggered = true;
CREATE INDEX idx_sec_filings_customer  ON sec_filings(customer_id);
CREATE INDEX idx_sec_filings_date      ON sec_filings(filing_date);

-- ============================================================
-- ROW LEVEL SECURITY (Supabase)
-- ============================================================

DO $$
DECLARE t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'company','customers','invoices','payment_transactions',
    'ar_aging_snapshots','credit_metrics','credit_metric_changes',
    'credit_actions','credit_events','negative_news',
    'bankruptcy_details','growth_signals','sec_monitoring','sec_filings'
  ]) LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format(
      'CREATE POLICY "auth_select" ON %I FOR SELECT USING (auth.role() = ''authenticated'')', t
    );
    EXECUTE format(
      'CREATE POLICY "service_all" ON %I USING (auth.role() = ''service_role'')', t
    );
  END LOOP;
END $$;
