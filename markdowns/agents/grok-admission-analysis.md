---
name: grok-admission-analysis
description: Vendor-admission decision memo for xAI Grok Build — harness-fit criteria, verified findings, risk register, recommendation (DEFER with re-evaluation triggers). Supervisor decides.
status: draft
---

# Grok admission analysis (2026-08-25)

Decision requested: admit xAI's **Grok Build** as a fourth harness
vendor, defer pending maturity, or reject. Research by a Sonnet-pinned
web-research pass (36 tool calls, primary-source-first); harness-fit
analysis and recommendation by the session worker. Analysis follows the
Antigravity admission template — the worked example of what a vendor
proves before the harness trusts it, and a warning: even with that
process, Antigravity's safety probe went stale within six weeks.

## What Grok Build is (verified against primary sources)

Official xAI agentic coding CLI. Binary `grok`; TUI + headless + ACP
(JSON-RPC) modes. Source-available at `github.com/xai-org/grok-build`
(Apache 2.0, 26k stars) but **"External contributions are not
accepted"** — published code, not community governance. Install is
`curl -fsSL https://x.ai/cli/install.sh | bash` (per docs.x.ai —
quoted, not executed; nothing was installed for this memo).
Distinguish from `superagent-ai/grok-cli` and other community tools
carrying similar names — explicitly unaffiliated.

## Findings vs admission criteria

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | Reads `AGENTS.md` natively | ✅ **PASS — best-in-harness** | docs.x.ai project-rules page, quoted: reads `AGENTS.md`, `AGENT.md`, `CLAUDE.md`, `CLAUDE.local.md`, plus `.grok/rules/`, `.claude/rules/`, `.cursor/rules/`. No mirror hook needed — Grok would be the only vendor beside Codex to consume the canonical file directly, and it reads the CLAUDE.md mirror too. |
| 2 | Headless with verifiable exit codes | ⚠️ **PARTIAL** | `-p/--single`, `--output-format json \| streaming-json`, `--no-auto-update` for CI — all primary-sourced. **Exit-code semantics: not found on any official page**; only a secondary-source paraphrase. Fails the verified-by-execution bar until installed and probed. |
| 3 | Read-only reviewability mechanism | ⚠️ **PLAUSIBLE, UNPROVEN** | Permission modes (Ask/Auto/Always-approve), `--allow`/`--deny` rules with **deny-wins-over-allow** even under always-approve, `--sandbox <PROFILE>`, and a built-in read-only `explore` agent type. The *shape* is right — arguably richer than Antigravity's. But sandbox implementation is undocumented (enterprise pages 403/404'd) and nothing was executed. |
| 4 | Write-refusal probe on installed version | ❌ **NOT RUN** | Requires installing via `curl \| bash` — a supervised decision, not one this memo takes unilaterally. |
| 5 | Agent Skills standard | ⚠️ **SIMILAR SHAPE, UNDECLARED** | `SKILL.md` + YAML frontmatter under `.grok/skills/`; "extra keys are ignored." No agentskills.io compliance claim; does **not** scan `.agents/skills/` — though "custom paths in config" might point there (untested). |
| 6 | Model discipline (per-agent pinning) | ✅ **PASS (docs)** | `[subagents.models]` in `config.toml` (quoted: `explore = "grok-build"`), `-m/--model` and `--effort` per invocation. Subagent nesting is **explicitly depth 1** — bounded fan-out by design. Delegation exposure profile closer to Codex than Claude. |
| 7 | Maturity floor: changelog + pinnable version | ❌ **FAIL** | `x.ai/build/changelog` → 404. GitHub Releases → **zero entries** ("There aren't any releases here"), despite a reported v1.0 on 2026-08-07 (secondary source only). No official channel exists from which a version floor can be pinned or a weekly walk can diff releases. The refresh-vendor protocol cannot operate on this vendor today. |

## Risk register

| Risk | Severity | Note |
|---|---|---|
| **No verifiable release channel** | **Blocking** | The harness's whole safety model (version floors, probe-version gates, weekly walks) assumes a diffable changelog. Antigravity's probe went stale *with* a changelog; Grok offers no way to even detect staleness. |
| Safety chain unproven | Blocking until probed | Criteria 2–4. Same posture as Antigravity pre-admission — resolvable by a supervised install + probe session, ~1–2 hours. |
| Product age | High | ~3 months from beta; v1.0 (if the date is right) under 3 weeks old. Interface churn near-certain. |
| Secondary-source load-bearing claims | Medium | Subscription mapping (x.ai/api 403'd), v1.0 date, default-model identity (docs say `grok-build`, a secondary source says `grok-4.6` — unresolved conflict). |
| Branding anomaly | Low, flag only | Official pages consistently render the publisher as "SpaceXAI". Consistent across independently fetched official pages; corporate-structure story unverified. Sanity-check before quoting externally. |
| Install is `curl \| bash` | Medium | Standard for the category but unpinned and unverifiable ahead of time; combined with no releases, there is no way to install a *known* version. |

## What admission would buy (for balance)

Native AGENTS.md consumption (no sync hook), a third independent
reviewer lineage (breaks any Claude↔Codex blind-spot correlation),
cheap models (`grok-build-0.1` at $1/$2 per Mtok under 200k), and
per-agent model pinning that fits the guardrail pattern directly.

## Recommendation

**DEFER — do not admit now, do not reject.** The paper fit is the best
of any candidate vendor (criterion 1 alone removes a whole class of
sync machinery), but criterion 7 fails closed and is not ours to fix:
without an official changelog or a single tagged release, the harness
cannot pin a floor, cannot detect drift, and cannot run the weekly walk
that keeps every other vendor honest. Admitting now would create a
vendor file that rots invisibly — the exact failure mode the
refresh-vendor protocol exists to prevent, demonstrated six weeks ago
by a vendor with *better* release hygiene than this.

**Re-evaluation triggers (any one reopens the analysis):**
1. An official changelog URL resolves, or `xai-org/grok-build` gains
   tagged releases.
2. 60 days elapse with the CLI surface stable (spot-check the docs).
3. A supervised install + write-refusal probe session is explicitly
   authorized despite the above (supervisor's prerogative — the memo
   only advises).

**If admitted later**, the entry plan is: supervised install → capture
`grok --help` verbatim → write-refusal probe with recorded version →
author `vendor-knowledge/grok.md` with a verification-boundary block →
dispatcher branch behind the same probe-version gate Antigravity now
has → fold models into `model-capabilities.md`.

## Sources

Primary: docs.x.ai (build/overview, cli/reference, cli/headless-scripting,
features/project-rules, features/skills-plugins-marketplaces,
features/subagents, features/permissions, settings, developers/pricing),
github.com/xai-org/grok-build (+releases page). Secondary (labelled
low-confidence where load-bearing): cryptobriefing.com v1.0 date,
search-synthesized subscription mapping. Full research transcript:
session 2026-08-25, Sonnet web-research pass.
