/**
 * @skill aggregate-credit-scores
 * @type analytical
 * @description Combines multiple normalised credit scores into one authoritative 0–100 score.
 *   Higher = lower risk. Confidence reflects number of valid sources.
 *   - 1 source  → confidence = 'low'
 *   - 2 sources → confidence = 'medium'
 *   - 3+ sources → confidence = 'high'
 *   Empty input → score 50, confidence 'low'.
 *   Never throws.
 * @input CreditSignal[] — any mix of providers
 * @output AggregatedScore — weighted final score, confidence, per-source breakdown
 * @usedBy ar-aging-agent, cia-agent
 */

import {
  normaliseCreditSignal,
  CreditSignal,
} from "./normalise-credit-signal.ts";

// ─── Types ────────────────────────────────────────────────────────────────────

export interface AggregatedScore {
  final_score: number;                              // 0–100, weighted average
  confidence: "high" | "medium" | "low";           // high = 3+ sources
  source_count: number;
  interpretation: "very_safe" | "safe" | "watch" | "concern" | "high_risk";
  sources: {
    provider: string;
    raw_score: string | number;
    normalised_score: number;
    weight: number;
  }[];
}

// ─── Provider weights ─────────────────────────────────────────────────────────
// Higher = more authoritative. Unknown providers default to 0.5.

const PROVIDER_WEIGHTS: Record<string, number> = {
  moodys: 1.0,
  sp_fitch: 1.0,
  coface: 0.9,
  atradius: 0.9,
  euler_hermes: 0.9,
  dnb_paydex: 0.8,
  experian_intelliscore: 0.7,
  dnb_failure_score: 0.7,
  equifax_business: 0.7,
  internal_payment_score: 0.5,
  manual: 0.5,
  altman_z: 0.4,
  estimated: 0.3,
};

const FALLBACK_WEIGHT = 0.5;

// ─── Helpers ──────────────────────────────────────────────────────────────────

function toInterpretation(score: number): AggregatedScore["interpretation"] {
  if (score >= 80) return "very_safe";
  if (score >= 60) return "safe";
  if (score >= 40) return "watch";
  if (score >= 20) return "concern";
  return "high_risk";
}

function round1(v: number): number {
  return Math.round(v * 10) / 10;
}

// ─── Main export ──────────────────────────────────────────────────────────────

export function aggregateCreditScores(signals: CreditSignal[]): AggregatedScore {
  if (!signals || signals.length === 0) {
    return {
      final_score: 50,
      confidence: "low",
      source_count: 0,
      interpretation: "watch",
      sources: [],
    };
  }

  let weightedSum = 0;
  let weightSum = 0;
  const sources: AggregatedScore["sources"] = [];

  for (const signal of signals) {
    const norm = normaliseCreditSignal(signal);
    const weight = PROVIDER_WEIGHTS[signal.source] ?? FALLBACK_WEIGHT;

    // Skip if normalisation fell back due to unrecognised input value
    // (confidence dropped to 'low' when the original confidence was 'high' or 'medium')
    if (norm.confidence === "low" && signal.confidence !== "low") {
      continue;
    }

    weightedSum += norm.normalised_score * weight;
    weightSum += weight;

    sources.push({
      provider: signal.source,
      raw_score: signal.raw_value,
      normalised_score: norm.normalised_score,
      weight,
    });
  }

  if (sources.length === 0) {
    return {
      final_score: 50,
      confidence: "low",
      source_count: 0,
      interpretation: "watch",
      sources: [],
    };
  }

  const final_score = round1(weightedSum / weightSum);
  const confidence: AggregatedScore["confidence"] =
    sources.length >= 3 ? "high" : sources.length === 2 ? "medium" : "low";

  return {
    final_score,
    confidence,
    source_count: sources.length,
    interpretation: toInterpretation(final_score),
    sources,
  };
}
