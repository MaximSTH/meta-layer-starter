---
name: model-capabilities
description: Per-model capability + cost reference. Drives the agent's model-selection decisions for tasks where the harness exposes a model selector — direct API calls from product code, SDK model selection in batch jobs, or per-CLI model flags when documented in the vendor-knowledge file. Walked weekly by /refresh-vendor.
status: reference
last-verified: 2026-07-18
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

| Model | Model ID | Best for | Input $/Mtok | Output $/Mtok | Context | Notes |
|---|---|---|---|---|---|---|
| **Fable 5** | `claude-fable-5` | Most capable model — hardest reasoning, long-horizon autonomous agentic runs | $10 | $50 | 1M | **Distinct Claude-5-family model, a tier ABOVE Opus — NOT a fast mode of Opus.** Thinking is always-on (cannot be disabled). Access + burn-rate below. `[VOLATILE]` |
| **Mythos 5** | `claude-mythos-5` | Same tier / capability as Fable 5 | $10 | $50 | 1M | Project Glasswing only; successor to the invitation-only `claude-mythos-preview`. Same pricing + API surface as Fable 5. `[VOLATILE]` |
| **Opus 4.8** | `claude-opus-4-8` | Top of the Opus line — long-horizon planning, complex multi-file refactors, ambiguous judgment calls | $5 | $25 | 1M | Most capable **Opus**; Fable / Mythos sit above it. `/fast`-capable (see note). `[VOLATILE]` |
| **Opus 4.7** | `claude-opus-4-7` | Previous-generation Opus; same use cases as 4.8 | $5 | $25 | 1M | Version-pinned production / reproducibility. `/fast`-capable. `[VOLATILE]` |
| **Sonnet 5** | `claude-sonnet-5` | Default for agentic-coding work; code review at depth; structured output | $3 ($2 intro thru 2026-08-31) | $15 ($10 intro) | 1M | The workhorse; near-Opus quality on coding / agentic. `[VOLATILE]` |
| **Sonnet 4.6** | `claude-sonnet-4-6` | Previous-generation Sonnet | $3 | $15 | 1M | Version-pinned / reproducibility. `[VOLATILE]` |
| **Haiku 4.5** | `claude-haiku-4-5` | Simple text generation, classification, lightweight summarization, high-throughput batch | $1 | $5 | 200K | When the task is bounded and the answer is short. `[VOLATILE]` |

**Fast mode (`/fast`) is NOT a model.** It is a research-preview
output-speed toggle for **Opus 4.8 / 4.7 only** — the *same* Opus model
run at up to ~2.5× output tokens/sec at premium pricing; it does NOT
downgrade to a smaller model, and it has nothing to do with Fable 5
(a separate, more-capable model). API surface: `speed: "fast"` + beta
`fast-mode-2026-02-01` on the beta Messages endpoint. `[VOLATILE]`
(_This corrects a prior entry that conflated Fable 5 with `/fast` — they
are two different things: Fable 5 is a distinct top-tier model; `/fast`
is an Opus output-speed mode._)

**Fable 5 / Mythos 5 access model + burn rate (as of 2026-07-18)
`[VOLATILE]`:** Per the official @claudeai announcement (2026-07-18),
the promotional inclusion window (extended 2026-07-07 → 07-12 → 07-19)
ends **2026-07-19**. **Beginning 2026-07-20:** Fable 5 is included as
standard in **Max** and **Team Premium** plans at **50% of usage
limits**; **Pro** and **Team Standard** remain **usage-credit-based**
($10/$50 per Mtok) with a one-time **$100 credit**. **Elevated burn
rate:** always-on extended thinking (no disable) plus 2×-Opus per-token
pricing make Fable consume plan limits / credits materially faster than
Opus. _Both earlier supervisor-supplied dates ("through July 7" and the
50%-cap framing) were partial views of this rolling transition,
resolved at the gate by primary source per channel ordering._ Source:
[anthropic.com/news/redeploying-fable-5](https://www.anthropic.com/news/redeploying-fable-5)
+ the 2026-07-18 @claudeai announcement. **Re-cite next walk:**
`support.claude.com` (Max plan / usage-credits articles) and
[claude.com/pricing](https://claude.com/pricing) did NOT yet reflect
the 07-20 arrangement at walk time — swap in the stabler support/pricing
URL once they catch up.

**Tool use, vision, computer-use, prompt caching, extended thinking** —
all supported across Fable / Opus / Sonnet / Haiku unless explicitly
noted in the vendor docs. Verify on next `/refresh-vendor` walk.

**Source:** [platform.claude.com/docs/en/about-claude/models/overview.md](https://platform.claude.com/docs/en/about-claude/models/overview.md)
(model IDs / pricing cross-checked against the `claude-api` skill model
table, cached 2026-06-24)

## OpenAI — model selection

| Model | Best for | Cost tier | Notes |
|---|---|---|---|
| **Codex** | Agentic-coding via CLI (`codex exec`); structured output | medium | The CLI binary is what we call into via `cross-vendor-review.sh`. Runs the GPT-5.x family under the hood. `[VOLATILE]` |
| **GPT-5.6** (Sol / Terra / Luna) | Current top OpenAI generation — direct API calls from product code (non-Codex usage) | varies | Newest family as of this walk (surfaced in the 2026-07-18 codex-cli walk); GPT-5.3-Codex-Spark is a research-preview variant. `[VOLATILE]` |
| **GPT-5.5 / GPT-5.4 / GPT-5.4-mini** | Prior-generation direct API usage | varies | Still selectable; check vendor pricing page. `[VOLATILE]` |

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
  `claude-sonnet-5` rather than `claude-sonnet-latest`). Versioned
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
