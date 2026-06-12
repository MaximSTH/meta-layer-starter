---
name: stake-matrix
description: Four-tier change-severity classification. Walk top to bottom; stop at the first YES. Tier decides reviewer + merge behavior + which gates fire.
status: reference
---

# Stake matrix

Every change lands at one of four tiers. The tier decides whether a
peer vendor reviews it, whether it auto-merges on green CI, and which
gates fire on the diff.

## Decision tree

Walk top to bottom. Stop at the first YES.

| Question | If YES → Tier |
|---|---|
| **Production-irreversible?** (money handling, security boundaries, data-integrity migrations, payment integrations, auth flows) | **1** |
| **Quality-load-bearing?** (new user-facing features, marketing copy that ships externally, new analytics events, onboarding flows) | **2** |
| **Routine code change?** (refactoring a private helper with green tests; adding a function not yet wired in; dev-only dep bump) | **3** |
| Markdown edits, comments, formatter changes, frontmatter-only | **4** |

## Per-tier behavior

| Tier | Reviewer | Merge behavior | Pre-commit |
|---|---|---|---|
| **Tier 1** | Peer vendor mandatory (different model than the worker) | Hold for explicit "ship it" | Full gate set |
| **Tier 2** | Peer vendor mandatory (lighter resolution bar than Tier 1) | Hold for explicit "ship it" | Full gate set |
| **Tier 3** | Same vendor with rubric in fresh context | Auto-merge on green CI | Full gate set |
| **Tier 4** | Pre-commit hooks only | Auto-merge on green CI | Subset (lint / format) |

## Three conventions that extend the basic shape

- **Plan-for-implementation.** A markdown plan that plans a Tier 1
  implementation is itself Tier 1, even though it ships as markdown.
  Plan flaws caught early cost minutes; caught late, they cost days.
- **Content-for-implementation.** A copy block bundled with a Tier 1/2
  implementation inherits that tier and routes through content review.
- **Research-for-implementation.** Research output that feeds a Tier
  1/2 implementation (model prompt data, persona claims, domain
  mappings) inherits that tier and routes through research methodology.

## When tier is unclear

Escalate up. Tier 2 instead of 3 is cheap; Tier 3 instead of 1 is
dangerous.

## When the agent meets an unclassified surface

In a new codebase, the surface-to-tier table is incomplete. The agent
will hit surfaces nothing in the table covers — a new directory, a
file shape that doesn't pattern-match prior work. The walk:

1. **The agent classifies provisionally.** It picks a tier using the
   decision tree above (production-irreversible → quality-load-bearing
   → routine → markdown-only), citing the reasoning in one line.
2. **The agent surfaces the classification in the chat checkpoint**
   as a pending addition: *"New surface: `lib/payments/checkout/*`. I
   classified Tier 1 because it touches money. Approve to add the row,
   or redirect."*
3. **The supervisor approves, refines, or redirects.** Approval adds
   the row to the project's surface table at the top of `AGENTS.md`.
   Refinement adjusts the tier or the path glob; redirection sends
   the work back for re-scoping.
4. **The row sticks.** Future PRs against the same surface route
   automatically; no per-PR tier judgment after this.

The first month of a new codebase, expect 1–3 unclassified-surface
prompts per week. By month three, the prompts approach zero — every
load-bearing surface has been classified once.

Default when the agent is genuinely uncertain: **propose Tier 2**.
Erring upward costs an extra review pass; erring downward skips review
on something that needed it.

## Adapt for your project

Author a per-tier examples table for your stack — what does each tier
actually cover in your codebase? Concrete examples (file paths,
named features, named flows) make tier classification a 30-second
decision at PR time instead of a debate.
