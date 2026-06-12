---
name: fcpss-gate
description: Universal pre-ship coverage gate. Any work affecting user-visible or system-visible behavior answers Functional / Cross-cutting / Performance / Security / Stability before shipping, across all 5 work shapes.
status: reference
---

# FCPSS gate

Process discipline, not a tool feature. Before any work that changes
user-visible or system-visible behavior ships, the plan or PR answers
five questions. Coverage is **binary** — 5/5 ships; 4/5 doesn't.

## The five dimensions

| Letter | Dimension | The question |
|---|---|---|
| **F** | Functional | What user-visible or system-visible behavior changes after this ships? Concrete, named. |
| **C** | Cross-cutting | What shared canonical files / pre-commit gates / other surfaces does this touch? Inherits from where, propagates to where? |
| **P** | Performance | Round-trip count, latency budget, cost / footprint envelope. Does it regress measured performance? |
| **S** | Security | Auth boundary, row-level security, input sanitization, secret surface, threat-model deltas. |
| **S** | Stability | Error boundaries, retry, offline behavior, partial-failure recovery, observability. |

Each bullet must be filled. A bullet that reads "N/A" must explain why.

## Five work shapes the gate applies to

| Shape | What it looks like |
|---|---|
| **New surface** | A surface that didn't exist before — new screen, new repository, new auth-bound table, new admin action, new marketing page. |
| **Revise existing** | A surface ships materially changed behavior — rewrite onboarding, refactor a model prompt, redesign a dashboard, change paywall flow. |
| **Research** | Output is a decision / audit memo / dataset that may feed model prompts, user-facing copy, or a future surface. |
| **Optimization** | Behavior is the same; cost / speed / footprint changes — round-trip reduction, query batching, bundle-size cuts. |
| **Security** | Threat-driven work — new auth policy, secret rotation, CSRF mitigation, input-sanitization fix. |

## Out of scope

Cosmetic / mechanical changes that don't move user-visible or
system-visible behavior (typo fix, color tweak, dependency patch-bump),
and polish commits inside a PR whose parent change already walked
FCPSS.

## Where the gate fires

| Trigger | Source |
|---|---|
| Drafting a per-surface plan | The FCPSS template lives in the plan file; the deep-dive walks it at ship time |
| Reviewing a Tier 1 / Tier 2 PR | Supervision chat-checkpoint requires the block; absence is a blocker |
| `/build-feature` skill | Walks the author through the template at the FCPSS step |
| `/refactor-extract` skill | Walks coverage at the Decide phase |
| The cross-surface AGENTS.md operating principles | Universal pre-ship rule — any work affecting user-visible or system-visible behavior walks this gate |

## Adapt for your project

Author per-work-shape examples for your stack — what does each
dimension actually mean for a new screen in your codebase? for a
research deliverable in your domain? Concrete examples make the gate
walkable in 5 minutes instead of debated each PR.
