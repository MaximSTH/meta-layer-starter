---
name: comparisons
description: Honest head-to-head vs Karpathy's CLAUDE.md, ECC, and Hermes Agent. Each is best at a different thing; this file says when meta-layer-starter is the right choice and when it isn't.
status: reference
---

# Comparisons — why this template and not the alternatives

If you found this repo, you probably also found one or more of:

- [Karpathy's CLAUDE.md](https://github.com/multica-ai/andrej-karpathy-skills/blob/main/CLAUDE.md)
- [ECC](https://github.com/affaan-m/ecc) (Affaan M)
- [Hermes Agent](https://hermes-agent.nousresearch.com/) (Nous Research)

All three are useful. None are direct competitors. Each is best at a
different thing, and the wrong choice for the wrong audience hurts
everyone. Honest read below.

## The head-to-head

| | **Karpathy's CLAUDE.md** | **ECC** | **Hermes Agent** | **meta-layer-starter** |
|---|---|---|---|---|
| **Category** | Behavioral primer | Harness operator system | Autonomous agent platform | Discipline substrate |
| **Form factor** | One ~60-line CLAUDE.md | npm packages + GitHub App + Rust control plane + Tkinter dashboard + skills catalog | Server-resident binary + cross-platform connectors | Template repo (clone, adapt, sync) |
| **Where it runs** | Inside your IDE harness | Inside your IDE harness, expanding it | On your server, persistent | Your repo (markdown + scripts + hooks) |
| **What it ships** | 4 behavioral principles | 64 agents + 261 skills + 84 command shims | Slack/Discord/Email connectors + sandboxing + scheduled jobs | 17 protocols + 3 portable skills + vendor knowledge + harness sync |
| **Activity model** | Always-on context | Active (call into during sessions) | Autonomous (runs on its own) | Passive (read as context, walked by skills) |
| **Best for** | Solo Claude, low-stakes work | Power users wanting maximum feature breadth | Teams who want agents-as-employees | Solo / small teams running multi-vendor on stakes-bearing work |
| **Commercial** | OSS only | OSS + Pro tier ($19/seat/mo) | OSS only | OSS only |

## When to pick which

### Pick Karpathy's CLAUDE.md if

- You're solo, single-vendor, low-stakes.
- You want behavioral guidance without ceremony.
- The work doesn't justify multi-rubric or cross-vendor overhead.
- "Would a senior engineer say this is overcomplicated?" is the right
  gate for your codebase.

Karpathy's file is the best behavioral primer published. It's sharp,
short, and earns every line. If a one-file rulebook covers your
needs, take his — adding more is overhead you don't need.

### Pick ECC if

- You want maximum feature breadth: skills for every domain, agents
  for every task, dashboards, control planes.
- You're willing to learn ECC's opinions about how to work with
  agents (subagent orchestration, skill catalog, hook profiles).
- You value the social-proof signal (marketplace install count,
  weekly downloads, contributor base).
- You're OK with monthly maintenance velocity (ECC ships major
  releases every few weeks).

ECC is the only project in this space with that scale and momentum.
If you want kitchen-sink, take ECC — building yours from scratch will
take you a year to catch up.

### Pick Hermes Agent if

- You want a server-resident agent that accumulates memory and runs
  scheduled jobs.
- You're building agents-as-employees, not agents-as-coding-assistants.
- Persistent multi-platform connectors (Slack, Discord, Email) are
  load-bearing.

Hermes solves a different problem than the other three. If your
question is "I want an agent on my server," take Hermes; it's the
project in this space with that pitch.

### Pick meta-layer-starter (this template) if

- You're running two or more AI coding agents side-by-side
  (Claude Code + Codex + maybe Antigravity).
- The work has stakes — money, security, user safety, anything
  expensive to ship broken.
- You want the human in the loop on Tier 1 / Tier 2 decisions
  (cross-vendor review, supervised "ship it" before merge).
- You want discipline as the substrate, not skills as the surface.
- You'd rather hold ~5K lines of substance you can read in an hour
  than 50K lines of features you can't navigate.

This template's bet is **supervision as the unit, not autonomy**.
ECC and Hermes push toward agents doing more on their own; this
template pushes the opposite — agents handling implementation,
humans supervising the calls that matter.

## What this template does NOT try to be

Being explicit about the non-goals prevents wrong-audience
disappointment:

- **Not a CLAUDE.md.** That's one file of seventeen in here. The Karpathy
  approach handles the behavioral-primer job better.
- **Not a stack starter.** Zero opinions about Flutter / Rust / Python /
  Next.js / your-stack. Bring your own substrate; this template is
  about how to ship it.
- **Not a feature catalog.** No skill marketplace, no command shims,
  no dashboards. If feature breadth is what you want, take ECC.
- **Not an autonomous agent platform.** No server-resident mode, no
  persistent memory, no scheduled jobs. If that's what you want,
  take Hermes.
- **Not a Karpathy alternative for solo-Claude weekenders.** Too much
  ceremony for low-stakes work. The Prerequisites section in the
  README lets you prune to solo mode but you'd still be carrying a
  protocol library you'd never walk.
- **Not authored for multi-supervisor teams.** Every protocol
  assumes one human at the supervisor seat: one tier classifier, one
  "ship it" approver, one chat-checkpoint reader per PR.
  Multi-supervisor arbitration (who has shipit authority, what
  happens when two approvers disagree, async-handoff rules) is a
  project-side addition. The substrate scales down to solo cleanly;
  scaling up to teams is on you.

## The honest line

Each of the four tools is the right answer to a different question.
The wrong answer for *any* question is "the one with the most stars."

- **"What behavioral rules should my single Claude session follow?"**
  → Karpathy.
- **"How do I get the most agent capability with the least authoring?"**
  → ECC.
- **"How do I have an agent run on my infrastructure 24/7?"**
  → Hermes.
- **"How do I supervise two or more AI agents working on code with
  real stakes?"**
  → This template.

If the question you're holding isn't on this list, none of the four
is the right answer; author your own substrate.

## See also

- [`cross-vendor-harness.md`](cross-vendor-harness.md) — the topology
  that makes vendor-neutrality real instead of aspirational.
- [`example-pr-walkthrough.md`](example-pr-walkthrough.md) — synthetic
  worked example showing what the gate produces in practice.
