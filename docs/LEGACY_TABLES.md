# Legacy Tables

These tables were created in the initial scaffold (February 2026)
and are not currently used by any active agent.
Preserved for potential future use — do not reference in new code without a plan.

| Table | Created | Status | Notes |
|-------|---------|--------|-------|
| bankruptcy_details | Feb 2026 | Unused | Could feed GOING_CONCERN events |
| growth_signals | Feb 2026 | Unused | Could feed positive CIA signals |
| credit_actions | Feb 2026 | Unused | Superseded by pending_actions + credit_events |
| credit_metrics | Feb 2026 | Fully orphaned | Altman Z removed from decisions and UI (Apr 27 2026). No agent writes to it, no frontend reads it. Contains: credit_score, altman_z_score, d_and_b_rating, current_ratio. credit_rating_score on customers table is the authoritative score. |
