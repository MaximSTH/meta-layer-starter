---
name: iteration-discipline
description: When to keep looping and when to escalate. Distinguishes mechanical-gate loops (test fails / hook fires) from judgment-gate loops (does this copy land?). Mechanical loops self-iterate to convergence; judgment loops escalate after one round.
status: reference
---

# Iteration discipline

Agentic loops happen whether you author this protocol or not. The
model-tool-observation cycle is the harness's job — every tool call
is one iteration, every observation feeds the next decision. **The
meta-layer's job is not to make loops happen. It's to say when they
stop.**

This protocol is about stopping criteria. Specifically: when is "loop
again" the right call, when is "escalate to the supervisor" the right
call, and when is "ship it" the right call.

## Two loop shapes that need different treatment

| Loop shape | Gate | Stopping criterion | Default budget |
|---|---|---|---|
| **Mechanical-gate loop** | A mechanical signal that converges (test passes / fails, hook fires / clears, type check green, lint clean, pre-commit hook accepts the commit) | Gate condition met (test green, hook silent, etc.) | 3 rounds before escalation |
| **Judgment-gate loop** | A judgment signal that doesn't converge mechanically (does this copy land? is this UX right? is this protocol clear?) | Supervisor's "ship it" or "revise" call | 1 round before escalation |

The distinction matters because **the model can self-loop safely
toward a mechanical gate but should NOT self-loop toward a judgment
gate.** A mechanical gate gives the model unambiguous feedback —
"test red → fix it → test green → done." A judgment gate gives the
model ambiguous feedback — "the supervisor didn't like this version
but didn't say why" — and a second iteration without supervisor
input is likely to repeat the same wrong call differently.

## Convergence criteria already in the meta-layer

Several existing protocols imply iteration gates. This protocol names
them in one vocabulary:

| Protocol | Gate type | Convergence condition |
|---|---|---|
| [`cross-vendor-review.md`](cross-vendor-review.md) | Judgment (peer-vendor anchored observations) | No anchored observations remain unfixed |
| [`fcpss-gate.md`](fcpss-gate.md) | Mechanical (per-dimension binary coverage) | 5/5 dimensions covered |
| [`refactor-extraction.md`](refactor-extraction.md) | Mechanical (signal cleared) | Duplication checker / file-size hook no longer fires |
| Testing (in `AGENTS.md`) | Mechanical (test green) | CI green on the PR branch |
| Supervisor "ship it" | Judgment (human call) | Explicit "ship it" / "merge it" — mild assent doesn't count |

If a loop you're walking isn't covered above, classify it as
mechanical or judgment before iterating. The classification picks the
budget.

## Iteration budget + escalation

**Mechanical-gate budget: 3 rounds default.**

After 3 rounds with the gate still failing, escalate to the supervisor
even if the model has "another idea." Three consecutive failed
attempts at a mechanical gate usually means the model has the wrong
mental model — a fourth attempt with the same model is more likely to
break something else than to fix the original issue.

The escalation surfaces:
- What the gate is and what it's still saying.
- What was tried in each round.
- The model's current hypothesis about why the gate keeps failing.

The supervisor either redirects (different approach) or unblocks
(missing context the model couldn't infer).

**Judgment-gate budget: 1 round default.**

After one supervisor "revise" call, the model's next move is not
"another attempt." It's **"what specifically did you want different?"**
A judgment gate doesn't converge through trial; it converges through
clarification.

The exception: if the supervisor's redirect was specific and
unambiguous ("make the headline shorter," "use the imperative
voice"), one more iteration is fine before re-checking. But three
rounds of judgment iteration without explicit criteria is a smell —
the supervisor didn't give the model enough to converge.

## When the loop budget is wrong for your case

The defaults are sized for typical agentic-coding work. Adjust per
your project:

- **Bug fixes with a written failing test.** Mechanical gate, but the
  budget can be smaller — 1 round is usually enough; 2 rounds is
  unusual; 3 rounds means the test is wrong or the model is missing
  context.
- **Build / migrate / refactor with parallel work in flight.** Budget
  should reflect the cost of a rollback. If a partial commit blocks
  other PRs, escalate earlier.
- **Research / exploration loops.** Judgment-shaped by default. Budget
  by time-boxing rather than round count — "20 minutes of exploration,
  then surface what you found."

State the chosen budget in the task brief if it diverges from the
default. The cost of a forgotten budget is more wasted iterations
than the cost of authoring the budget upfront.

## What this protocol does not cover

- **The harness's tool-use loop** (Claude Code's `--print` /
  Antigravity's `agy --print` / Codex's `codex exec`). That's
  vendor-owned. This protocol is about the meta-layer's stopping
  criteria, not the harness's iteration mechanics.
- **CI retries.** Those are infrastructure-level — usually 1-2 retries
  for flaky-network tolerance, no model judgment involved.
- **Long-running background loops** (`/loop` skill in Claude Code,
  cron jobs). Those are time-shaped, not round-shaped, and live
  outside the synchronous "session" the meta-layer protocols target.

## When to escalate vs ship vs iterate (one-line)

| Signal | Action |
|---|---|
| Mechanical gate cleared | Ship it (or proceed to the next gate) |
| Mechanical gate failing, budget remaining | Iterate |
| Mechanical gate failing, budget exhausted | Escalate |
| Judgment gate cleared ("ship it") | Ship |
| Judgment gate ambiguous ("not quite") | Clarify, then iterate once |
| Judgment gate still ambiguous after clarification | Escalate (deeper supervisor input needed) |

## Adapt for your project

- **Set a default iteration budget for your common gates.** If your
  codebase has a slow test suite, "3 rounds" might be impractical —
  reduce to 2 so a failed test budget doesn't cost half an hour.
- **Name your judgment gates explicitly.** Protocols vary in how
  judgment-shaped they are; per-project guidance helps. Examples:
  copy review (judgment), security review (mechanical for static
  checks, judgment for threat-model deltas), persona stress-test
  (judgment).
- **Wire the iteration count into the chat-checkpoint** per
  [`supervision.md`](supervision.md) so the supervisor sees how many
  rounds happened before ship-it landed. A 4-round iteration on a
  Tier 2 PR is a signal worth noticing even if the final state
  shipped clean.
