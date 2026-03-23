import { describe, it, expect } from "vitest";
import { calculateCreditLimitProposal } from "../calculate-credit-limit-proposal";

const BASE: Parameters<typeof calculateCreditLimitProposal>[0] = {
  current_limit: 500_000,
  current_exposure: 400_000,
  days_over_90: 0,
  utilization_pct: 80,
  altman_z_zone: null,
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

  it("applies 50% reduction for distress zone + high overdue (non-preferred)", () => {
    const result = calculateCreditLimitProposal({
      ...BASE,
      days_over_90: 80_000,
      utilization_pct: 80,
      altman_z_zone: "distress",
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
      altman_z_zone: "distress",
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
      altman_z_zone: null,
    });
    const preferred = calculateCreditLimitProposal({
      ...BASE,
      utilization_pct: 75,
      days_over_90: 60_000,
      altman_z_zone: null,
      is_preferred_customer: true,
    });
    expect(nonPreferred.action).toBe("reduce");
    expect(preferred.action).toBe("no_action");
  });

  it("enforces minimum 25% reduction for non-preferred customers", () => {
    // grey zone + high overdue + bad on_time → reductionFactor set to 0.25
    const result = calculateCreditLimitProposal({
      ...BASE,
      utilization_pct: 75,
      days_over_90: 60_000,
      altman_z_zone: "grey",
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
      altman_z_zone: "distress",
    });
    expect(result.rationale.length).toBeGreaterThan(10);
  });
});
