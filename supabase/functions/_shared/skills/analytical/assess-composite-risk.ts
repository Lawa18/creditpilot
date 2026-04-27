/**
 * @skill assess-composite-risk
 * @type analytical
 * @description Evaluates composite credit risk by combining AR aging signals, news signals,
 *   SEC signals, and normalised credit score. Adjusts the utilization action threshold
 *   downward based on active negative signals, allowing multi-signal convergence to trigger
 *   earlier intervention than any single signal would alone.
 *
 *   Base threshold: 85% utilization triggers action.
 *   Adjustments (cumulative, floor at 40%):
 *     NEGATIVE_NEWS_HIGH or NEGATIVE_NEWS_CRITICAL   −10pp
 *     GOING_CONCERN_WARNING                          −15pp
 *     COVENANT_WAIVER                                −10pp
 *     CEO_DEPARTURE                                  −5pp
 *     credit_score < 20 (distress)                   −15pp
 *     credit_score 20–40 (concern)                   −5pp
 *
 *   recommend_action is true when:
 *     utilization_pct >= adjusted_threshold, OR
 *     credit_score < 20 AND at least one signal is active, OR
 *     3+ distinct agents have flagged the same customer
 *
 *   Severity:
 *     3+ agents flagging       → critical
 *     2 agents flagging        → high
 *     1 agent + score < 20    → high
 *     1 agent only             → medium
 *     no signals               → info
 *
 * @input CompositeRiskInput
 * @output CompositeRiskResult
 * @usedBy cia-agent (briefing mode, Step 6b)
 */

export interface CompositeRiskInput {
  utilization_pct: number;
  credit_score?: number | null;
  /** Event types currently active for this customer (from credit_events.event_type) */
  active_event_types: string[];
  /** Unique source agents that have flagged this customer in the current run */
  agents_flagging: string[];
}

export interface CompositeRiskResult {
  adjusted_threshold: number;
  recommend_action: boolean;
  severity: "critical" | "high" | "medium" | "info";
  rationale: string;
  adjustments: string[];
}

const BASE_THRESHOLD = 85;
const THRESHOLD_FLOOR = 40;

export function assessCompositeRisk(input: CompositeRiskInput): CompositeRiskResult {
  const {
    utilization_pct,
    credit_score = null,
    active_event_types,
    agents_flagging,
  } = input;

  const adjustments: string[] = [];
  let delta = 0;

  // Signal-driven threshold adjustments
  if (active_event_types.includes("NEGATIVE_NEWS_HIGH") || active_event_types.includes("NEGATIVE_NEWS_CRITICAL")) {
    delta += 10;
    adjustments.push("NEGATIVE_NEWS (−10pp)");
  }

  if (active_event_types.includes("GOING_CONCERN_WARNING")) {
    delta += 15;
    adjustments.push("GOING_CONCERN_WARNING (−15pp)");
  }

  if (active_event_types.includes("COVENANT_WAIVER")) {
    delta += 10;
    adjustments.push("COVENANT_WAIVER (−10pp)");
  }

  if (active_event_types.includes("CEO_DEPARTURE")) {
    delta += 5;
    adjustments.push("CEO_DEPARTURE (−5pp)");
  }

  // Credit score threshold adjustments
  if (credit_score !== null && credit_score < 20) {
    delta += 15;
    adjustments.push(`credit_score distress <20 (−15pp)`);
  } else if (credit_score !== null && credit_score >= 20 && credit_score <= 40) {
    delta += 5;
    adjustments.push(`credit_score concern 20–40 (−5pp)`);
  }

  const adjusted_threshold = Math.max(THRESHOLD_FLOOR, BASE_THRESHOLD - delta);

  // Determine whether action is recommended
  const hasActiveSignals = active_event_types.length > 0;
  const inDistress = credit_score !== null && credit_score < 20;
  const multiAgent = agents_flagging.length >= 3;

  const recommend_action =
    utilization_pct >= adjusted_threshold ||
    (inDistress && hasActiveSignals) ||
    multiAgent;

  // Determine severity
  let severity: CompositeRiskResult["severity"];
  if (agents_flagging.length >= 3) {
    severity = "critical";
  } else if (agents_flagging.length === 2) {
    severity = "high";
  } else if (agents_flagging.length === 1 && inDistress) {
    severity = "high";
  } else if (agents_flagging.length >= 1) {
    severity = "medium";
  } else {
    severity = "info";
  }

  // Build rationale
  const parts: string[] = [];

  if (adjustments.length > 0) {
    parts.push(`Threshold adjusted from ${BASE_THRESHOLD}% to ${adjusted_threshold}% due to: ${adjustments.join(", ")}.`);
  } else {
    parts.push(`No active signals; utilization threshold remains at ${BASE_THRESHOLD}%.`);
  }

  if (utilization_pct >= adjusted_threshold) {
    parts.push(`Utilization ${utilization_pct}% meets or exceeds adjusted threshold ${adjusted_threshold}%.`);
  }

  if (inDistress && hasActiveSignals) {
    parts.push(`Distress credit score (${credit_score}) with active signals — immediate review warranted.`);
  }

  if (agents_flagging.length >= 2) {
    parts.push(`${agents_flagging.length} agents flagging (${agents_flagging.join(", ")}) — multi-signal convergence.`);
  }

  if (!recommend_action) {
    parts.push("No action required at this time.");
  }

  return {
    adjusted_threshold,
    recommend_action,
    severity,
    rationale: parts.join(" "),
    adjustments,
  };
}
