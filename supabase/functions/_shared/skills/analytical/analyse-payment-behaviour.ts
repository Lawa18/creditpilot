/**
 * @skill analyse-payment-behaviour
 * @type analytical
 * @description Analyses a customer's payment transaction history to derive behavioural
 *   metrics: on-time rate, average days early/late, trend, and an overall health signal.
 *   Uses the second half of the transaction history vs the first half to detect trend.
 * @input PaymentTransaction[] — array of payment records with timing and on_time flag
 * @output PaymentBehaviourResult — derived metrics and trend/health classification
 * @usedBy ar-aging-agent, credit-limit-review-agent (planned)
 */

export interface PaymentTransaction {
  payment_date: string;
  days_to_pay: number;
  days_early_late: number; // negative = paid early, positive = paid late
  on_time: boolean;
  amount: number;
}

export interface PaymentBehaviourResult {
  on_time_rate: number;        // 0–1
  avg_days_early_late: number; // negative = pays early on average
  avg_days_to_pay: number;
  trend: "improving" | "stable" | "deteriorating" | "insufficient_data";
  total_transactions: number;
  recent_on_time_rate: number; // last 3 transactions only
  health: "healthy" | "watch" | "at_risk";
}

export function analysePaymentBehaviour(
  transactions: PaymentTransaction[]
): PaymentBehaviourResult {
  if (!transactions || transactions.length === 0) {
    return {
      on_time_rate: 1,
      avg_days_early_late: 0,
      avg_days_to_pay: 30,
      trend: "insufficient_data",
      total_transactions: 0,
      recent_on_time_rate: 1,
      health: "healthy",
    };
  }

  // Sort ascending by payment date so trend comparison is chronological
  const sorted = [...transactions].sort(
    (a, b) => new Date(a.payment_date).getTime() - new Date(b.payment_date).getTime()
  );

  const total = sorted.length;
  const onTimeCount = sorted.filter((t) => t.on_time).length;
  const on_time_rate = onTimeCount / total;

  const avg_days_early_late =
    sorted.reduce((sum, t) => sum + (t.days_early_late ?? 0), 0) / total;

  const avg_days_to_pay =
    sorted.reduce((sum, t) => sum + (t.days_to_pay ?? 0), 0) / total;

  // Recent on-time rate: last 3 transactions
  const recent = sorted.slice(-3);
  const recent_on_time_rate =
    recent.filter((t) => t.on_time).length / recent.length;

  // Trend: compare average days_early_late in the first half vs second half
  let trend: PaymentBehaviourResult["trend"] = "insufficient_data";
  if (total >= 2) {
    const half = Math.ceil(total / 2);
    const earlyHalfAvg =
      sorted.slice(0, half).reduce((s, t) => s + t.days_early_late, 0) / half;
    const lateHalfAvg =
      sorted.slice(half).reduce((s, t) => s + t.days_early_late, 0) /
      (total - half);

    const delta = lateHalfAvg - earlyHalfAvg;
    if (delta > 5) trend = "deteriorating";
    else if (delta < -5) trend = "improving";
    else trend = "stable";
  }

  // Health signal: at_risk if on_time_rate low or trend deteriorating
  let health: PaymentBehaviourResult["health"] = "healthy";
  if (on_time_rate < 0.6 || trend === "deteriorating") health = "at_risk";
  else if (on_time_rate < 0.85 || avg_days_early_late > 10) health = "watch";

  return {
    on_time_rate,
    avg_days_early_late: Math.round(avg_days_early_late * 10) / 10,
    avg_days_to_pay: Math.round(avg_days_to_pay * 10) / 10,
    trend,
    total_transactions: total,
    recent_on_time_rate,
    health,
  };
}
