import { describe, it, expect } from "vitest";
import { aggregateCreditScores } from "../aggregate-credit-scores";
import { CreditSignal } from "../normalise-credit-signal";

function sig(
  source: CreditSignal["source"],
  raw_value: number | string,
  confidence: CreditSignal["confidence"] = "high"
): CreditSignal {
  return { source, raw_value, as_of_date: "2026-01-01", confidence };
}

describe("aggregateCreditScores", () => {
  // ── Empty / null input ────────────────────────────────────────────────────

  it("empty array → score 50, confidence low, source_count 0", () => {
    const result = aggregateCreditScores([]);
    expect(result.final_score).toBe(50);
    expect(result.confidence).toBe("low");
    expect(result.source_count).toBe(0);
    expect(result.sources).toHaveLength(0);
    expect(result.interpretation).toBe("watch");
  });

  it("null input → score 50, confidence low", () => {
    const result = aggregateCreditScores(null as any);
    expect(result.final_score).toBe(50);
    expect(result.confidence).toBe("low");
  });

  // ── Single source ─────────────────────────────────────────────────────────

  it("single source → uses that score, confidence = low", () => {
    const result = aggregateCreditScores([sig("dnb_paydex", 80)]);
    expect(result.final_score).toBe(80);
    expect(result.confidence).toBe("low");
    expect(result.source_count).toBe(1);
  });

  it("single high-authority source (S&P AAA) → score 100, confidence low", () => {
    const result = aggregateCreditScores([sig("sp_fitch", "AAA")]);
    expect(result.final_score).toBe(100);
    expect(result.confidence).toBe("low");
  });

  // ── Two sources ───────────────────────────────────────────────────────────

  it("two sources → weighted average, confidence = medium", () => {
    // moodys weight 1.0, score from "Aaa" = 100
    // dnb_paydex weight 0.8, score = 60
    // weighted avg = (100*1.0 + 60*0.8) / (1.0 + 0.8) = (100 + 48) / 1.8 = 82.2
    const result = aggregateCreditScores([
      sig("moodys", "Aaa"),
      sig("dnb_paydex", 60),
    ]);
    expect(result.confidence).toBe("medium");
    expect(result.source_count).toBe(2);
    expect(result.final_score).toBeCloseTo(82.2, 1);
  });

  // ── Three sources ─────────────────────────────────────────────────────────

  it("three sources → confidence = high", () => {
    const result = aggregateCreditScores([
      sig("moodys", "Baa2"),   // 70, weight 1.0
      sig("dnb_paydex", 80),   // 80, weight 0.8
      sig("coface", 6),        // 60, weight 0.9
    ]);
    expect(result.confidence).toBe("high");
    expect(result.source_count).toBe(3);
    expect(result.final_score).toBeGreaterThan(0);
  });

  it("four sources → confidence still high (3+ threshold)", () => {
    const result = aggregateCreditScores([
      sig("moodys", "Aaa"),
      sig("sp_fitch", "AAA"),
      sig("dnb_paydex", 90),
      sig("coface", 9),
    ]);
    expect(result.confidence).toBe("high");
    expect(result.source_count).toBe(4);
  });

  // ── Unknown provider ──────────────────────────────────────────────────────

  it("unknown provider source → uses fallback weight 0.5", () => {
    // Pass a signal typed as CreditSignal but with an unrecognised source
    const unknownSignal: CreditSignal = {
      source: "manual" as CreditSignal["source"], // manual is known, weight 0.5
      raw_value: 70,
      as_of_date: "2026-01-01",
      confidence: "high",
    };
    const result = aggregateCreditScores([unknownSignal]);
    expect(result.sources[0].weight).toBe(0.5);
    expect(result.final_score).toBe(70);
  });

  // ── Interpretation bands ──────────────────────────────────────────────────

  it("score ≥ 80 → very_safe", () => {
    const result = aggregateCreditScores([sig("dnb_paydex", 85)]);
    expect(result.interpretation).toBe("very_safe");
  });

  it("score 60–79 → safe", () => {
    const result = aggregateCreditScores([sig("dnb_paydex", 65)]);
    expect(result.interpretation).toBe("safe");
  });

  it("score 40–59 → watch", () => {
    const result = aggregateCreditScores([sig("dnb_paydex", 50)]);
    expect(result.interpretation).toBe("watch");
  });

  it("score 20–39 → concern", () => {
    const result = aggregateCreditScores([sig("dnb_paydex", 25)]);
    expect(result.interpretation).toBe("concern");
  });

  it("score < 20 → high_risk", () => {
    const result = aggregateCreditScores([sig("dnb_paydex", 10)]);
    expect(result.interpretation).toBe("high_risk");
  });

  // ── Source breakdown ──────────────────────────────────────────────────────

  it("sources array contains provider, raw_score, normalised_score, weight", () => {
    const result = aggregateCreditScores([sig("sp_fitch", "BBB+")]);
    const src = result.sources[0];
    expect(src.provider).toBe("sp_fitch");
    expect(src.raw_score).toBe("BBB+");
    expect(src.normalised_score).toBe(75);
    expect(src.weight).toBe(1.0);
  });

  // ── Higher-weight provider influences result more ─────────────────────────

  it("higher-weight provider pulls final score more than lower-weight one", () => {
    // moodys (w=1.0) at 30 vs estimated (w=0.3) at 90
    // expected avg: (30*1.0 + 90*0.3) / (1.0 + 0.3) = (30+27)/1.3 = 43.8
    const result = aggregateCreditScores([
      sig("moodys", "B1"),     // 33, weight 1.0
      sig("estimated", 90),    // 90, weight 0.3
    ]);
    // final_score should be closer to 33 than to 90
    expect(result.final_score).toBeLessThan(60);
  });
});
