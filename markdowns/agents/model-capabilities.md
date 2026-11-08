---
name: model-capabilities
description: Per-model capability + cost reference. Drives the agent's model-selection decisions for tasks where the harness exposes a model selector — direct API calls from product code, SDK model selection in batch jobs, or per-CLI model flags when documented in the vendor-knowledge file. Walked weekly by /refresh-vendor.
status: reference
last-verified: 2026-11-08
google-rates-last-verified: 2026-11-08  # component clock — rates fetched from aistudio.google.com/docs/pricing 2026-11-08
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
| **Fable 5.1** | `claude-fable-5-1` | Most capable model — hardest reasoning, long-horizon autonomous agentic runs | $10 | $50 | 1M | **Distinct Claude-5-family model, a tier ABOVE Opus — NOT a fast mode of Opus.** Cache reads $0.25 (0.025× base). Default Fable in Claude Code since v2.1.257 (needs ≥2.1.255). Access + burn-rate below. `[VOLATILE]` |
| **Mythos 5.1** | `claude-mythos-5-1` | Same tier / capability as Fable 5.1 | $10 | $50 | 1M | Limited availability ([support 14604842](https://support.claude.com/en/articles/14604842)). Same pricing as Fable 5.1. `[VOLATILE]` |
| **Opus 5.5** | `claude-opus-5-5` | Complex agentic coding + enterprise work; **default model on every first-party Claude Code plan** (v2.1.280+) | $4 | $20 | 1M | Top of the Opus line; Fable sits above it. 128K max output. Cache reads $0.20 (0.05× base). `/fast`-capable — ⚠️ fast mode bills at **$8/$40**. `[VOLATILE]` |
| **Sonnet 5.5** | `claude-sonnet-5-5` | Default for agentic-coding work; code review at depth; structured output | $2 | $10 | 1M | The workhorse. Default `sonnet` alias in Claude Code since v2.1.284 (so `--model sonnet` resolves here). 128K max output. Cache reads $0.10. `[VOLATILE]` |
| **Haiku 5.5** | `claude-haiku-5-5` | Classification, extraction, summarization, high-throughput batch, search fan-out | $0.10 (≤100K prompt) · $0.50 (>100K) | $0.50 · $2.50 | 1M | Prompt-length-tiered pricing — long prompts cost 5×. Default `haiku` alias since v2.1.293. Context 1M (Haiku 4.5 was 200K). `[VOLATILE]` |
| **Legacy (still available)** | `claude-fable-5`, `claude-opus-5`, `claude-opus-4-8`, `claude-opus-4-7`, `claude-sonnet-5`, `claude-sonnet-4-6`, `claude-haiku-4-5` | Version-pinned reproducibility | Fable 5 $10 · Opus 5/4.8/4.7 $5 · Sonnet 5 $2 · Sonnet 4.6 $3 · Haiku 4.5 $1 | Fable 5 $50 · Opus $25 · Sonnet 5 $10 · Sonnet 4.6 $15 · Haiku 4.5 $5 | 1M (Haiku 4.5: 200K) | Per the models overview "Legacy models" list (2026-11-08). Mythos 5 still priced ($10/$50, limited availability). `[VOLATILE]` |

**Fast mode (`/fast`) is NOT a model.** It is an output-speed toggle for
**Opus 5.5** (GA) and **Opus 5 / Opus 4.8** (research preview) — the
*same* Opus model run at premium pricing ($8/$40 on Opus 5.5; $10/$50 on
Opus 5 / 4.8); it does NOT downgrade to a smaller model, and it has
nothing to do with Fable (a separate, more-capable model). Opus 4.8
fast mode was deprecated 2026-10-30 and is removed 2026-11-30 — after
removal, fast requests on Opus 4.8 **error** rather than fall back
(Claude Code CHANGELOG). API surface:
[platform.claude.com fast-mode](https://platform.claude.com/docs/en/build-with-claude/fast-mode). `[VOLATILE]`

**Fable access model + burn rate (as of 2026-11-08) `[VOLATILE]`:**
Per [support.claude.com/15424964](https://support.claude.com/en/articles/15424964):
on **Max**, **Ultra** and **Team Premium**, Fable 5 and Fable 5.1 are
included — up to **50% of weekly usage limits** at no extra cost, drawn
from the plan's regular weekly limits and consumed faster than other
models; past the Fable limit, continue on usage credits or switch
model. On **Pro** and **Team Standard**, Fable is usage-credit-only.
The one-time July 2026 credit applied to the Fable 5 change only —
**no equivalent credit for Fable 5.1**. (Supersedes the 2026-07-18
entry cited to the @claudeai announcement; the support article is now
the stable source.)

**Tool use, vision, computer-use, prompt caching, extended thinking** —
all supported across Fable / Opus / Sonnet / Haiku unless explicitly
noted in the vendor docs.

**Source:** [platform.claude.com/docs/en/about-claude/models/overview.md](https://platform.claude.com/docs/en/about-claude/models/overview.md)
+ [platform.claude.com/docs/en/about-claude/pricing.md](https://platform.claude.com/docs/en/about-claude/pricing.md)
(both fetched 2026-11-08; Claude Code default-model versions from the
upstream CHANGELOG)

## OpenAI — model selection

| Model | Best for | Cost tier | Notes |
|---|---|---|---|
| **Codex** | Agentic-coding via CLI (`codex exec`); structured output | per model | The CLI binary is what we call into via `cross-vendor-review.sh`. Runs the GPT-6.x family; bundled default with no config is `gpt-6.1-sol` (codex 0.162.1 catalog + exec banner). Reasoning efforts `low…max` plus new `ultra` (not on Luna). The dispatcher pins the reviewer model by tier (`--tier`, default workhorse = `gpt-6.1-sol`; 2026-11-08) rather than inheriting the operator's global model — see [`codex-cli.md`](vendor-knowledge/codex-cli.md) §9. `[VOLATILE]` |
| **GPT-6 Astra** (`gpt-6-astra`) | OpenAI frontier tier | $10 / $50 | Catalog label "Frontier intelligence". `[VOLATILE]` |
| **GPT-6.1 Sol** (`gpt-6.1-sol`) | OpenAI workhorse | $2 / $10 | Catalog label "Latest workhorse"; Codex default. `[VOLATILE]` |
| **GPT-6.1 Terra** (`gpt-6.1-terra`) | Cheaper workhorse-class model | $1 / $5 | Listed (visibility `list`, priority 3) in the **live** Codex model catalog the 0.162.1 CLI reads from `~/.codex/models_cache.json` (server-refreshed 2026-11-08 by a 0.164.0 client) — absent only from the *bundled* offline catalog of an unconfigured `CODEX_HOME`. Catalog gives it no role label ("GPT-6.1 Terra Codex model"). `[VOLATILE]` |
| **GPT-6 Luna** (`gpt-6-luna`) | OpenAI light tier | $0.10 / $0.50 | Catalog label "Fast and affordable". `[VOLATILE]` |
| **GPT-6 Sol** (`gpt-6-sol`) | Prior workhorse | $2 / $10 | Still in the Codex catalog. `[VOLATILE]` |
| **GPT-5.6 Sol / Terra / Luna** | Prior generation ("Older" in the Codex catalog) | $4/$20 · $2/$12 · $0.20/$1.20 | GPT-5.6 Sol API promo: "available until November 30, 2026" (API pricing page). The Codex-plan promo date is a separate surface — see [`codex-cli.md`](vendor-knowledge/codex-cli.md) §6. `[VOLATILE]` |
| **GPT-5.5 / 5.4 family** | Legacy / API-only | 5.5 $5/$30 · 5.4 $2.50/$15 · 5.4-Mini $0.75/$4.50 · 5.4-Nano $0.20/$1.25 | GPT-5.5 retired from Codex ChatGPT sign-in 2026-10-14 (catalogued "Legacy"); 5.4 / 5.4-Mini absent from the Codex catalog. `[VOLATILE]` |

**Source:** [developers.openai.com/api/docs/pricing](https://developers.openai.com/api/docs/pricing)
(fetched 2026-11-08; standard short-context tier) + `codex debug models`
bundled catalog at codex 0.162.1.

## Google — model selection

| Model | Best for | Cost tier | Notes |
|---|---|---|---|
| **Antigravity (`agy`)** | Agentic-coding via CLI; cross-vendor review peer | varies | Google's coding CLI. Headless via `agy --print`. Review dispatch re-enabled 2026-11-08 after the write-refusal probe passed on 1.5.3 and denial detection moved to the JSON `denied_actions` field; dispatch uses `gemini-3.8-flash-high` (workhorse) or `-low` (light), with no frontier mapping ([`antigravity-cli.md`](vendor-knowledge/antigravity-cli.md) §9). `[VOLATILE]` |
| **Gemini 4 Argon** (`gemini-4-argon`) | Google frontier tier | $2 / $10 → **$4 / $20 from 2026-12-01** | API flagship; not on the Free tier. Not listed by `agy models` on the reference account. `[VOLATILE]` |
| **Gemini 3.8 Flash** (`gemini-3.8-flash-{high,medium,low}` in agy) | Workhorse→light band; effort baked into the agy model ID | $0.75 / $3.75 → **$1.50 / $7.50 from 2027-01-01** | `agy models` 1.5.3 (2026-11-08) — replaces 3.7 / 3.6 / 3.5 Flash. `[VOLATILE]` |
| **Gemini 3.1 Pro** | Prior frontier | $2 / $12 (≤200K prompt) | API-priced; no longer listed by `agy models` on the reference account. `[VOLATILE]` |
| **Brokered non-Google** (`claude-sonnet-4-6`, `claude-opus-4-6-thinking`, `gpt-oss-120b-medium`) | Cross-vendor access through one CLI | n/a | Antigravity serves peer-vendor models — CLI choice ≠ model family. Catalog is **server-side and account-dependent** (agy 1.3.6: Claude models appear only if the Google Cloud project can use them). `[VOLATILE]` |

**Source:** [aistudio.google.com/docs/pricing](https://aistudio.google.com/docs/pricing)
(`ai.google.dev/pricing` 301-redirects there; fetched 2026-11-08) +
`agy models` at agy 1.5.3.

## Vendor-neutral capability tiers (restructured 2026-08-25)

Task heuristics name a **tier**, never a vendor's model. The per-vendor
mapping below resolves each tier to a concrete pick. One heuristics
table governs all harness vendors; adding a vendor adds a mapping row,
not a rewrite. (Replaces the Claude-shaped table this file carried
until 2026-08-25; a Grok column waits on the
[deferred admission](grok-admission-analysis.md).)

**Verification note (2026-11-08):** Anthropic rows re-verified against
the platform models overview + pricing page; OpenAI against the API
pricing page and the codex 0.162.1 bundled catalog; Google inventory
against `agy models` (1.5.3) and rates against the AI Studio pricing
page (all by fetch or execution). The `google-rates-last-verified`
component clock is kept and now matches the file-level date; it exists
so a future inventory-only walk cannot silently refresh Google rates.

| Tier | Meaning |
|---|---|
| **frontier** | Hardest reasoning, long-horizon judgment, ambiguity. Expensive; use deliberately. |
| **workhorse** | Coding, review-at-depth, synthesis, structured output. The default. |
| **light** | Search, retrieval, fan-out, classification, extraction, summarization. Cheap, fast, high-volume. |

### Per-vendor tier mapping

| Tier | Claude (API/Code) | OpenAI (via Codex / API) | Google (via `agy`) |
|---|---|---|---|
| frontier | Fable 5.1 · Opus 5.5 | GPT-6 Astra (`gpt-6-astra`) | Gemini 4 Argon (API); not exposed by `agy models` on the reference account — subagent tier alias `pro` |
| workhorse | Sonnet 5.5 | GPT-6.1 Sol (`gpt-6.1-sol`) | `gemini-3.8-flash-high` / `-medium` |
| light | Haiku 5.5 · Sonnet 5.5 at low effort | GPT-6 Luna (`gpt-6-luna`) | `gemini-3.8-flash-low` — subagent tier alias `flash` |

Prices deliberately NOT restated here — the per-vendor model tables
above are the SSOT for rates (per the AGENTS.md "SSOT for shared
values" rule); this mapping names models only.

Mapping notes: OpenAI column resolves against the live Codex model
catalog (`codex debug models` with the operator's `CODEX_HOME`,
2026-11-08). The workhorse cell is GPT-6.1 Sol because the catalog
itself labels it "Latest workhorse model for coding and everyday work"
(priority 1). GPT-6.1 Terra is half Sol's price and also listed, but
carries no role label; whether it is review-grade is unassessed — a
supervisor decision, not a catalog fact. Google
column: `agy models` (agy 1.5.3) is **account-dependent and
server-side** — the reference account lists only Gemini 3.8 Flash plus
brokered models, so the frontier cell names the API model and the agy
subagent tier aliases (`inherit` / `flash` / `pro`) instead of an agy
model ID. On the model ID, effort is still baked in
(`-high|-medium|-low`), but agy also has a separate `--effort` flag
(since 1.1.5). Antigravity **brokers non-Google models**, so "which
vendor CLI" and "which model family" are independent axes there.

## Model selection heuristics

When the harness lets you pick, use these defaults rather than
defaulting to the most expensive available model:

| Task shape | Tier |
|---|---|
| **Search / retrieval / fan-out (file search, web search, broad sweeps)** | **light** — and pin it in the agent definition, don't rely on the operator remembering. Claude's current pin is Sonnet @ `effort: medium` — by this table's definitions a **workhorse** pin, deliberately one notch above the light default per explicit supervisor directive ("use Sonnet for websearch subagents", 2026-08-25). Strict light (Haiku, or Sonnet @ low) is a two-line frontmatter edit in [`.claude/agents/`](../../.claude/agents/) if search spend warrants it. Verification canonical in [`claude-code.md`](vendor-knowledge/claude-code.md) §3. |
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

**Enforcement status by vendor (2026-11-08):** Claude — **pinned at
workhorse (Sonnet @ medium), a supervisor-directed notch above the
light default**, via `model:` frontmatter in
[`.claude/agents/`](../../.claude/agents/). ⚠️ That pin is a
**default, not enforcement**: a per-invocation `model` on the Agent
tool call overrides it; the only hard enforcement is
`CLAUDE_CODE_SUBAGENT_MODEL_FORCE` (2.1.257), an operator env var the
template cannot ship. Canonical record in
[`claude-code.md`](vendor-knowledge/claude-code.md) §3. Codex — NOT
enforced: `agents.default_subagent_model` (global) and per-agent
`model` are now **schema-confirmed by execution** at 0.162.1, but
honoring at spawn is unverified and the last headless delegation test
did not spawn ([`codex-cli.md`](vendor-knowledge/codex-cli.md) §3).
Antigravity — NOT enforced: subagent `model` is now documented
(tiers `inherit` / `flash` / `pro`, agent files in `.agents/agents/`)
but untested behaviorally
([`antigravity-cli.md`](vendor-knowledge/antigravity-cli.md) §3).

## When this file is stale

`last-verified` more than 60 days old = `/refresh-vendor model-capabilities`
walks every claim against the vendor pricing pages. Pricing tier
moves are the most common drift. Verify against the live vendor
billing dashboard, not just the docs site, before any cost-sensitive
decision.

## Adapt for your project

- Pin specific model versions for production reproducibility (e.g.,
  `claude-sonnet-5-5` rather than `claude-sonnet-latest`). Versioned
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
