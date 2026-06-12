---
name: protocols-index
description: Index of protocols + token-efficiency rules. The protocols are the reference-material substrate that skills point at; rules R1–R5 keep them readable.
status: reference
---

# Protocols

Protocols are the project-agnostic reference material that skills walk
on kickoff. Each protocol is a framework abstract — the *shape* of a
rule, gate, or review rubric. Worked examples live in your project,
not in these files.

## The protocols shipped with this starter

| Protocol | What it covers |
|---|---|
| [`fcpss-gate.md`](fcpss-gate.md) | Universal pre-ship coverage gate. 5 dimensions × 5 work shapes. |
| [`stake-matrix.md`](stake-matrix.md) | 4-tier change-severity classification. |
| [`cross-vendor-review.md`](cross-vendor-review.md) | Peer-vendor code review + anchor-or-decline. |
| [`plan-review.md`](plan-review.md) | Review rubric for markdown plans before implementation. |
| [`content-review.md`](content-review.md) | Cross-vendor review for user-facing rendered content. |
| [`persona-stress-test.md`](persona-stress-test.md) | Three-mode rubric for changes affecting how the project talks to a user type. |
| [`research-methodology.md`](research-methodology.md) | Per-data-point research discipline + cross-vendor audit. |
| [`supervision.md`](supervision.md) | Tier-aware merge gating + chat-as-checkpoint. |
| [`build-feature.md`](build-feature.md) | Walk for building / creating / implementing a new feature. |
| [`refactor-extraction.md`](refactor-extraction.md) | Four-phase signal-driven refactor flow. |
| [`refresh-vendor.md`](refresh-vendor.md) | Vendor knowledge refresh cadence. |
| [`evidence-discipline.md`](evidence-discipline.md) | Pre-recommendation discipline — falsification first, asymmetric burden of proof, multi-channel verification. Fires before any destructive recommendation. |
| [`iteration-discipline.md`](iteration-discipline.md) | When to keep iterating vs escalate. Mechanical-gate loops (3 rounds → escalate); judgment-gate loops (1 round → clarify). |
| [`failure-attribution.md`](failure-attribution.md) | Four-category rubric (vendor regression / protocol gap / supervisor miss / agent error) for attributing a production failure before retry. |
| [`auto-trigger-discriminator.md`](auto-trigger-discriminator.md) | Kickoff-vs-iteration check at the head of every auto-triggered skill. |
| [`markdown-lifecycle.md`](markdown-lifecycle.md) | YAML frontmatter conventions for project markdown. |
| [`doc-consistency.md`](doc-consistency.md) | Cross-document semantic consistency — SSOT-for-values, value-authority ladder, post-edit sweep, declared quoters, escalation path. |
| [`rubric-shared-anchors.md`](rubric-shared-anchors.md) | The five anchor categories every review rubric accepts. |

## Five token-efficiency rules

| # | Rule | How it's enforced |
|---|---|---|
| **R1** | Protocol files cap at 200 lines. Past that, split into linked sub-protocols. | Convention. Author your own pre-commit gate when the project's drift count justifies it; the starter doesn't ship one. |
| **R2** | Lead with table of contents + decision tree. Jump-to-section without loading the whole file. | Convention; reviewed at PR time. |
| **R3** | Sub-protocols are separate files. Link out instead of bloating the parent. | Falls out of R1 + R2. |
| **R4** | Skill bodies stay short and point at the protocol (target: under 20 lines, ceiling around 25). | Convention. The starter ships skill bodies under this ceiling; a pre-commit size gate is a reasonable project-specific addition. |
| **R5** | Skill descriptions are narrow trigger specs (~80 tokens). They say *when* the skill fires, not what it does. | `scripts/check-skill-frontmatter.sh` validates frontmatter presence (`name`, `description`) and the portable-subset constraint (no Claude-specific fields like `effort` / `hooks` / `allowed-tools` in `.agents/skills/`). The ~80-token trigger-spec convention is reviewed at PR time, not mechanically enforced. |

## Adapt for your project

Each protocol carries an "Adapt for your project" section at the
bottom — that's where you customize for your stack. The frameworks
themselves are stable.

If your project needs a protocol that isn't shipped here (e.g., a
specific compliance review, a domain-specific audit), author it
following the same shape:
- Frontmatter (name, description, status)
- Framework explanation
- Decision tree / table
- "When this fires" section
- "Adapt for your project" closing section
