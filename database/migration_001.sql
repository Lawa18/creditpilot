-- ============================================================
-- MIGRATION 001 — Agent infrastructure tables
-- Run this in Supabase SQL Editor
-- ============================================================

-- ── 1. AGENT RUNS ─────────────────────────────────────────────
-- One row per agent execution. Powers the demo page run log.

CREATE TABLE agent_runs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id          UUID NOT NULL DEFAULT gen_random_uuid(), -- shared across all writes in one run
  agent_name      TEXT NOT NULL,                           -- 'ar_aging_agent' | 'news_monitor_agent' | 'sec_monitor_agent'
  status          TEXT NOT NULL DEFAULT 'running'          -- 'running' | 'completed' | 'failed'
                    CHECK (status IN ('running','completed','failed')),
  started_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at    TIMESTAMPTZ,
  customers_scanned INT DEFAULT 0,
  conditions_found  INT DEFAULT 0,
  messages_composed INT DEFAULT 0,
  actions_taken     INT DEFAULT 0,
  summary         TEXT,                                    -- agent's own written summary
  error_message   TEXT,                                    -- if status = 'failed'
  triggered_by    TEXT DEFAULT 'manual'                    -- 'manual' | 'schedule' | 'webhook'
);

-- ── 2. AGENT MESSAGES ──────────────────────────────────────────
-- Every communication the agent composes — email, Teams card, internal alert.
-- Storing the composed text is the core output. Actual delivery is optional.

CREATE TABLE agent_messages (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id          UUID NOT NULL REFERENCES agent_runs(id) ON DELETE CASCADE,
  customer_id     UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  agent_name      TEXT NOT NULL,

  -- What kind of message
  channel         TEXT NOT NULL DEFAULT 'email'
                    CHECK (channel IN ('email','teams','internal')),
  template_type   TEXT NOT NULL,
                  -- 'dunning_1' | 'dunning_2' | 'dunning_3' | 'dunning_4'
                  -- 'credit_limit_alert' | 'watch_list_alert'
                  -- 'news_alert' | 'sec_alert'
                  -- 'collections_referral' | 'account_manager_alert'

  -- Who it goes to
  recipient_type  TEXT NOT NULL DEFAULT 'customer'
                    CHECK (recipient_type IN ('customer','account_manager','credit_committee')),
  recipient_name  TEXT,                                    -- rendered name
  recipient_email TEXT,                                    -- rendered email (may be placeholder in demo)

  -- The actual content
  subject         TEXT,                                    -- email subject line
  body            TEXT NOT NULL,                           -- full message body

  -- Delivery
  status          TEXT NOT NULL DEFAULT 'draft'
                    CHECK (status IN ('draft','sent','delivered','failed')),
  delivered_via   TEXT,                                    -- null | 'resend' | 'teams_webhook' | 'demo_only'
  sent_at         TIMESTAMPTZ,

  -- Context
  invoice_ids     UUID[],                                  -- invoices referenced in this message
  metadata        JSONB DEFAULT '{}',                      -- any extra context the agent wants to store

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 3. PENDING ACTIONS ─────────────────────────────────────────
-- Agent-proposed actions that need human approval before executing.
-- e.g. credit limit reductions, credit holds, watch list additions.

CREATE TABLE pending_actions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id          UUID NOT NULL REFERENCES agent_runs(id) ON DELETE CASCADE,
  customer_id     UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  agent_name      TEXT NOT NULL,
  message_id      UUID REFERENCES agent_messages(id) ON DELETE SET NULL,  -- the alert that triggered this

  -- What the agent wants to do
  action_type     TEXT NOT NULL,                           -- uses same enum as credit_actions
  rationale       TEXT NOT NULL,                           -- agent's written explanation

  -- For credit limit changes
  current_value   BIGINT,                                  -- current credit_limit
  proposed_value  BIGINT,                                  -- proposed new credit_limit

  -- Review
  status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending','approved','rejected','expired')),
  reviewed_by     TEXT,
  reviewed_at     TIMESTAMPTZ,
  review_note     TEXT,                                    -- human's comment on approval/rejection
  expires_at      TIMESTAMPTZ DEFAULT (now() + INTERVAL '7 days'),

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── TRIGGERS — updated_at ──────────────────────────────────────

CREATE TRIGGER trg_agent_runs_upd
  BEFORE UPDATE ON agent_runs
  FOR EACH ROW EXECUTE FUNCTION fn_updated_at();

-- ── INDEXES ────────────────────────────────────────────────────

CREATE INDEX idx_agent_runs_agent     ON agent_runs(agent_name);
CREATE INDEX idx_agent_runs_status    ON agent_runs(status);
CREATE INDEX idx_agent_runs_started   ON agent_runs(started_at DESC);

CREATE INDEX idx_agent_msgs_run       ON agent_messages(run_id);
CREATE INDEX idx_agent_msgs_customer  ON agent_messages(customer_id);
CREATE INDEX idx_agent_msgs_agent     ON agent_messages(agent_name);
CREATE INDEX idx_agent_msgs_channel   ON agent_messages(channel);
CREATE INDEX idx_agent_msgs_status    ON agent_messages(status);
CREATE INDEX idx_agent_msgs_created   ON agent_messages(created_at DESC);

CREATE INDEX idx_pending_run          ON pending_actions(run_id);
CREATE INDEX idx_pending_customer     ON pending_actions(customer_id);
CREATE INDEX idx_pending_status       ON pending_actions(status) WHERE status = 'pending';
CREATE INDEX idx_pending_created      ON pending_actions(created_at DESC);

-- ── ROW LEVEL SECURITY ─────────────────────────────────────────

DO $$
DECLARE t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'agent_runs', 'agent_messages', 'pending_actions'
  ]) LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format(
      'CREATE POLICY "auth_select" ON %I FOR SELECT USING (auth.role() = ''authenticated'')', t
    );
    EXECUTE format(
      'CREATE POLICY "service_all" ON %I USING (auth.role() = ''service_role'')', t
    );
    -- Allow anon reads for the public demo page
    EXECUTE format(
      'CREATE POLICY "anon_select" ON %I FOR SELECT USING (auth.role() = ''anon'')', t
    );
  END LOOP;
END $$;

-- ── REALTIME ───────────────────────────────────────────────────
-- Enable realtime on these tables so the demo page updates live
-- as the agent writes rows

ALTER PUBLICATION supabase_realtime ADD TABLE agent_runs;
ALTER PUBLICATION supabase_realtime ADD TABLE agent_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE pending_actions;

-- ── VERIFY ─────────────────────────────────────────────────────

SELECT table_name, 
       (SELECT COUNT(*) FROM information_schema.columns 
        WHERE table_name = t.table_name 
        AND table_schema = 'public') AS column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_name IN ('agent_runs','agent_messages','pending_actions')
ORDER BY table_name;
