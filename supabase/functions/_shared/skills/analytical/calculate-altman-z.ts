/**
 * @skill calculate-altman-z
 * @type analytical
 * @description Calculates the Altman Z-score for public companies — a widely-used predictor
 *   of corporate bankruptcy risk over a 2-year horizon.
 *
 *   Formula: Z = 1.2*X1 + 1.4*X2 + 3.3*X3 + 0.6*X4 + 1.0*X5
 *     X1 = Working Capital / Total Assets
 *     X2 = Retained Earnings / Total Assets
 *     X3 = EBIT / Total Assets
 *     X4 = Market Value of Equity / Total Liabilities
 *     X5 = Revenue / Total Assets
 *
 *   Zones: Safe > 2.99 | Grey 1.81–2.99 | Distress < 1.81
 *
 * @input AltmanZInput — five financial statement components
 * @output AltmanZResult — z_score, zone, and the five intermediate ratios
 * @usedBy credit-limit-review-agent (planned), onboarding-agent (planned)
 */

export interface AltmanZInput {
  working_capital: number;
  total_assets: number;
  retained_earnings: number;
  ebit: number;
  market_value_equity: number;
  total_liabilities: number;
  revenue: number;
}

export type AltmanZZone = "safe" | "grey" | "distress";

export interface AltmanZResult {
  z_score: number;
  zone: AltmanZZone;
  x1: number; // Working Capital / Total Assets
  x2: number; // Retained Earnings / Total Assets
  x3: number; // EBIT / Total Assets
  x4: number; // Market Value Equity / Total Liabilities
  x5: number; // Revenue / Total Assets
}

export function calculateAltmanZ(input: AltmanZInput): AltmanZResult {
  const {
    working_capital,
    total_assets,
    retained_earnings,
    ebit,
    market_value_equity,
    total_liabilities,
    revenue,
  } = input;

  // Guard against division by zero
  if (!total_assets || total_assets === 0 || !total_liabilities || total_liabilities === 0) {
    return { z_score: 0, zone: "distress", x1: 0, x2: 0, x3: 0, x4: 0, x5: 0 };
  }

  const x1 = working_capital / total_assets;
  const x2 = retained_earnings / total_assets;
  const x3 = ebit / total_assets;
  const x4 = market_value_equity / total_liabilities;
  const x5 = revenue / total_assets;

  const z_score = 1.2 * x1 + 1.4 * x2 + 3.3 * x3 + 0.6 * x4 + 1.0 * x5;

  let zone: AltmanZZone;
  if (z_score > 2.99) zone = "safe";
  else if (z_score >= 1.81) zone = "grey";
  else zone = "distress";

  const r4 = (v: number) => Math.round(v * 10000) / 10000;

  return {
    z_score: Math.round(z_score * 100) / 100,
    zone,
    x1: r4(x1),
    x2: r4(x2),
    x3: r4(x3),
    x4: r4(x4),
    x5: r4(x5),
  };
}
