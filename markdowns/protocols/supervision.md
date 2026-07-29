---
name: supervision
description: Tier-aware merge gating and chat-as-checkpoint. Tier 1/2 PRs hold for explicit "ship it" after a structured chat block; Tier 3/4 auto-merge on green CI. Decision-moment notation makes multi-step flows scannable.
status: reference
---

# Supervision

Once cross-vendor review is done, supervision decides whether the PR
auto-merges or holds for explicit approval. The rule is tier-aware.

## Assumption: one supervisor

This protocol assumes **one human** holds the supervisor seat per PR.
That single person:

- Classifies the tier when ambiguous.
- Reads the chat checkpoint when CI goes green.
- Types "ship it" (or sends it back).

The protocol does not address: multi-supervisor approval rules,
async handoff between supervisors in different time zones, conflicts
when supervisor A approves and supervisor B disagrees, or quorum gates.

**If your project has multiple supervisors**, you have to add the
arbitration rule yourself before adopting. Document it in your
project's `supervision.md` "Adapt for your project" section: who has
final shipit authority, what happens if two supervisors disagree,
whether the chat checkpoint waits for one approval or many. Without
that addition, the protocol's "explicit ship it" rule is ambiguous on
multi-supervisor teams.

The substrate was authored on a solo-supervisor workflow. It scales
down to that case cleanly; scaling it up to teams is a project-side
addition, not something the starter ships.

## Tier-aware merge gating

| Tier | Behavior on green CI |
|---|---|
| **Tier 1** | Hold for explicit "ship it". Chat-checkpoint posted; merge only after the supervisor's explicit approval. |
| **Tier 2** | Same as Tier 1. |
| **Tier 3** | Auto-merge on green CI. |
| **Tier 4** | Auto-merge on green CI. |

## The chat-checkpoint template

Plain markdown rendered live in the terminal when CI goes green on a
Tier 1 / Tier 2 PR:

> **PR #`<n>` — `<title>`**
>
> **What this PR does** — 3–5 sentences a stakeholder can read cold.
> What was wrong or missing before, what this PR changes, what the
> supervisor notices day-to-day. No protocol jargon, no bare
> `file:line` citations, no rubric-item-N references. Behavioral
> language, not "§2 rewritten."
>
> **Audit trail**
>
> - Anchored observations: self-check `<N items, all resolved>`;
>   cross-vendor (`<reviewer>`) `<N items, all resolved | "skipped — reason">`.
> - No-anchor observations (declined): self-check `<N | "none">`;
>   cross-vendor `<N | "none">`.
> - Iteration: `<N rounds; if N>1, one short sentence per round in plain English>`.
> - FCPSS coverage: `<paste the F/C/P/S/S block from the PR or plan>`.
>
> Awaiting "ship it" before merge.

**"Ship it"** = explicit approval (`ship it`, `merge it`, `go`, `yes
ship`). Mild assent (`ok`, `sure`) does not count; if unsure, ask
once.

## Pre-push secret gate (required)

No branch is ever pushed — and no PR opened — without a clean
**full-history** secret scan. This is a hard gate, not advisory: the
push does not happen until the scan is clean and the result is logged.

Before the first `git push` of any branch:

1. **Scan the whole history** (not just the working tree):
   `gitleaks git --no-banner .` (gitleaks 8.19+; older builds:
   `gitleaks detect --source . --no-banner`). History matters because a
   secret committed and later deleted still lives in the objects a push
   uploads.
2. The scan must exit clean (no findings). A finding **blocks the
   push**: remove the secret, rewrite the history that carried it (the
   branches are local until pushed — rewriting is safe), **rotate the
   exposed credential**, then re-scan.
3. **Log the clean result the same turn**, surfaced in chat per the
   log-surfacing rule:
   `[LOG] gitleaks: clean (full history) — <branch> @ <short-sha>`.
   Record it in the ledger that accompanies the shipped change.

This complements the `.gitignore` secret patterns, which stop secrets
from being *staged* in the first place; the scan catches anything that
slipped past them, including in historical commits. Keep both in sync:
when a new secret-bearing filename convention appears, add it to
`.gitignore` **and** rely on the scan as the backstop. CI re-runs the
same scan on every PR and push to main (the `secret-scan` job in
`check.yml`) as the merge-time backstop: a finding fails the check
that tier-gated merges are held to. (Blocking is as strong as the
merge discipline — add branch protection requiring the check to make
it GitHub-enforced.) It does not replace the local pre-push scan: a secret
pushed to a feature branch has already left the machine before CI
fires, so a CI-caught finding still walks step 2 in full, including
rotating the exposed credential.

## Decision-moment notation

Inline tags when narrating a multi-step flow in chat:

| Tag | Meaning |
|---|---|
| `[SUPERVISOR]` | The human's call — explicit decision required to proceed |
| `[WORKER]` | The primary vendor executed (wrote code, ran the rubric, etc.) |
| `[REVIEWER]` | A peer vendor ran via the cross-vendor dispatcher |
| `[AUTO]` | A mechanical gate fired — pre-commit hook, CI check, archive job |
| `[LOG]` | An append-only log was written; the entry is also surfaced in chat the same turn |

## Worker self-check → cross-vendor symmetry

Every rubric type (code, plan, content, persona, research) runs in two
stages: self-check first (same rubric, fresh context), cross-vendor
second (peer vendor). Both feed the chat checkpoint. The **no-anchor
delta** — observations the cross-vendor pass surfaces that self-check
missed — is the load-bearing signal.

## Log-surfacing at write-time

Append-only logs are unreliable when the agent doing the work is the
one self-reporting. The fix is asymmetric:

- The log file is the durable record. It survives sessions and feeds
  future agents.
- Every log entry surfaces in chat the moment it's written:
  `[LOG] <path>: <one-line entry just written>`.
- Required artifacts are mechanically enforced — pre-commit gates, PR
  templates, ship-with-PR contracts — so the system refuses to merge
  without them.

The supervision invariant is "the supervisor sees the writes happen,"
not "the supervisor trusts the self-report."

## Session-brief lifecycle

Every cross-vendor session creates its brief at
`markdowns/briefs/<artifact-name>.md` as Step 0, commits it, and
passes it to the cross-vendor dispatcher via `--brief` on every pass.
After "ship it" lands, the brief is removed in a follow-up commit
before merge. Squash collapses everything; `main` never holds the
brief long-term.

## Adapt for your project

Decide what counts as your "ship it" supervisor (one human, a
rotating reviewer, an approval bot). Wire the chat-checkpoint into
your terminal narration so the block surfaces automatically when CI
goes green on Tier 1/2 PRs.
