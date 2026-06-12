---
name: onboarding
description: First-day walkthrough for someone new to a project built on the meta-layer-starter. Read these protocols in this order, walk these surfaces, here's the operating model. Not for the project's author — for the second participant.
status: reference
---

# Onboarding

For your first day on a project built on the meta-layer-starter.
This is the lightweight version — not a comprehensive tour, just the
30 minutes you need before your first PR.

## The operating model in one paragraph

You're the supervisor. The agent writes the code. Your job is
review-and-redirect, not implementation. Every Tier 1 or Tier 2 PR
posts a chat checkpoint with what-this-PR-does + audit trail +
FCPSS coverage; you read it, you approve "ship it" or send it back.
Tier 3 / Tier 4 PRs auto-merge on green CI. You see drift alerts,
escalations from iteration budgets, and failed evidence-discipline
checks in chat. Your day-1-to-day-30 is high supervision overhead;
your day-90 is much lower as the surface-to-tier table stabilizes
and the agent learns the project's conventions.

## Read these protocols in this order

The four load-bearing ones — scan these before your first review:

1. [`AGENTS.md`](../../AGENTS.md) — operating principles + Doc Map.
   ~10 minutes. The behavioral primer + where to find everything else.
2. [`fcpss-gate.md`](../protocols/fcpss-gate.md) — universal pre-ship
   checklist. ~3 minutes. The five questions every PR answers before
   merge.
3. [`stake-matrix.md`](../protocols/stake-matrix.md) — tier
   classification. ~3 minutes. Which PRs need cross-vendor review,
   which auto-merge.
4. [`evidence-discipline.md`](../protocols/evidence-discipline.md) —
   pre-recommendation discipline. ~5 minutes. The single most
   load-bearing protocol in agent-driven work — read this one carefully.

That's your first ~20 minutes. **Scan-mode, not deep-read** — the
protocols are written for the agent to follow on every PR; you only
need to recognize the patterns when an agent chat checkpoint
references them. Deep-read a protocol when it fires on a PR and you
don't know what it produced. Pair the scan with the worked example
in [`example-pr-walkthrough.md`](example-pr-walkthrough.md) — that's
where the scan-level knowledge clicks into a concrete shape.

## Read these when they fire (situational)

You don't need to internalize these upfront. Read them when a PR
walks them and you don't know what the protocol expects.

- [`supervision.md`](../protocols/supervision.md) — when you see your
  first chat checkpoint.
- [`cross-vendor-review.md`](../protocols/cross-vendor-review.md) — when
  you see your first peer-vendor review report.
- [`build-feature.md`](../protocols/build-feature.md) — when you see
  the agent propose a build plan.
- [`refactor-extraction.md`](../protocols/refactor-extraction.md) —
  when the agent surfaces a duplication signal.
- [`iteration-discipline.md`](../protocols/iteration-discipline.md) —
  when the agent says "round 3, escalating to you."
- [`failure-attribution.md`](../protocols/failure-attribution.md) —
  when something breaks in production and the team's about to retry
  the agent.

## Walk these surfaces

Open each in a tab, read for two minutes:

- [`markdowns/meta-layer/example-pr-walkthrough.md`](example-pr-walkthrough.md) —
  synthetic worked example: what the gate produces (chat checkpoint,
  FCPSS coverage, cross-vendor review report) on a real-shaped PR.
  Read this BEFORE your first real review so you know what the
  shape looks like.
- [`markdowns/meta-layer/cross-vendor-harness.md`](cross-vendor-harness.md) —
  the architecture you're operating under (AGENTS-master, sync mechanics).
- [`markdowns/meta-layer/comparisons.md`](comparisons.md) — what this
  template is and isn't, vs Karpathy / ECC / Hermes.
- [`markdowns/agents/vendor-knowledge/`](../agents/vendor-knowledge/) —
  the per-vendor capability files the agent depends on.

## Your first review — what to look for

When the first chat checkpoint lands, scan in this order:

1. **What-this-PR-does paragraph** — does it match your model of what
   should have happened? If the paragraph reads as protocol-jargon
   rather than plain English describing behavior, push back: "give me
   this in plain English, not in §-citations."
2. **Audit trail — anchored vs no-anchor counts.** Anchored
   observations cite a test, a lint rule, a named protocol section,
   or a brief line. No-anchor observations are style preferences
   the author declines. If anchored > 0 unresolved, the PR isn't
   ready to ship.
3. **FCPSS coverage.** Five dimensions each get a concrete answer
   (no "N/A" without a reason). A vague "Stability: handles errors"
   is incomplete; "Stability: payment retry on 503, exponential
   backoff, max 3 attempts, errors surface to Sentry" is concrete.
4. **Iteration count.** Round 1 is normal. Round 3+ on a single PR
   is a signal worth understanding — read the iteration log and ask
   the agent for the failure mode summary.

## When the agent confidently goes wrong

The single most common failure mode (this template was authored
partly in response to it): the agent says "I checked X, X doesn't
exist, removing it." Walk evidence-discipline §1 + §2: "what evidence
would change your recommendation? Did you verify against the second
channel?" Almost always the agent only checked one cheap channel.

The recovery: redirect, don't accept. Saying "verify against the
binary's --help" or "check the GitHub issues" usually surfaces the
missing evidence within one round.

## What this doc isn't

This onboarding is for someone joining the project — the second
person. The project's author / supervisor needs the full protocol
substrate, not this slim summary. If you're the author, your
onboarding is the full Doc Map in [`AGENTS.md`](../../AGENTS.md).

## Adapt for your project

After your first month, add a project-specific section at the bottom
naming the surfaces / decisions / conventions the next person should
know but couldn't infer from the protocols alone. The slim shape
above stays; project-specific context layers below.
