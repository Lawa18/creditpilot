import { supabase } from "@/integrations/supabase/client";

const SEED_CREDIT_LIMITS = [
  { id: "c0000001-0000-0000-0000-000000000029", limit: 3000000 },
  { id: "c0000001-0000-0000-0000-000000000008", limit: 4500000 },
  { id: "c0000001-0000-0000-0000-000000000005", limit: 5000000 },
];

/**
 * Full demo reset + agent invocation.
 * Called by both the Reset Demo button (Actions.tsx) and the
 * session-based auto-init on first page load (App.tsx).
 */
export async function initDemo() {
  // ── 1. Reset all tables to seed state ────────────────────────────────────

  await supabase
    .from("pending_actions")
    .update({ status: "pending", reviewed_by: null, reviewed_at: null, review_note: null })
    .eq("is_demo", true);

  await supabase
    .from("agent_messages")
    .update({ status: "pending" })
    .eq("is_demo", true);

  for (const { id, limit } of SEED_CREDIT_LIMITS) {
    await supabase.from("customers").update({ credit_limit: limit }).eq("id", id);
  }

  await supabase
    .from("sec_monitoring")
    .update({ alert_triggered: true })
    .in("customer_id", [
      "c0000001-0000-0000-0000-000000000021",
      "c0000001-0000-0000-0000-000000000049",
    ]);

  await supabase
    .from("negative_news")
    .update({ reviewed: false, reviewed_by: null, reviewed_at: null })
    .not("id", "is", null);

  await supabase
    .from("credit_events")
    .update({ cia_processed: false, cia_processed_at: null })
    .eq("is_demo", true);

  // ── 2. Invoke all agents ──────────────────────────────────────────────────

  await Promise.all([
    supabase.functions.invoke("ar-aging-agent", { body: { triggered_by: "auto" } }),
    supabase.functions.invoke("news-monitor-agent", { body: { triggered_by: "auto" } }),
    supabase.functions.invoke("sec-monitor-agent", { body: { triggered_by: "auto" } }),
  ]);
  await supabase.functions.invoke("cia-agent", { body: {} });

  // ── 3. Mark demo as initialized ───────────────────────────────────────────

  sessionStorage.setItem("demo_initialized", "true");
  sessionStorage.setItem("demo_activated", "true");
  sessionStorage.setItem(
    "demo_agents",
    JSON.stringify(["ar_aging_agent", "news_monitor_agent", "sec_monitor_agent"])
  );
}
