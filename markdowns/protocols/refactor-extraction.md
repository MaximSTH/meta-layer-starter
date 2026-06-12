---
name: refactor-extraction
description: Four-phase signal-driven refactor flow — Detect, Decide, Execute, Prevent regression. Triggered by a mechanical signal (duplication cluster, file-size warning) or the near-match scan from build-feature. The `/refactor-extract` skill walks this on kickoff.
status: reference
---

# Refactor extraction

Signal-driven refactor extractions are Tier 1 by default. The
`/refactor-extract` skill is the thin wrapper that walks the four
phases.

## The four phases

### 1. Detect

Cite the **mechanical signal** that triggered the refactor:

- A duplication cluster from a checker like `jscpd` (`file:line ↔ file:line`)
- A file-size warning or failure from a pre-commit hook
- An authoring-time near-match surfaced by `/build-feature`'s scan

**No mechanical signal, no advance.** "While I'm here" cleanups are
out of scope. The duplication policy is the gate.

### 2. Decide

| Duplication count | Decision |
|---|---|
| **1–2 inline copies** | Leave them. Refactor is not yet earning its weight. |
| **3 copies** | Open a refactor ticket. The next time the pattern recurs, refactor. |
| **4+ copies** | **The refactor IS the change.** Do it now, forward-looking (the next caller adopts the new helper) or retroactively (migrate existing call sites). |

Walk FCPSS coverage at this phase per [`fcpss-gate.md`](fcpss-gate.md).
The duplicate-count claim is itself an evidence claim — verify the
search method covered the right surfaces per
[`evidence-discipline.md`](evidence-discipline.md) §4 (count "3 copies
found via [search]" not "there are 3 copies"). A miscounted fourth
copy flips the decision from "open a ticket" to "refactor IS the
change."

### 3. Execute

- **Write the helper / land the split + test pin first.**
- **Migrate callers one at a time, with the suite green between each.**
- **Verify the signal cleared** — re-run the checker, re-count file
  size, confirm the near-match rationale's verdict.
- No half-migration. No "we'll get to it next sprint."

### 4. Prevent regression

The test pin is the durable guard. The mechanical signal (duplication
checker, file-size hook) keeps watching the surface. The AGENTS.md
duplication policy is the steady-state authoring rule.

## Tier classification

Refactor extractions are **Tier 1 by default** — they touch shared
canonical files and affect every reader. Narrow private-helper
refactors with green tests stay Tier 3 (same-vendor self-review,
auto-merge on green CI).

## The ≥70% behavioral-applicability heuristic

When evaluating an existing helper as a near-match for new work:

- **≥70% of the behavior overlaps** → extend the existing helper
- **<70%** → author new, with the gap documented in the new code's
  header comment

This heuristic gates the build-feature near-match scan and the
refactor extraction decide phase identically.

## Adapt for your project

Wire your duplication checker (`jscpd`, `pmd-cpd`, `simian`) and
file-size pre-commit hook to your stack. Set the warn / fail
thresholds for your language. Pick the LOC at which a file's size
becomes a refactor signal.
