import { describe, it, expect } from "vitest";
import {
  analysePaymentBehaviour,
  PaymentTransaction,
} from "../analyse-payment-behaviour";

// Helper: build a transaction record
function tx(
  payment_date: string,
  days_early_late: number,
  on_time: boolean,
  amount = 10_000
): PaymentTransaction {
  return {
    payment_date,
    days_to_pay: 30 + days_early_late,
    days_early_late,
    on_time,
    amount,
  };
}

describe("analysePaymentBehaviour", () => {
  it("returns safe defaults for empty transactions", () => {
    const result = analysePaymentBehaviour([]);
    expect(result.on_time_rate).toBe(1);
    expect(result.trend).toBe("insufficient_data");
    expect(result.total_transactions).toBe(0);
    expect(result.health).toBe("healthy");
  });

  it("returns safe defaults for null input", () => {
    const result = analysePaymentBehaviour(null as any);
    expect(result.on_time_rate).toBe(1);
    expect(result.health).toBe("healthy");
  });

  it("classifies a healthy customer correctly", () => {
    const transactions: PaymentTransaction[] = [
      tx("2025-01-15", -2, true),
      tx("2025-02-15", 0, true),
      tx("2025-03-15", -1, true),
      tx("2025-04-15", -3, true),
      tx("2025-05-15", 1, true),
      tx("2025-06-15", -2, true),
    ];
    const result = analysePaymentBehaviour(transactions);

    expect(result.on_time_rate).toBe(1);
    expect(result.health).toBe("healthy");
    expect(result.trend).not.toBe("deteriorating");
    expect(result.total_transactions).toBe(6);
  });

  it("flags a deteriorating customer as at_risk", () => {
    // Early transactions pay on time, later ones are increasingly late
    const transactions: PaymentTransaction[] = [
      tx("2025-01-01", -1, true),
      tx("2025-02-01", 0, true),
      tx("2025-03-01", 5, false),
      tx("2025-04-01", 12, false),
      tx("2025-05-01", 18, false),
      tx("2025-06-01", 25, false),
    ];
    const result = analysePaymentBehaviour(transactions);

    expect(result.on_time_rate).toBeLessThan(0.5);
    expect(result.trend).toBe("deteriorating");
    expect(result.health).toBe("at_risk");
  });

  it("handles a single transaction without crashing", () => {
    const result = analysePaymentBehaviour([tx("2025-06-01", 5, false)]);

    expect(result.total_transactions).toBe(1);
    expect(result.on_time_rate).toBe(0);
    expect(result.trend).toBe("insufficient_data");
  });

  it("detects improving trend when recent payments are earlier", () => {
    const transactions: PaymentTransaction[] = [
      tx("2025-01-01", 15, false),
      tx("2025-02-01", 12, false),
      tx("2025-03-01", -2, true),
      tx("2025-04-01", -3, true),
    ];
    const result = analysePaymentBehaviour(transactions);
    expect(result.trend).toBe("improving");
  });

  it("calculates recent_on_time_rate from last 3 transactions", () => {
    const transactions: PaymentTransaction[] = [
      tx("2025-01-01", 10, false),
      tx("2025-02-01", 10, false),
      tx("2025-03-01", 10, false),
      // Last 3: all on time
      tx("2025-04-01", 0, true),
      tx("2025-05-01", 0, true),
      tx("2025-06-01", 0, true),
    ];
    const result = analysePaymentBehaviour(transactions);
    expect(result.recent_on_time_rate).toBe(1);
    expect(result.on_time_rate).toBeLessThan(1); // overall is lower
  });
});
