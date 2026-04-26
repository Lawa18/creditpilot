/**
 * @skill calculate-credit-limit-proposal
 * @type analytical
 * @description Proposes a revised credit limit based on utilization, overdue balance,
 *   normalised credit score (0–100), and whether the customer is a preferred account.
 *   Enforces a minimum 25% reduction once criteria for action are met.
 *   Preferred customers receive 10pp latitude on utilization thresholds.
 *
 *   Credit score thresholds:
 *     < 20  → treat as distress
 *     20–40 → treat as grey / concern
 *     > 40  → treat as safe
 *     null  → use utilization and payment behaviour only
 *
 * @input CreditLimitInput — current limit, exposure metrics, financial health indicators
 * @output CreditLimitProposal — proposed limit, reduction %, action, and rationale
 * @usedBy ar-aging-agent, credit-limit-review-agent (planned)
 */

export interface CreditLimitInput {
  current_limit: number;
  current_exposure: number;
  days_over_90: number;
  utilization_pct: number;          // 0–100
  credit_score?: number | null;     // 0–100 normalised score; null = unavailable
  is_preferred_customer?: boolean;
  on_time_rate?: number;            // 0–1, from payment history
}

export interface CreditLimitProposal {
  proposed_limit: number;
  reduction_pct: number;            // percentage points reduced; 0 = no action
  action: "reduce" | "no_action";
  rationale: string;
}

export function calculateCreditLimitProposal(
  input: CreditLimitInput
): CreditLimitProposal {
  const {
    current_limit,
    days_over_90,
    utilization_pct,
    credit_score = null,
    is_preferred_customer = false,
    on_time_rate = 1,
  } = input;

  if (!current_limit || current_limit <= 0) {
    return {
      proposed_limit: 0,
      reduction_pct: 0,
      action: "no_action",
      rationale: "No credit limit set.",
    };
  }

  // Map normalised credit score to risk category
  const inDistress = credit_score !== null && credit_score < 20;
  const inGrey = credit_score !== null && credit_score >= 20 && credit_score <= 40;
  const highOverdue = days_over_90 > 50_000;

  // Preferred customers get 10pp latitude — thresholds are higher before action triggers
  const highUtilThreshold = is_preferred_customer ? 80 : 70;
  const criticalUtilThreshold = is_preferred_customer ? 90 : 85;
  const highUtil = utilization_pct > highUtilThreshold;
  const criticalUtil = utilization_pct > criticalUtilThreshold;

  let reductionFactor = 0;
  let rationale = "";

  if (inDistress && highOverdue) {
    reductionFactor = is_preferred_customer ? 0.40 : 0.50;
    rationale = `Customer credit score in distress range (${credit_score}) with $${(days_over_90 / 1000).toFixed(0)}K over 90 days past due. Significant limit reduction warranted.`;
  } else if (inDistress && highUtil) {
    reductionFactor = is_preferred_customer ? 0.30 : 0.40;
    rationale = `Distress credit score (${credit_score}) with ${utilization_pct}% utilization. Limit reduction to protect exposure.`;
  } else if (criticalUtil && highOverdue) {
    reductionFactor = is_preferred_customer ? 0.25 : 0.35;
    rationale = `Critical utilization (${utilization_pct}%) combined with $${(days_over_90 / 1000).toFixed(0)}K over 90 days.`;
  } else if (highUtil && highOverdue) {
    reductionFactor = is_preferred_customer ? 0.20 : 0.30;
    rationale = `High utilization (${utilization_pct}%) with $${(days_over_90 / 1000).toFixed(0)}K overdue balance.`;
  } else if (inGrey && highOverdue && on_time_rate < 0.7) {
    reductionFactor = 0.25;
    rationale = `Credit score in concern range (${credit_score}) with declining payment behaviour (on-time rate ${Math.round(on_time_rate * 100)}%) and overdue balance.`;
  }

  if (reductionFactor === 0) {
    return {
      proposed_limit: current_limit,
      reduction_pct: 0,
      action: "no_action",
      rationale: "No credit limit reduction warranted at this time.",
    };
  }

  // Enforce minimum 25% reduction for non-preferred customers once action is triggered
  if (!is_preferred_customer && reductionFactor < 0.25) {
    reductionFactor = 0.25;
  }

  const proposed_limit = Math.round(current_limit * (1 - reductionFactor));
  const reduction_pct = Math.round(reductionFactor * 100);

  return { proposed_limit, reduction_pct, action: "reduce", rationale };
}
