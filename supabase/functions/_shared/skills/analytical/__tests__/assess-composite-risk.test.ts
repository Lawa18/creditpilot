import { describe, it, expect } from "vitest";
import { assessCompositeRisk } from "../assess-composite-risk";

describe("assessCompositeRisk", () => {
  // ── No signals ──────────────────────────────────────────────────────────────

  it("no signals, good credit score → info severity, no action", () => {
    const result = assessCompositeRisk({
      utilization_pct: 70,
      credit_score: 75,
      active_event_types: [],
      agents_flagging: [],
    });
    expect(result.severity).toBe("info");
    expect(result.recommend_action).toBe(false);
    expect(result.adjusted_threshold).toBe(85);
    expect(result.adjustments).toHaveLength(0);
  });

  // ── Single signal — threshold adjustment ────────────────────────────────────

  it("NEGATIVE_NEWS_HIGH → threshold drops to 75%, util 74% → no action", () => {
    const result = assessCompositeRisk({
      utilization_pct: 74,
      credit_score: 60,
      active_event_types: ["NEGATIVE_NEWS_HIGH"],
      agents_flagging: ["news-monitor-agent"],
    });
    expect(result.adjusted_threshold).toBe(75);
    expect(result.recommend_action).toBe(false);
    expect(result.severity).toBe("medium");
  });

  it("NEGATIVE_NEWS_HIGH → threshold 75%, util 76% → recommend action, medium severity", () => {
    const result = assessCompositeRisk({
      utilization_pct: 76,
      credit_score: 60,
      active_event_types: ["NEGATIVE_NEWS_HIGH"],
      agents_flagging: ["news-monitor-agent"],
    });
    expect(result.adjusted_threshold).toBe(75);
    expect(result.recommend_action).toBe(true);
    expect(result.severity).toBe("medium");
  });

  // ── Multi-signal threshold stacking ─────────────────────────────────────────

  it("NEGATIVE_NEWS_HIGH + COVENANT_WAIVER → threshold 65% (−10 −10)", () => {
    const result = assessCompositeRisk({
      utilization_pct: 64,
      credit_score: 50,
      active_event_types: ["NEGATIVE_NEWS_HIGH", "COVENANT_WAIVER"],
      agents_flagging: ["news-monitor-agent", "sec-monitor-agent"],
    });
    expect(result.adjusted_threshold).toBe(65);
    expect(result.recommend_action).toBe(false); // util 64 < threshold 65
    expect(result.severity).toBe("high"); // 2 agents
  });

  it("NEGATIVE_NEWS_HIGH + COVENANT_WAIVER + GOING_CONCERN_WARNING → threshold 50% (−10 −10 −15)", () => {
    const result = assessCompositeRisk({
      utilization_pct: 51,
      credit_score: 45,
      active_event_types: ["NEGATIVE_NEWS_HIGH", "COVENANT_WAIVER", "GOING_CONCERN_WARNING"],
      agents_flagging: ["news-monitor-agent", "sec-monitor-agent", "ar-aging-agent"],
    });
    expect(result.adjusted_threshold).toBe(50);
    expect(result.recommend_action).toBe(true); // util 51 >= threshold 50, also 3 agents
    expect(result.severity).toBe("critical"); // 3 agents
  });

  // ── Distress credit score ────────────────────────────────────────────────────

  it("credit_score < 20 with any active signal → recommend_action true regardless of util", () => {
    const result = assessCompositeRisk({
      utilization_pct: 30, // well below any threshold
      credit_score: 15,
      active_event_types: ["CEO_DEPARTURE"],
      agents_flagging: ["news-monitor-agent"],
    });
    expect(result.recommend_action).toBe(true);
    expect(result.severity).toBe("high"); // 1 agent + distress score
  });

  it("credit_score < 20 but NO active signals → no forced action", () => {
    const result = assessCompositeRisk({
      utilization_pct: 30,
      credit_score: 10,
      active_event_types: [],
      agents_flagging: [],
    });
    // inDistress && hasActiveSignals = false; util 30 < adjusted_threshold 70 (85-15)
    expect(result.recommend_action).toBe(false);
    expect(result.adjusted_threshold).toBe(70);
  });

  // ── Agent count severity ─────────────────────────────────────────────────────

  it("3 agents flagging → critical severity and recommend_action true", () => {
    const result = assessCompositeRisk({
      utilization_pct: 50,
      credit_score: 55,
      active_event_types: ["OVERDUE_BUCKET_OVER_90", "NEGATIVE_NEWS_HIGH", "COVENANT_WAIVER"],
      agents_flagging: ["ar-aging-agent", "news-monitor-agent", "sec-monitor-agent"],
    });
    expect(result.severity).toBe("critical");
    expect(result.recommend_action).toBe(true);
  });

  // ── Threshold floor ──────────────────────────────────────────────────────────

  it("many signals combined cannot push threshold below 40% floor", () => {
    const result = assessCompositeRisk({
      utilization_pct: 35,
      credit_score: 10, // distress −15pp
      active_event_types: [
        "NEGATIVE_NEWS_CRITICAL", // −10pp
        "GOING_CONCERN_WARNING",  // −15pp
        "COVENANT_WAIVER",        // −10pp
        "CEO_DEPARTURE",          // −5pp
      ],
      agents_flagging: ["ar-aging-agent", "news-monitor-agent", "sec-monitor-agent"],
    });
    // Raw delta: 10+15+10+5+15 = 55pp → 85-55 = 30, but floor is 40
    expect(result.adjusted_threshold).toBe(40);
  });
});
