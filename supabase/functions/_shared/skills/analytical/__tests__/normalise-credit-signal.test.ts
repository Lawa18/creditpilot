import { describe, it, expect } from "vitest";
import {
  normaliseCreditSignal,
  normaliseAll,
  CreditSignal,
} from "../normalise-credit-signal";

function sig(
  source: CreditSignal["source"],
  raw_value: number | string,
  confidence: CreditSignal["confidence"] = "high"
): CreditSignal {
  return { source, raw_value, as_of_date: "2026-01-01", confidence };
}

describe("normaliseCreditSignal", () => {
  // --- Payment behaviour scores ---

  it("D&B PAYDEX 80 → 80 (pass through)", () => {
    const result = normaliseCreditSignal(sig("dnb_paydex", 80));
    expect(result.normalised_score).toBe(80);
    expect(result.interpretation).toBe("very_safe"); // 80 is in the 80–100 band
  });

  it("D&B failure score 30 → 70 (inverted)", () => {
    const result = normaliseCreditSignal(sig("dnb_failure_score", 30));
    expect(result.normalised_score).toBe(70);
    expect(result.interpretation).toBe("safe");
  });

  it("D&B failure score 100 → 0 (worst)", () => {
    const result = normaliseCreditSignal(sig("dnb_failure_score", 100));
    expect(result.normalised_score).toBe(0);
    expect(result.interpretation).toBe("high_risk");
  });

  it("Experian Intelliscore 90 → 90 (pass through)", () => {
    const result = normaliseCreditSignal(sig("experian_intelliscore", 90));
    expect(result.normalised_score).toBe(90);
    expect(result.interpretation).toBe("very_safe");
  });

  it("Equifax Business 992 → 100 (best)", () => {
    const result = normaliseCreditSignal(sig("equifax_business", 992));
    expect(result.normalised_score).toBe(100);
  });

  it("Equifax Business 101 → 0 (worst)", () => {
    const result = normaliseCreditSignal(sig("equifax_business", 101));
    expect(result.normalised_score).toBe(0);
  });

  // --- Altman Z ---

  it("Altman Z 3.5 → safe zone, score ≈ 62.5 (formula: (3.5+4)/12*100)", () => {
    const result = normaliseCreditSignal(sig("altman_z", 3.5));
    expect(result.normalised_score).toBeCloseTo(62.5, 1);
    expect(result.interpretation).toBe("safe"); // 62.5 falls in the 60–79 band
  });

  it("Altman Z 2.4 → grey zone (40–70)", () => {
    const result = normaliseCreditSignal(sig("altman_z", 2.4));
    expect(result.normalised_score).toBeGreaterThanOrEqual(40);
    expect(result.normalised_score).toBeLessThan(70);
  });

  it("Altman Z 1.2 → distress zone, score ≈ 43.3 (watch)", () => {
    // Formula: (1.2 + 4) / 12 * 100 = 43.3 — distress zone but watch band
    const result = normaliseCreditSignal(sig("altman_z", 1.2));
    expect(result.normalised_score).toBeCloseTo(43.3, 1);
    expect(result.interpretation).toBe("watch");
  });

  it("Altman Z 0 → distress zone, score ≈ 33.3 (concern)", () => {
    // Formula: (0 + 4) / 12 * 100 = 33.3 — solidly in concern band
    const result = normaliseCreditSignal(sig("altman_z", 0));
    expect(result.normalised_score).toBeCloseTo(33.3, 1);
    expect(result.interpretation).toBe("concern");
  });

  it("Altman Z -4 (worst) → 0 (clamped)", () => {
    const result = normaliseCreditSignal(sig("altman_z", -4));
    expect(result.normalised_score).toBe(0);
  });

  it("Altman Z 8 (best) → 100 (clamped)", () => {
    const result = normaliseCreditSignal(sig("altman_z", 8));
    expect(result.normalised_score).toBe(100);
  });

  // --- Moody's ---

  it("Moody's 'Aaa' → 100", () => {
    const result = normaliseCreditSignal(sig("moodys", "Aaa"));
    expect(result.normalised_score).toBe(100);
    expect(result.interpretation).toBe("very_safe");
  });

  it("Moody's 'B2' → 26", () => {
    const result = normaliseCreditSignal(sig("moodys", "B2"));
    expect(result.normalised_score).toBe(26);
    expect(result.interpretation).toBe("concern");
  });

  it("Moody's 'Baa2' → 70", () => {
    const result = normaliseCreditSignal(sig("moodys", "Baa2"));
    expect(result.normalised_score).toBe(70);
    expect(result.interpretation).toBe("safe");
  });

  it("Moody's 'C' → 0", () => {
    const result = normaliseCreditSignal(sig("moodys", "C"));
    expect(result.normalised_score).toBe(0);
    expect(result.interpretation).toBe("high_risk");
  });

  // --- S&P / Fitch ---

  it("S&P 'BBB+' → 75", () => {
    const result = normaliseCreditSignal(sig("sp_fitch", "BBB+"));
    expect(result.normalised_score).toBe(75);
    expect(result.interpretation).toBe("safe");
  });

  it("S&P 'bbb+' → 75 (case insensitive)", () => {
    const result = normaliseCreditSignal(sig("sp_fitch", "bbb+"));
    expect(result.normalised_score).toBe(75);
  });

  it("S&P 'BBB +' → 75 (whitespace tolerant)", () => {
    const result = normaliseCreditSignal(sig("sp_fitch", "BBB +"));
    expect(result.normalised_score).toBe(75);
  });

  it("S&P 'AAA' → 100", () => {
    const result = normaliseCreditSignal(sig("sp_fitch", "AAA"));
    expect(result.normalised_score).toBe(100);
  });

  it("S&P 'D' → 0", () => {
    const result = normaliseCreditSignal(sig("sp_fitch", "D"));
    expect(result.normalised_score).toBe(0);
    expect(result.interpretation).toBe("high_risk");
  });

  // --- Trade credit insurers ---

  it("Coface 8 → 80", () => {
    const result = normaliseCreditSignal(sig("coface", 8));
    expect(result.normalised_score).toBe(80);
    expect(result.interpretation).toBe("very_safe");
  });

  it("Coface 0 → 0 (worst)", () => {
    const result = normaliseCreditSignal(sig("coface", 0));
    expect(result.normalised_score).toBe(0);
  });

  it("Coface 10 → 100 (best)", () => {
    const result = normaliseCreditSignal(sig("coface", 10));
    expect(result.normalised_score).toBe(100);
  });

  it("Atradius 1 → 0 (worst)", () => {
    const result = normaliseCreditSignal(sig("atradius", 1));
    expect(result.normalised_score).toBe(0);
  });

  it("Atradius 10 → 100 (best)", () => {
    const result = normaliseCreditSignal(sig("atradius", 10));
    expect(result.normalised_score).toBe(100);
  });

  it("Euler Hermes 1 → 100 (best rating, reverse scale)", () => {
    const result = normaliseCreditSignal(sig("euler_hermes", 1));
    expect(result.normalised_score).toBe(100);
    expect(result.interpretation).toBe("very_safe");
  });

  it("Euler Hermes 6 → 0 (worst rating, reverse scale)", () => {
    const result = normaliseCreditSignal(sig("euler_hermes", 6));
    expect(result.normalised_score).toBe(0);
    expect(result.interpretation).toBe("high_risk");
  });

  it("Euler Hermes 3 → 60 (mid-scale)", () => {
    const result = normaliseCreditSignal(sig("euler_hermes", 3));
    expect(result.normalised_score).toBe(60);
  });

  // --- Internal scores ---

  it("internal_payment_score 72 → 72 (pass through)", () => {
    const result = normaliseCreditSignal(sig("internal_payment_score", 72));
    expect(result.normalised_score).toBe(72);
  });

  // --- Fallback / error handling ---

  it("unknown Moody's rating → 50 with low confidence", () => {
    const result = normaliseCreditSignal(sig("moodys", "XXXZ"));
    expect(result.normalised_score).toBe(50);
    expect(result.confidence).toBe("low");
    expect(result.interpretation).toBe("watch");
  });

  it("unknown S&P rating → 50 with low confidence", () => {
    const result = normaliseCreditSignal(sig("sp_fitch", "ZZZ"));
    expect(result.normalised_score).toBe(50);
    expect(result.confidence).toBe("low");
  });

  it("preserves as_of_date on output", () => {
    const signal: CreditSignal = {
      source: "dnb_paydex",
      raw_value: 75,
      as_of_date: "2026-03-01",
      confidence: "high",
    };
    expect(normaliseCreditSignal(signal).as_of_date).toBe("2026-03-01");
  });

  it("normalised_score is rounded to 1 decimal place", () => {
    // Equifax: (546 - 101) / 891 * 100 = 49.9438...
    const result = normaliseCreditSignal(sig("equifax_business", 546));
    expect(result.normalised_score.toString()).toMatch(/^\d+(\.\d)?$/);
  });

  // --- Interpretation bands ---

  it("score 85 → very_safe", () => {
    expect(normaliseCreditSignal(sig("dnb_paydex", 85)).interpretation).toBe("very_safe");
  });

  it("score 65 → safe", () => {
    expect(normaliseCreditSignal(sig("dnb_paydex", 65)).interpretation).toBe("safe");
  });

  it("score 45 → watch", () => {
    expect(normaliseCreditSignal(sig("dnb_paydex", 45)).interpretation).toBe("watch");
  });

  it("score 25 → concern", () => {
    expect(normaliseCreditSignal(sig("dnb_paydex", 25)).interpretation).toBe("concern");
  });

  it("score 10 → high_risk", () => {
    expect(normaliseCreditSignal(sig("dnb_paydex", 10)).interpretation).toBe("high_risk");
  });
});

describe("normaliseAll", () => {
  it("returns empty array for empty input", () => {
    expect(normaliseAll([])).toEqual([]);
  });

  it("returns empty array for null input", () => {
    expect(normaliseAll(null as any)).toEqual([]);
  });

  it("normalises multiple signals in one call", () => {
    const results = normaliseAll([
      sig("dnb_paydex", 80),
      sig("moodys", "Aaa"),
      sig("euler_hermes", 1),
    ]);
    expect(results).toHaveLength(3);
    expect(results[0].normalised_score).toBe(80);
    expect(results[1].normalised_score).toBe(100);
    expect(results[2].normalised_score).toBe(100);
  });
});
