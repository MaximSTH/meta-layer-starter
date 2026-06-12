---
name: persona-stress-test
description: Three-mode rubric for changes that touch how the project talks to a specific user type. Walkthrough mode (does the change land with this persona?), coherence mode (does the persona profile still hold?), market-grounding mode (is the persona profile still anchored in real discourse?).
status: reference
---

# Persona stress-test

When a change affects how the project talks to a specific user type
(onboarding copy, paywall flow, model-prompt audience targeting,
user-facing labels), the change is stress-tested against the relevant
persona(s) before shipping.

## Three modes

Different changes fire different modes. A single PR may fire one,
two, or all three.

| Mode | When it fires | What it checks |
|---|---|---|
| **1. Walkthrough** | The change is user-facing AND a specific persona is the primary audience | Walk the persona through the new flow / read the new copy. Does it land? Does the persona's friction match the project's intent? |
| **2. Coherence** | The persona profile itself is being revised in the same PR | Does the revised profile contradict claims elsewhere in the profile? Does it still align with prior anchored claims? |
| **3. Market-grounding** | The persona is being newly authored OR its claims are being substantially revised | Are the persona's claims grounded in real public discourse (forums, reviews, social posts) about this user type? Or is the persona invented from imagination? |

## When the rubric fires

Persona stress-test fires per the tier of the implementation it ships
with. Tier 1 (e.g. user-facing AI text targeting this persona class)
mandates the walkthrough mode; Tier 2 (e.g. marketing copy) typically
fires walkthrough; coherence and market-grounding fire when the
profile itself is being touched.

## The rubric structure

Each mode is its own rubric with its own reviewer-prompt template.
The cross-vendor dispatcher routes to the right one based on the
`--rubric persona-walkthrough` / `--rubric persona-coherence` /
`--rubric persona-market-grounding` flag.

Anchored observations are scored against:
- The persona profile (named claims)
- The brand voice / copywriting register
- The discourse audit (if one exists)
- The product surface where the change lands

## Anchored vs no-anchor

Per [`cross-vendor-review.md`](cross-vendor-review.md). If the
reviewer can't cite a profile claim, a register rule, or a surface
constraint, the observation auto-declines.

## Conditional firing

A feature that serves two persona classes fires persona stress-test
twice (once per class). The protocol isn't a one-shot per PR.

## Adapt for your project

Author your project's personas — name them, ground them in real
discourse, give them concrete claims (what they care about, what they
avoid, what makes them abandon). Each persona file is what
walkthrough / coherence modes anchor against. Author the
reviewer-prompt templates for the three modes.
