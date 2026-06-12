---
name: example-pr-walkthrough
description: Synthetic worked example showing what the supervision gate produces in practice. A hypothetical "add /pricing page" PR walked through FCPSS, cross-vendor review, two iteration rounds, and final approval. Read this once to see what chat checkpoints, anchored observations, and audit trails actually look like.
status: reference
---

# Example PR walkthrough — the gate in action

This is a **synthetic** example. The PR doesn't exist in any real
codebase. It shows what the supervision gate produces so you know
what to expect on day one before your first real PR lands.

The example: a generic web app on Next.js + Postgres. The supervisor
asks the agent to add a `/pricing` page that lists three plans, pulls
plan data from the database, and renders pricing in the user's local
currency.

This is **Tier 2** work (user-visible, not money-irreversible) — so
it walks FCPSS, gets cross-vendor reviewed, and holds for explicit
"ship it" before merge per [`stake-matrix.md`](../protocols/stake-matrix.md)
+ [`supervision.md`](../protocols/supervision.md).

## 1. The supervisor's prompt

```
Add a /pricing page. Three plans (Free / Pro / Team). Plan data lives
in the existing `plans` table. Render prices in the user's local
currency using their session's locale. Use the existing landing-page
layout for chrome consistency.
```

## 2. What the agent does before the chat checkpoint

The `/build-feature` skill auto-fires on "Add a /pricing page." The
agent walks
[`markdowns/protocols/build-feature.md`](../protocols/build-feature.md):

- **Classify the work shape.** New user-visible page → "screen / surface"
  per FCPSS §1. Not a refactor, not a bug fix.
- **Run the near-match scan.** Greps for existing pricing logic,
  plan-table reads, currency-rendering helpers. Finds:
  - `lib/db/plans.ts` — existing read helper. ✓ extend (≥70% applicable).
  - `lib/intl/format-currency.ts` — existing currency formatter. ✓ extend.
  - `app/landing/page.tsx` — existing landing layout. ✓ extend (chrome).
  - No existing pricing route. New file required.
- **Implement.** Builds `app/pricing/page.tsx`. Reuses the three helpers
  above. Adds three plan cards rendered from `plans` table rows.
- **Walk FCPSS.** Produces the coverage block below.
- **Self-review in fresh context** per
  [`cross-vendor-review.md`](../protocols/cross-vendor-review.md) §3.
  Worker rubric run before peer-vendor review.

## 3. The chat checkpoint

This is what lands in chat when CI goes green. The supervisor reads
this before approving "ship it."

```
[WORKER] Tier 2 — /pricing page

What this PR does:
Adds /pricing with three plan cards (Free / Pro / Team) reading from
the plans table. Reuses existing chrome (landing-layout), existing
db helper (lib/db/plans.ts), existing currency formatter (extended
to accept session locale instead of defaulting to 'en-US').

Near-match scan:
- ✓ Reused lib/db/plans.ts (extended with .orderBy('display_order'))
- ✓ Reused lib/intl/format-currency.ts (added optional locale arg)
- ✓ Reused app/landing/page.tsx chrome (extracted into shared component)
- New: app/pricing/page.tsx (no existing route)

FCPSS coverage:
- Functional: Three plan cards render. Plan data sourced from plans
  table, ordered by display_order. Each card shows name, monthly
  price, top three features, "Choose plan" CTA. Empty state: if no
  plans returned, page renders a 503-shaped "Pricing temporarily
  unavailable" message with a support email link.
- Cross-cutting: Currency format reuses lib/intl/format-currency.ts;
  added a locale parameter (defaults to existing 'en-US' behavior so
  no caller breaks). Tests added for the new branch.
- Performance: Single DB query (3 rows expected, parameterized by
  status='active'). ISR with revalidate=3600 — plan pricing changes
  infrequently. No client-side currency conversion (rendered server-
  side, sent as formatted string).
- Security: No auth on this page (public marketing). plans table
  already has SELECT-anon RLS; no policy change. No PII collected.
- Stability: 1 unit test for the new currency-locale branch. 1
  integration test for the empty-state path. CI green.

Audit trail:
- Worker self-review (fresh context, same rubric): 0 anchored
  observations, 1 no-anchor (style nit on plan card spacing,
  declined per anchor-or-decline).
- Cross-vendor review (Codex): see report below.
- Iteration rounds: 2 (first round had one anchored observation).

[REVIEWER] Cross-vendor review report (Codex, round 1):

### Anchored observations
- app/pricing/page.tsx:47 — three plan cards render unconditionally
  even when `plans` query returns < 3 rows. The fallback empty-state
  in §FCPSS only triggers on 0 rows. The 1-row / 2-row case (e.g.,
  the Team plan is temporarily disabled) renders a broken layout.
  Anchor: empty-state coverage is FCPSS-required for partial-data
  cases per fcpss-gate.md §Functional row 3.

### No-anchor observations
- None.

[WORKER] Round 2:
Fixed app/pricing/page.tsx:47 — empty-state predicate now triggers
when `plans.length < 3 || plans.length === 0`. Tests added for the
1-row + 2-row paths. Re-ran cross-vendor review.

[REVIEWER] Cross-vendor review report (Codex, round 2):

### Anchored observations
- None.

### No-anchor observations
- None.

[WORKER] Holding for ship it.
```

## 4. What the supervisor scans for

Per [`onboarding.md`](onboarding.md) — read in this order:

1. **What-this-PR-does paragraph** — does it match the original ask?
   Here: "Three plan cards reading from plans table, reusing chrome
   + db helper + currency formatter." Matches "add a /pricing page."
   ✓ approve this part.

2. **Audit trail counts.** Anchored = 0 after round 2 (was 1 in
   round 1). No-anchor = 0. ✓ ready to ship.

3. **FCPSS coverage.** Five rows, each with a concrete answer —
   no "N/A" without reason. The Functional row names the empty-
   state behavior (good, that was the round-1 finding). The Security
   row notes "no PII collected" (concrete, not "we handle PII
   carefully"). The Stability row names test counts (good — vague
   "tests added" wouldn't be enough). ✓.

4. **Iteration count.** 2 rounds. Round 1 found a real bug (partial-
   data layout break). Round 2 fixed it cleanly. ✓ — this is normal,
   not a signal worth investigating.

5. **Anchored observation in round 1.** Cited a specific protocol
   section (fcpss-gate.md §Functional row 3) — that's a real anchor,
   not a style preference. The supervisor doesn't need to verify the
   protocol cite themselves; they trust the citation because the
   rubric requires it.

The supervisor types `ship it.` Tier 2 → `gh pr merge` fires per
[`supervision.md`](../protocols/supervision.md).

## 5. What this example is NOT

- **Not a real PR.** No `/pricing` route exists in any of the author's
  projects. The file paths (`lib/db/plans.ts`, `lib/intl/format-
  currency.ts`) are invented for the example. If you grep your project
  for them, they won't be there.
- **Not a contract on shape.** Your project's chat checkpoint might
  show different headers based on your work's tier, the vendor mix
  you chose, and the protocols active at the time. The shape above is
  representative; the strict requirement is the supervision template
  in [`supervision.md`](../protocols/supervision.md).
- **Not a checklist.** Don't copy the FCPSS rows verbatim. The
  prompts there ("Functional: three plan cards render...") are
  the agent's own concrete restatement of the gate; on your work
  the rows will read differently because the work is different.

## 6. What to do if your real first PR looks nothing like this

That's expected. This example was chosen because it's a common shape
(public web page + DB read + reuse-first). Your first real PR could
be a refactor, a bug fix, a script, or a content update — different
work shapes produce different FCPSS coverage answers per
[`fcpss-gate.md`](../protocols/fcpss-gate.md) §1.

The shape that's invariant across work types:

- The chat checkpoint has a what-this-PR-does paragraph in plain
  English.
- The audit trail lists anchored and no-anchor counts separately.
- FCPSS coverage is five rows with concrete answers.
- Cross-vendor review reports observations under `### Anchored` and
  `### No-anchor` headers.
- Tier 1 / Tier 2 PRs hold for explicit "ship it"; Tier 3 / Tier 4
  auto-merge on green CI.

When you can recognize those five invariants, you can supervise
agent work in this template even when the surface details differ
from this example.

## See also

- [`onboarding.md`](onboarding.md) — first-day walkthrough; pair with
  this example.
- [`supervision.md`](../protocols/supervision.md) — chat-checkpoint
  template + decision-moment notation.
- [`fcpss-gate.md`](../protocols/fcpss-gate.md) — the gate the
  Functional / Cross-cutting / Performance / Security / Stability
  rows answer.
- [`cross-vendor-review.md`](../protocols/cross-vendor-review.md) —
  anchored vs no-anchor observations, iteration rules.
- [`stake-matrix.md`](../protocols/stake-matrix.md) — why this
  example is Tier 2 (not 1, not 3).
