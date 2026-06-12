---
name: build-feature
description: Walk for building / creating / implementing a new feature. Classify type, run near-match scan, FCPSS, tier-correct review. The `/build-feature` skill auto-walks this protocol on kickoff utterances.
status: reference
---

# Build feature

When a new feature is being added (a screen, a flow, an integration,
a backend endpoint), walk this protocol from kickoff. The
`/build-feature` skill is the thin wrapper that walks it.

## The walk

| Step | What |
|---|---|
| **1. Discriminate kickoff vs iteration** | Per [`auto-trigger-discriminator.md`](auto-trigger-discriminator.md). If iteration / polish / investigation, exit silently — conversation continues without the protocol-walk. |
| **2. Classify the feature type** | New surface, revise existing, optimization, security, research. Maps to FCPSS work shapes. |
| **3. Run the near-match scan** | Search the codebase for existing helpers / components / patterns that could be extended or reused before authoring new code. If a near-match is ≥70% applicable, enter [`refactor-extraction.md`](refactor-extraction.md) at the Decide phase. "I couldn't find a near-match" requires two channels per [`evidence-discipline.md`](evidence-discipline.md) §3 before it supports authoring new — grep alone is one channel, not enough. |
| **4. Classify the tier** | Per [`stake-matrix.md`](stake-matrix.md). Tier decides reviewer and merge behavior. |
| **5. Draft the plan** | If Tier 1/2, plan goes through [`plan-review.md`](plan-review.md) before any code. |
| **6. Walk FCPSS** | Per [`fcpss-gate.md`](fcpss-gate.md). 5/5 ships; 4/5 doesn't. |
| **7. Implement** | Author the change with the FCPSS dimensions in mind. Tests first for any bug-fix path. |
| **8. Self-check** | Same rubric in fresh context per [`cross-vendor-review.md`](cross-vendor-review.md). |
| **9. Cross-vendor review** | Tier 1/2 only. Peer vendor reads the diff cold. |
| **10. Chat-checkpoint + ship** | Per [`supervision.md`](supervision.md). Tier 1/2 holds for explicit "ship it". |

## The near-match scan

Before creating any new file or helper, scan up to 5 nearest existing
candidates and decide:

- **Extend an existing helper / component** if applicability is ≥70%.
- **Author a new one** only if all candidates are <70% applicable, with
  the gap documented.

The scan is the gate against code-entropy growth. New files are the
expensive default; reuse is the cheap default.

## Adapt for your project

Author per-surface examples — what counts as a "feature build" in
your codebase (a new screen? a new endpoint? a new module?), and what
search patterns the near-match scan uses (which directories to grep,
which file extensions to consider).
