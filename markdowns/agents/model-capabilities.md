---
name: model-capabilities
description: Per-model capability + cost reference. Drives the agent's model-selection decisions for tasks where the harness exposes a model selector — direct API calls from product code, SDK model selection in batch jobs, or per-CLI model flags when documented in the vendor-knowledge file. Walked weekly by /refresh-vendor.
status: reference
last-verified: 2026-08-25
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
| **Opus 5** | `claude-opus-5` | Complex agentic coding + enterprise work; **current default Opus** in Claude Code (v2.1.219+) | $5 | $25 | 1M | Top of the Opus line. Fable sits above it. 128K max output; adaptive thinking; default effort `high`; knowledge cutoff May 2026. `/fast`-capable — ⚠️ fast mode bills at **$10/$50**, not the $5/$25 base. `[VOLATILE]` |
| **Opus 4.8** | `claude-opus-4-8` | Prior-generation Opus | $5 | $25 | 1M | **Legacy (still available).** `/fast`-capable. `[VOLATILE]` |
| **Opus 4.7** | `claude-opus-4-7` | Prior-generation Opus | $5 | $25 | 1M | **Legacy (still available).** Version-pinned reproducibility. **No longer `/fast`-capable** (removed v2.1.219). `[VOLATILE]` |
| **Sonnet 5** | `claude-sonnet-5` | Default for agentic-coding work; code review at depth; structured output | $2 | $10 | 1M | The workhorse; near-Opus quality on coding / agentic. $2/$10 is now the **standard list price**, not an intro rate (corrected 2026-08-25). 128K max output. `[VOLATILE]` |
| **Sonnet 4.6** | `claude-sonnet-4-6` | Prior-generation Sonnet | $3 | $15 | 1M | **Legacy (still available).** Version-pinned / reproducibility. `[VOLATILE]` |
| **Haiku 4.5** | `claude-haiku-4-5` | Simple text generation, classification, lightweight summarization, high-throughput batch | $1 | $5 | 200K | When the task is bounded and the answer is short. `[VOLATILE]` |

**Fast mode (`/fast`) is NOT a model.** It is a research-preview
output-speed toggle for **Opus 5 / Opus 4.8** (4.7 removed v2.1.219) —
the *same* Opus model
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
| **GPT-5.6 Sol** | Top OpenAI tier | $4 in / $20 out ($8/$30 long-ctx) | Also on Bedrock with first-class `max` reasoning effort (codex 0.144.5 walk). `[VOLATILE]` |
| **GPT-5.6 Terra** | OpenAI workhorse | $2 / $12 ($4/$18 long-ctx) | `[VOLATILE]` |
| **GPT-5.6 Luna** | OpenAI light tier | $0.20 / $1.20 ($0.40/$1.80 long-ctx) | `[VOLATILE]` |
| **GPT-5.5 / 5.4 / 5.4-Mini / 5.4-Nano** | Prior-generation | $5/$30 · $2.50/$15 · $0.75/$4.50 · $0.20/$1.25 | 272K ctx on 5.5/5.4; Pro variants $30/$180. GPT-5.3-Codex-Spark research preview. `[VOLATILE]` |

**Source:** [developers.openai.com/api/docs/pricing](https://developers.openai.com/api/docs/pricing)
(platform.openai.com/docs/pricing 301-redirects there; verified by fetch 2026-08-25)

## Google — model selection

| Model | Best for | Cost tier | Notes |
|---|---|---|---|
| **Antigravity (`agy`)** | Agentic-coding via CLI; cross-vendor review peer | varies | Google's coding CLI. Headless via `agy --print` — ⚠️ review dispatch hard-blocked pending probe re-run ([`antigravity-cli.md`](vendor-knowledge/antigravity-cli.md) §9). `[VOLATILE]` |
| **Gemini 3.7 / 3.6 / 3.5 Flash** (`gemini-3.x-flash-{high,medium,low}`) | Workhorse→light band; effort baked into the model ID | rates not re-verified | `agy models`, binary 1.1.19, 2026-08-25. `[VOLATILE]` |
| **Gemini 3.1 Pro** (`gemini-3.1-pro-{high,low}`) | Google frontier tier | rates not re-verified | Same channel. `[VOLATILE]` |
| **Brokered non-Google** (`claude-sonnet-4-6`, `claude-opus-4-6-thinking`, `gpt-oss-120b-medium`) | Cross-vendor access through one CLI | n/a | Antigravity serves peer-vendor models — CLI choice ≠ model family. `[VOLATILE]` |

**Source:** [ai.google.dev/pricing](https://ai.google.dev/pricing)

## Vendor-neutral capability tiers (restructured 2026-08-25)

Task heuristics name a **tier**, never a vendor's model. The per-vendor
mapping below resolves each tier to a concrete pick. One heuristics
table governs all harness vendors; adding a vendor adds a mapping row,
not a rewrite. (Replaces the Claude-shaped table this file carried
until 2026-08-25; a Grok column waits on the
[deferred admission](grok-admission-analysis.md).)

**Verification note (2026-08-25):** Anthropic rows re-verified against
the platform models overview; OpenAI against the pricing page (by
fetch); Google model *inventory* against the `agy models` binary
channel. Google per-Mtok *rates* were NOT re-verified and stay flagged
inline — the earlier partial-verification hold on `last-verified` is
lifted by this full pass.

| Tier | Meaning |
|---|---|
| **frontier** | Hardest reasoning, long-horizon judgment, ambiguity. Expensive; use deliberately. |
| **workhorse** | Coding, review-at-depth, synthesis, structured output. The default. |
| **light** | Search, retrieval, fan-out, classification, extraction, summarization. Cheap, fast, high-volume. |

### Per-vendor tier mapping

| Tier | Claude (API/Code) | OpenAI (via Codex / API) | Google (via `agy`) |
|---|---|---|---|
| frontier | Fable 5 ($10/$50) · Opus 5 ($5/$25) | GPT-5.6 Sol ($4/$20) | `gemini-3.1-pro-high` |
| workhorse | Sonnet 5 ($2/$10) | GPT-5.6 Terra ($2/$12) | `gemini-3.7-flash-high` / `-medium` |
| light | Haiku 4.5 ($1/$5) · Sonnet 5 at low effort | GPT-5.6 Luna ($0.20/$1.20) · GPT-5.4-Mini ($0.75/$4.50) | `gemini-3.7-flash-low` |

Mapping notes: OpenAI rates are short-context standard tier from
[developers.openai.com/api/docs/pricing](https://developers.openai.com/api/docs/pricing)
(long-context roughly doubles input). Google column: `agy models`
(binary channel, agy 1.1.19) — **effort is baked into the model ID**
(`-high|-medium|-low` suffixes), and Antigravity also **brokers
non-Google models** (`claude-sonnet-4-6`, `claude-opus-4-6-thinking`,
`gpt-oss-120b-medium`), so "which vendor CLI" and "which model family"
are independent axes there. Google per-Mtok rates: `[VOLATILE]`, see
[ai.google.dev/pricing](https://ai.google.dev/pricing).

## Model selection heuristics

When the harness lets you pick, use these defaults rather than
defaulting to the most expensive available model:

| Task shape | Tier |
|---|---|
| **Search / retrieval / fan-out (file search, web search, broad sweeps)** | **light** — and pin it in the agent definition, don't rely on the operator remembering. Claude enforcement: [`.claude/agents/`](../../.claude/agents/) (Explore + web-research, Sonnet-pinned; verification canonical in [`claude-code.md`](vendor-knowledge/claude-code.md) §3) |
| Code review on a Tier 1 / Tier 2 PR | workhorse (depth) |
| Code review on a Tier 3 PR | light (speed) |
| Long-horizon plan authoring | frontier (judgment) |
| Routine implementation from a clear plan | workhorse |
| High-volume classification / extraction / summarization | light (cost) |
| Vision tasks (image content extraction) | workhorse or higher (per docs) |
| Ambiguous "I don't know what this means" | frontier (judgment) |

**Escalation rule:** if a light-tier call produces output that doesn't
pass the consumer's quality bar, retry once at workhorse before
escalating to human. Don't escalate to frontier directly unless the
failure mode suggests judgment ambiguity (not capability ambiguity).

**Enforcement status by vendor (2026-08-25):** Claude — enforced
(pinned agent files; canonical record in
[`claude-code.md`](vendor-knowledge/claude-code.md) §3). Codex — NOT
enforced: per-agent `model` is docs-only and headless delegation did
not spawn even on explicit request
([`codex-cli.md`](vendor-knowledge/codex-cli.md) §3); exposure low
(explicit-request-only delegation). Antigravity — NOT enforced:
`model`/`inherit` changelog-indicated only, agent-definition location
undocumented, dispatch hard-blocked pending probe re-run
([`antigravity-cli.md`](vendor-knowledge/antigravity-cli.md) §9).

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
