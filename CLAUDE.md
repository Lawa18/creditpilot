# CreditPilot — Engineering Principles

This file is read automatically at the start of every Claude Code session in this repo.
It holds durable engineering principles discovered the hard way — not a status log
(see docs/CreditPilot_Deferred_Backlog.md for that) — just rules worth never re-learning.

## Never let an LLM compute exact arithmetic over multiple records

If a question requires summing, averaging, or otherwise aggregating numeric values across
more than one raw database record, the LLM must never be asked to do that math itself —
even with a careful prompt. This is a well-documented, measured limitation of language
models, not a prompting problem to engineer around.

Confirmed directly in this project (2026-08-29): the CIA agent was caught red-handed
producing three different portfolio totals across three identical requests, off by
millions of dollars, because it was handed raw line items and asked to sum them itself.

**The rule:** if a question needs an aggregate figure, compute it deterministically —
a SQL view, an RPC, or a simple JS reduce() over already-fetched rows — and hand the
model the finished number as an authoritative fact. The model's job is explaining and
contextualizing correct numbers, never generating them through its own arithmetic.

This applies to every future agent, field, or feature added to this project. Before
wiring any new data into a prompt, ask: "does this involve the model summing/averaging/
counting more than a couple of raw records?" If yes, pre-compute it first.

Reference implementation: supabase/functions/cia-agent/index.ts — search for
"OFFICIAL AR AGING PORTFOLIO TOTALS", "OFFICIAL SECTOR EXPOSURE TOTAL", "OFFICIAL
COMBINED TOTAL", "OFFICIAL PAYMENT BEHAVIOR TOTALS" for the pattern to copy.
