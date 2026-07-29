# Brief — `interaction-performance-backport`

## What's the work

Backport, from the starter's flagship consumer (Loomvous), the pattern
of its interaction-performance work: a new copy-and-fill template that
gives FCPSS's "P" a measurable bar (interaction classes with budget
slots, optimistic-by-default with revert-and-tell, refetch discipline
with query-ceiling slots, long-job honesty, dev-vs-deployed evaluation,
an honest enforcement map, and a remediation-ledger convention), plus
the gate rewiring so "P" delegates to the project's filled standard.
Pattern only — none of Loomvous's concrete numbers, stack specifics,
or ledger entries appear.

## Tier

Tier 2. Edits a load-bearing protocol file (`fcpss-gate.md`) that every
future PR walks, and adds a canonical skeleton; no code, no runtime
surface. Not Tier 1: no destructive change, no security surface, the
gate's structure (5 dimensions, binary coverage) is untouched.

## Scope — what's in

- NEW `markdowns/engineering/interaction-performance-template.md`
  (`status: template`) — section structure ported from Loomvous's
  shipped standard, all budgets/ceilings as placeholder slots.
- `markdowns/protocols/fcpss-gate.md` — "P" row amended: for UI work,
  covered only when the project's interaction-performance standard's
  budgets pass or a recorded `[SUPERVISOR]` exception exists; no
  standard yet → authoring it is the prerequisite.
- `AGENTS.md` Doc Map — new template added to the surface-skeletons
  row (CLAUDE.md mirror regenerates via pre-commit hook).
- `markdowns/briefs/_template.md` — P bullet gains the same delegation
  clause (sole quoter of the old P row found by the consistency sweep).
- `README.md` — "interaction-performance standard" added to the
  Meta-layer row's "What you'll add" enumeration.
- `markdowns/meta-layer/example-pr-walkthrough.md` — the synthetic
  FCPSS P bullet updated to model the amended gate (states the
  interaction class per the project standard). Added in self-review
  round 1; the example would otherwise demonstrate a P bullet the new
  row rejects.

## Scope — what's deliberately out

- Loomvous's budget numbers, query ceilings, Next.js/Vercel dev-mode
  specifics, house-pattern file references, and its §7 ledger entries —
  excluded by the binding portability rule (pattern, not law). The
  anonymized origin story in the template's preamble (including its
  incident count) is deliberately IN scope per the supervisor's
  instruction — the preamble exists so readers know the template is a
  paid-for lesson; the exclusion rule covers budgets, ceilings, and
  stack specifics, not the war story. The incident count is
  supervisor-attested (stated in the backport instruction), not
  independently re-verified against the source repo's PR history by
  this session.
- Any change to the other FCPSS rows, the work-shape table, or the
  gate's binary-coverage rule.
- A new protocol file — the template is a skeleton (`status:
  template`), so `markdowns/protocols/README.md` and the "18
  protocols" count are intentionally unchanged.
- Pre-filled default budgets in the slots — each project derives its
  own numbers per the template's "where your numbers come from" slot
  (supervisor confirmed slots stay empty). Universal structural
  invariants are exempt from the slot rule and remain literal: "zero
  round trips" for filters over data the client already holds, and
  coalesce-to-one reconciliation. These are the pattern itself, not
  derived budgets — sloting them would gut the discipline.

## FCPSS coverage

- **F (Functional):** No runtime behavior — this is meta-layer.
  Process-visible change: every future Tier 1/2 UI PR's "P" bullet must
  now cite class/budget/counts from a project standard or carry a
  `[SUPERVISOR]` exception; projects bootstrapping from the starter
  inherit the template.
- **C (Cross-cutting):** Touches the canonical `AGENTS.md` (mirror
  auto-syncs to `CLAUDE.md` via pre-commit hook — not hand-edited);
  `fcpss-gate.md` is cited by supervision, build-feature,
  refactor-extract, and the briefs template — the sole P-row quoter
  (`briefs/_template.md`) is updated in the same PR.
- **P (Performance):** N/A for runtime (docs only). Token-footprint:
  the template is a new 266-line file read on demand, not loaded into
  every session's context; the P-row edit lengthens one table row in a
  file skills already load.
- **S (Security):** N/A — no code, no secrets, no auth surface.
  Verified by a direct `gitleaks git` full-history run this session
  (26 commits, no leaks) — run manually because git hooks are NOT
  installed in this clone (neither pre-commit sync nor pre-push
  gitleaks; flagged to supervisor, mirror synced by hand via
  `scripts/sync-agents-md.sh`).
- **S (Stability):** Doc-consistency risk is the failure mode: quoters
  of the P row drift. Mitigated by the sweep (one quoter found,
  updated here) and by the template declaring that all numbers live in
  the filled copy only.

## Anchors for the cross-vendor review

- `markdowns/protocols/fcpss-gate.md:19` — the amended P row; check it
  delegates without changing the gate's binary-coverage semantics.
- `markdowns/engineering/interaction-performance-template.md` — check
  no Loomvous-specific number, stack detail, or ledger entry leaked in
  (the portability rule is binding); check every budget is a slot.
- `markdowns/protocols/markdown-lifecycle.md:37` — template status
  conventions the new file must follow.
- `AGENTS.md` Doc Map surface-skeletons row; `README.md:32`;
  `markdowns/briefs/_template.md:43` — the three index/quoter edits.

## Open questions

- None blocking. `gh repo edit --template=true` (the missing GitHub
  "Use this template" button) was denied by the local permission
  classifier — supervisor runs it directly or flips Settings → General
  → "Template repository"; independent of this PR.
