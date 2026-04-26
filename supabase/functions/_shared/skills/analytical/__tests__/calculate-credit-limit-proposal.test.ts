import { describe, it, expect } from "vitest";
import { calculateCreditLimitProposal } from "../calculate-credit-limit-proposal";

const BASE: Parameters<typeof calculateCreditLimitProposal>[0] = {
  current_limit: 500_000,
  current_exposure: 400_000,
  days_over_90: 0,
  utilization_pct: 80,
  credit_score: null,
  is_preferred_customer: false,
  on_time_rate: 1,
};

describe("calculateCreditLimitProposal", () => {
  it("returns no_action when no risk criteria are met", () => {
    const result = calculateCreditLimitProposal({
      ...BASE,
      utilization_pct: 50,
      days_over_90: 0,
    });
    expect(result.action).toBe("no_action");
    expect(result.reduction_pct).toBe(0);
    expect(result.proposed_limit).toBe(500_000);
  });

  it("returns no_action for zero current_limit", () => {
    const result = calculateCreditLimitProposal({ ...BASE, current_limit: 0 });
    expect(result.action).toBe("no_action");
  });

  it("applies 50% reduction for distress score + high overdue (non-preferred)", () => {
    const result = calculateCreditLimitProposal({
      ...BASE,
      days_over_90: 80_000,
      utilization_pct: 80,
      credit_score: 15, // < 20 = distress
    });
    expect(result.action).toBe("reduce");
    expect(result.reduction_pct).toBe(50);
    expect(result.proposed_limit).toBe(250_000);
  });

  it("preferred customer in distress + high overdue gets 40% reduction (not 50%)", () => {
    const result = calculateCreditLimitProposal({
      ...BASE,
      days_over_90: 80_000,
      utilization_pct: 80,
      credit_score: 15, // < 20 = distress
      is_preferred_customer: true,
    });
    expect(result.action).toBe("reduce");
    expect(result.reduction_pct).toBe(40);
    expect(result.proposed_limit).toBe(300_000);
  });

  it("preferred customer high util threshold is 80pp not 70pp", () => {
    // 75% util: triggers for non-preferred but NOT for preferred (threshold is 80)
    const nonPreferred = calculateCreditLimitProposal({
      ...BASE,
      utilization_pct: 75,
      days_over_90: 60_000,
      credit_score: null,
    });
    const preferred = calculateCreditLimitProposal({
      ...BASE,
      utilization_pct: 75,
      days_over_90: 60_000,
      credit_score: null,
      is_preferred_customer: true,
    });
    expect(nonPreferred.action).toBe("reduce");
    expect(preferred.action).toBe("no_action");
  });

  it("enforces minimum 25% reduction for non-preferred customers", () => {
    // grey score + high overdue + bad on_time → reductionFactor set to 0.25
    const result = calculateCreditLimitProposal({
      ...BASE,
      utilization_pct: 75,
      days_over_90: 60_000,
      credit_score: 30, // 20-40 = grey
      on_time_rate: 0.5,
    });
    expect(result.action).toBe("reduce");
    expect(result.reduction_pct).toBeGreaterThanOrEqual(25);
  });

  it("includes rationale in all reduce proposals", () => {
    const result = calculateCreditLimitProposal({
      ...BASE,
      days_over_90: 80_000,
      utilization_pct: 80,
      credit_score: 15,
    });
    expect(result.rationale.length).toBeGreaterThan(10);
  });

  it("credit_score null + high util + high overdue → triggers on AR metrics alone", () => {
    const result = calculateCreditLimitProposal({
      ...BASE,
      utilization_pct: 80,
      days_over_90: 80_000,
      credit_score: null,
    });
    expect(result.action).toBe("reduce");
    expect(result.reduction_pct).toBeGreaterThanOrEqual(25);
  });

  it("credit_score 50 (safe zone) + high overdue → uses AR metrics only, no distress penalty", () => {
    const safe = calculateCreditLimitProposal({
      ...BASE,
      utilization_pct: 80,
      days_over_90: 80_000,
      credit_score: 50, // > 40 = safe, no zone penalty
    });
    const distress = calculateCreditLimitProposal({
      ...BASE,
      utilization_pct: 80,
      days_over_90: 80_000,
      credit_score: 10, // < 20 = distress
    });
    // Safe score should result in smaller reduction than distress
    expect(safe.reduction_pct).toBeLessThan(distress.reduction_pct);
  });
});
