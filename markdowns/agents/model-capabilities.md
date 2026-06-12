---
name: model-capabilities
description: Per-model capability + cost reference. Drives the agent's model-selection decisions for tasks where the harness exposes a model selector — direct API calls from product code, SDK model selection in batch jobs, or per-CLI model flags when documented in the vendor-knowledge file. Walked weekly by /refresh-vendor.
status: reference
last-verified: 2026-06-10
---

# Model capabilities

This file is the per-model selection cheat-sheet. The agent reads it
when deciding which model to invoke for a task — direct API calls
from product code, `/model` overrides inside an agent harness, or
SDK model selection in batch jobs. Distinct from the per-CLI vendor
knowledge files: those cover the harness around the model; this
covers the model itself.

Walked weekly by [`refresh-vendor.md`](../protocols/refresh-vendor.md);
model pricing and availability drift faster than CLI flag tables.

**Verify against vendor pricing pages before any cost-sensitive
decision.** Numbers in markdown go stale; vendor billing dashboards
don't.

## Anthropic Claude — model selection

| Model | Best for | Input $/Mtok | Output $/Mtok | Context | Notes |
|---|---|---|---|---|---|
| **Opus 4.8** | Newest top-tier; long-horizon planning, complex multi-file refactors, ambiguous judgment calls | high | high | 200K | Latest Opus generation. Reach for when the task can't be decomposed. `[VOLATILE]` |
| **Opus 4.7** | Previous-generation top-tier; same use cases as 4.8 | high | high | 200K | Kept available for reproducibility / version-pinned production. `[VOLATILE]` |
| **Sonnet 4.6** | Default for agentic-coding work; code review at depth; structured output | medium | medium | 200K | The workhorse. `[VOLATILE]` |
| **Haiku 4.5** | Simple text generation, classification, lightweight summarization, high-throughput batch | low | low | 200K | When the task is bounded and the answer is short. `[VOLATILE]` |
| **Fable 5** | Faster Claude Code main-loop responses on supported tiers (Opus 4.8 / 4.7 / 4.6); does not downgrade to a smaller model | matches base | matches base | 200K | A faster-output mode of the Opus line, not a separate cheaper model. Toggled with `/fast` in Claude Code. `[VOLATILE]` |

**Tool use, vision, computer-use, prompt caching, extended thinking** —
all supported across Opus / Sonnet / Haiku unless explicitly noted in
the vendor docs. Verify on next `/refresh-vendor` walk.

**Source:** [docs.anthropic.com/en/docs/about-claude/models](https://docs.anthropic.com/en/docs/about-claude/models)

## OpenAI — model selection

| Model | Best for | Cost tier | Notes |
|---|---|---|---|
| **Codex** | Agentic-coding via CLI (`codex exec`); structured output | medium | The CLI binary is what we call into via `cross-vendor-review.sh`. `[VOLATILE]` |
| **GPT-5 family** | Direct API calls from product code (non-Codex usage) | varies | Check vendor pricing page. `[VOLATILE]` |

**Source:** [platform.openai.com/docs/pricing](https://platform.openai.com/docs/pricing)

## Google — model selection

| Model | Best for | Cost tier | Notes |
|---|---|---|---|
| **Antigravity (`agy`)** | Agentic-coding via CLI; cross-vendor review peer | varies | Google's coding CLI. Headless via `agy --print`. `[VOLATILE]` |

**Source:** [ai.google.dev/pricing](https://ai.google.dev/pricing)

## Model selection heuristics

When the harness lets you pick, use these defaults rather than
defaulting to the most expensive available model:

| Task shape | Default model |
|---|---|
| Code review on a Tier 1 / Tier 2 PR | Sonnet-tier (depth) |
| Code review on a Tier 3 PR | Haiku-tier (speed) |
| Long-horizon plan authoring | Opus-tier (judgment) |
| Routine implementation from a clear plan | Sonnet-tier |
| High-volume classification / extraction / summarization | Haiku-tier (cost) |
| Vision tasks (image content extraction) | Sonnet-tier or higher (per docs) |
| Ambiguous "I don't know what this means" | Opus-tier (judgment) |

**Escalation rule:** if a Haiku-tier call produces output that doesn't
pass the consumer's quality bar, retry once at Sonnet-tier before
escalating to human. Don't escalate to Opus-tier directly unless the
failure mode suggests judgment ambiguity (not capability ambiguity).

## When this file is stale

`last-verified` more than 60 days old = `/refresh-vendor model-capabilities`
walks every claim against the vendor pricing pages. Pricing tier
moves are the most common drift. Verify against the live vendor
billing dashboard, not just the docs site, before any cost-sensitive
decision.

## Adapt for your project

- Pin specific model versions for production reproducibility (e.g.,
  `claude-sonnet-4-6` rather than `claude-sonnet-latest`). Versioned
  pinning prevents silent capability shifts mid-quarter.
- Add per-project escalation rules to the heuristics table — your
  specific tasks may need different defaults.
- For high-volume API usage, add a per-task cost budget alongside the
  model choice ("classify support tickets at Haiku, max $200/month").
- Track per-model failure rates in your own observability so the
  next refresh-vendor walk has data to update the heuristics with.

## See also

- [`vendor-knowledge/claude-code.md`](vendor-knowledge/claude-code.md) —
  the CLI harness around Anthropic's models.
- [`vendor-knowledge/codex-cli.md`](vendor-knowledge/codex-cli.md) —
  the CLI harness around OpenAI's coding model.
- [`vendor-knowledge/antigravity-cli.md`](vendor-knowledge/antigravity-cli.md) —
  the CLI harness around Google's coding CLI.
- [`refresh-vendor.md`](../protocols/refresh-vendor.md) — the refresh
  cadence + channel reliability ordering.
