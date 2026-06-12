---
name: auto-trigger-discriminator
description: Kickoff-vs-iteration check at the head of every auto-triggered skill. Iteration / polish / investigation utterances short-circuit silently; only genuine kickoff utterances fire the protocol-walk.
status: reference
---

# Auto-trigger discriminator

The biggest source of friction in skill design is that a skill
description ends up firing on every casual mention of its topic. "Fix
that comment" should not start a fresh feature-build walkthrough.
"Let me think out loud" should not fire `/refactor-extract`.

The fix is a **kickoff-vs-iteration check** at the head of every
auto-triggered skill body. Iteration utterances short-circuit
silently; only kickoff utterances fire the protocol-walk.

## The check

When an auto-triggerable skill is about to fire, ask:

| Signal | Classification |
|---|---|
| **Kickoff** — "let's build", "implement X", "I want to add", "starting Y", explicit `/<skill>` invocation | Fire the protocol-walk |
| **Iteration** — "fix that", "polish this", "tweak the X", "rename Y" | Short-circuit silently; conversation continues without the protocol-walk |
| **Investigation** — "let me think", "what would this look like", "explore the option of", "tell me about" | Short-circuit silently |
| **Reference** — "in `/build-feature`, the rule is..." (the skill is being CITED, not invoked) | Short-circuit silently |

## When the discriminator does NOT apply

- **Explicit slash-command invocation** (`/build-feature`, `/refactor-extract`)
  bypasses the discriminator entirely. The supervisor typed the command;
  the supervisor wants the walk.
- **Mechanical-signal triggers** (a duplication cluster, a file-size
  fail) are kickoff by definition.
- **Calendar / cron triggers** (the weekly `/refresh-vendor` reminder)
  are kickoff by definition.

## Where this discriminator fires

At the **first step of every auto-triggered skill body**:

```markdown
1. **Discriminate kickoff vs iteration** per `auto-trigger-discriminator.md`.
   If iteration / polish / investigation, exit silently.
2. <next step of the actual protocol walk>
```

## Why this matters

Without the discriminator, every mention of "refactor" in chat would
fire `/refactor-extract`. Every mention of "feature" would fire
`/build-feature`. The supervisor would either silently endure the
noise OR have to explicitly negate every casual mention. Both are
worse than a one-line check at the head of each skill body.

## Adapt for your project

Apply the discriminator to every auto-triggered skill you author.
Calibrate the kickoff/iteration boundary to your project's vocabulary
— if your team uses "implementation" the way other teams use
"feature", make sure your skill descriptions and discriminator
recognize that.
