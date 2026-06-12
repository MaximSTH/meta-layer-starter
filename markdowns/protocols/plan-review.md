---
name: plan-review
description: Cross-vendor review rubric for markdown plans before implementation begins. Tier matches the tier of what the plan plans, not the tier of the markdown-as-deliverable. A flaw caught at plan-time costs minutes; caught at implementation, days.
status: reference
---

# Plan review

A plan that plans a Tier 1 implementation is itself Tier 1. Tier
applies to the activity, not just to code-shipping. Plan flaws
detected early cost minutes; detected at implementation, they cost
days.

## When the rubric fires

| What the plan plans | Plan-review tier |
|---|---|
| Tier 1 implementation | **Tier 1** plan-review |
| Tier 2 implementation | **Tier 2** plan-review |
| Tier 3 implementation | **Tier 3** (same vendor in fresh context) |
| Pure-process / meta plan (no code follows) | Match the tier of the meta artifact it'll produce |

## The rubric

The reviewer reads the plan cold and audits against:

| Dimension | Question |
|---|---|
| **Goal clarity** | Is the deliverable named and bounded? What does "done" look like? |
| **Dependencies** | What must exist before this can ship? What does this block? |
| **Definition of done** | Are the success criteria measurable? What gates does the implementation walk? |
| **Hidden assumptions** | What is the plan taking for granted that might not hold? |
| **Tradeoffs** | What did the author consider and reject? Why? |
| **Persona grounding** | If the work touches a user-facing surface, does the plan reference the relevant persona(s)? |
| **FCPSS coverage** | If the implementation is Tier 1/2, does the plan walk FCPSS at draft time? |

## Anchored vs no-anchor

Same rule as code review per [`cross-vendor-review.md`](cross-vendor-review.md):
observations cite a specific anchor (a section in the plan, a missing
detail in a named area, a contradiction with a cited rule) or get
declined.

## Exit condition

Ship the plan when no anchored observations remain unfixed. The
implementation then opens against the approved plan; the plan's
content is the contract.

## Adapt for your project

Author your project's "what a good plan looks like" template — sections
the plan must include (Goal, Approach, Deliverable, Rollback, Tests).
Author the reviewer-prompt template that gets pasted into the
cross-vendor call.
