import { describe, it, expect } from "vitest";
import { calculateAltmanZ } from "../calculate-altman-z";

// A financially healthy company — safe zone
const SAFE_INPUT = {
  working_capital: 500_000,
  total_assets: 2_000_000,
  retained_earnings: 800_000,
  ebit: 400_000,
  market_value_equity: 3_000_000,
  total_liabilities: 500_000,
  revenue: 5_000_000,
};

// A stressed company — grey zone
// Z ≈ 2.2: above 1.81 but below 2.99
const GREY_INPUT = {
  working_capital: 100_000,
  total_assets: 2_000_000,
  retained_earnings: 200_000,
  ebit: 100_000,
  market_value_equity: 600_000,
  total_liabilities: 1_200_000,
  revenue: 2_800_000,
};

// A distressed company — below 1.81
const DISTRESS_INPUT = {
  working_capital: -200_000,
  total_assets: 2_000_000,
  retained_earnings: -300_000,
  ebit: -100_000,
  market_value_equity: 200_000,
  total_liabilities: 1_800_000,
  revenue: 1_500_000,
};

describe("calculateAltmanZ", () => {
  it("returns distress zone for zero total_assets", () => {
    const result = calculateAltmanZ({ ...SAFE_INPUT, total_assets: 0 });
    expect(result.zone).toBe("distress");
    expect(result.z_score).toBe(0);
  });

  it("returns distress zone for zero total_liabilities", () => {
    const result = calculateAltmanZ({ ...SAFE_INPUT, total_liabilities: 0 });
    expect(result.zone).toBe("distress");
  });

  it("correctly classifies a safe zone company (Z > 2.99)", () => {
    const result = calculateAltmanZ(SAFE_INPUT);
    expect(result.zone).toBe("safe");
    expect(result.z_score).toBeGreaterThan(2.99);
  });

  it("correctly classifies a grey zone company (1.81 ≤ Z ≤ 2.99)", () => {
    const result = calculateAltmanZ(GREY_INPUT);
    expect(result.zone).toBe("grey");
    expect(result.z_score).toBeGreaterThanOrEqual(1.81);
    expect(result.z_score).toBeLessThanOrEqual(2.99);
  });

  it("correctly classifies a distress zone company (Z < 1.81)", () => {
    const result = calculateAltmanZ(DISTRESS_INPUT);
    expect(result.zone).toBe("distress");
    expect(result.z_score).toBeLessThan(1.81);
  });

  it("returns all five intermediate ratios", () => {
    const result = calculateAltmanZ(SAFE_INPUT);
    expect(typeof result.x1).toBe("number");
    expect(typeof result.x2).toBe("number");
    expect(typeof result.x3).toBe("number");
    expect(typeof result.x4).toBe("number");
    expect(typeof result.x5).toBe("number");
  });

  it("x1 equals working_capital / total_assets", () => {
    const result = calculateAltmanZ(SAFE_INPUT);
    const expected = SAFE_INPUT.working_capital / SAFE_INPUT.total_assets;
    expect(result.x1).toBeCloseTo(expected, 4);
  });

  it("z_score formula: Z = 1.2*X1 + 1.4*X2 + 3.3*X3 + 0.6*X4 + 1.0*X5", () => {
    const result = calculateAltmanZ(SAFE_INPUT);
    const manual =
      1.2 * result.x1 +
      1.4 * result.x2 +
      3.3 * result.x3 +
      0.6 * result.x4 +
      1.0 * result.x5;
    expect(result.z_score).toBeCloseTo(manual, 1);
  });

  it("handles negative working capital (distress scenario)", () => {
    const result = calculateAltmanZ(DISTRESS_INPUT);
    expect(result.x1).toBeLessThan(0);
    expect(result.zone).toBe("distress");
  });
});
