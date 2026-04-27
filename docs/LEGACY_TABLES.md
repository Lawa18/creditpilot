# Legacy Tables

These tables were created in the initial Lovable scaffold (February 2026)
and are not currently used by any agent. They are preserved for potential
future use but should not be referenced in new code without a clear plan.

| Table | Created | Status | Notes |
|-------|---------|--------|-------|
| bankruptcy_details | Feb 2026 | Unused | Could feed GOING_CONCERN events in future |
| growth_signals | Feb 2026 | Unused | Could feed positive CIA signals in future |
| credit_actions | Feb 2026 | Unused | Superseded by pending_actions + credit_events |
| sec_filings | Feb 2026 | Partially used | Agent now writes to this table |
