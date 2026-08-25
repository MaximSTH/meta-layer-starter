---
name: vendor-knowledge-codex-cli
description: Volatility-tagged knowledge of Codex CLI — canonical file (AGENTS.md native), skills, subagents, hooks, auth, rate limits, cost, MCP, headless. Drives cross-vendor scripts and /refresh-vendor.
status: reference
last-verified: 2026-08-25
---

# Codex CLI — vendor knowledge

Single file. One vendor. Every claim carries a `[STABLE]` / `[MEDIUM]` /
`[VOLATILE]` tag and a URL citation. Walked weekly by [`refresh-vendor.md`](../../protocols/refresh-vendor.md); change-marker semantics (no edit on no-op). Linked from the README at [`markdowns/agents/README.md`](../README.md).

**Install:** `npm install -g @openai/codex` —
see [`learn.chatgpt.com/docs/codex/cli`](https://learn.chatgpt.com/docs/codex/cli)
for platform-specific instructions and authentication setup. (Package
name verified via `npm view @openai/codex` → **0.144.5 latest, 2026-07-18**
(local binary introspected at 0.139.0; 0.140–0.144.5 drift walked via
GitHub release notes); the binary it installs is `codex`, not
`codex-cli`.)

**Docs host migration (2026-07-18):** the docs moved from
`developers.openai.com/codex/*` to `learn.chatgpt.com/docs/*` with a
**non-1:1 path remap** (e.g. `/codex/subagents` →
`/docs/agent-configuration/subagents`, `/codex/skills` →
`/docs/build-skills`). Old URLs 308-redirect but are no longer
canonical; every citation below points at the new home.

## TOC

1. Canonical instructions file
2. Skills / protocols
3. Subagents (parallel?)
4. Hooks
5. Auth
6. Rate limits (VOLATILE)
7. Cost
8. MCP (client + server)
9. Headless invocation
10. Gaps / Codex-CLI-down notes

## Volatility legend

Each claim's tag describes how often the underlying content tends to change:

- **`[STABLE]`** — major version bumps only (rare).
- **`[MEDIUM]`** — minor version bumps or quarterly cadence.
- **`[VOLATILE]`** — monthly or faster.

### Verification boundary (2026-08-25 walk)

Binary channel is **0.144.5 installed** (the 2026-07-18 walk ran against
0.139.0, so several previously docs-only claims are now executable).
Where a claim was tested, the probe and its **control** are cited
inline. Claims the binary could not discriminate — notably per-agent
`model` pinning, because `AgentRoleToml` ignores unknown fields — are
marked **`low-confidence`** per
[`refresh-vendor.md`](../../protocols/refresh-vendor.md).

A weekly calendar reminder triggers the cadence — when it fires, open Claude Code in the repo and type `/refresh-vendor <vendor>`. That supervised session walks every claim regardless of tier (Claude reads `last-verified` itself during step 2 of the protocol). The tiers inform per-claim re-tagging and form a ceiling on inter-walk gap: VOLATILE 60 days, MEDIUM 90 days, STABLE yearly.

The `last-verified` frontmatter date is the date of the **last applied change**, not the date of the last walk. Walk dates live in [`markdowns/agents/refresh-log.md`](../refresh-log.md).

---

## 1. Canonical instructions file

- **Native file:** `AGENTS.md`. Codex reads it natively — no shim, no config
  toggle. The format is the open spec stewarded by the Agentic AI Foundation
  under the Linux Foundation. `[STABLE]`
  ([agents.md](https://agents.md),
  [learn.chatgpt.com/docs/agent-configuration/agents-md](https://learn.chatgpt.com/docs/agent-configuration/agents-md))
- **Hierarchical lookup, three tiers:** (1) **Global** —
  `~/.codex/AGENTS.override.md` then `~/.codex/AGENTS.md` (whichever exists
  first). (2) **Project** — walk from git root down to cwd, checking each
  level for `AGENTS.override.md`, then `AGENTS.md`, then any
  `project_doc_fallback_filenames` configured in `~/.codex/config.toml`.
  (3) **Merge** — Codex concatenates files root-down with blank-line
  separators; the file closest to cwd appears last and overrides earlier
  guidance. `[STABLE]`
  ([learn.chatgpt.com/docs/agent-configuration/agents-md](https://learn.chatgpt.com/docs/agent-configuration/agents-md))
- **`AGENTS.override.md` precedence:** at every directory level, the
  override file beats the plain `AGENTS.md` at the same level. `[STABLE]`
  ([learn.chatgpt.com/docs/agent-configuration/agents-md](https://learn.chatgpt.com/docs/agent-configuration/agents-md))
- **Size cap:** Codex stops appending files once the combined size hits
  `project_doc_max_bytes` (default 32 KiB). `[STABLE]`
  ([learn.chatgpt.com/docs/agent-configuration/agents-md](https://learn.chatgpt.com/docs/agent-configuration/agents-md))
- **Search termination:** lookup stops at cwd — files in subdirectories of
  cwd are NOT scanned. Place overrides at or above the working location.
  `[STABLE]`
- **Profile isolation:** `CODEX_HOME` env var redirects the global lookup
  to a different directory; useful for per-project sandboxes. `[STABLE]`
- **Repo posture:** `AGENTS.md` at the repo root is the canonical
  instructions file. Codex reads it natively — no `.codex/settings`
  glue required. The pre-commit hook auto-mirrors AGENTS.md to
  CLAUDE.md so Claude Code's native lookup sees the same content.
  `[STABLE]`

---

## 2. Skills / protocols

- **First-party skills primitive — `.agents/skills/`, open Agent Skills
  standard.** Codex auto-discovers skills as directories anchored on a
  `SKILL.md` file with `name` + `description` frontmatter (both
  required), the same shape as Claude Code's. Skills build on the open
  Agent Skills standard ([agentskills.io](https://agentskills.io)).
  This corrects the prior walk's "no first-party skills primitive"
  claim — that is now false. `[MEDIUM]`
  ([learn.chatgpt.com/docs/build-skills](https://learn.chatgpt.com/docs/build-skills),
  [agentskills.io](https://agentskills.io))
- **Discovery scan:** "Codex scans `.agents/skills` in every directory
  from your current working directory up to the repository root." Four
  scope levels: `$REPO_ROOT/.agents/skills`, `$CWD/../.agents/skills`
  (each parent up the chain), `$HOME/.agents/skills` (personal), and
  `/etc/codex/skills` (system admin). `[MEDIUM]`
  ([learn.chatgpt.com/docs/build-skills](https://learn.chatgpt.com/docs/build-skills))
- **Invocation — both modes:** explicit (`$skill` mention in the prompt)
  AND implicit (auto-routed by `description` match). Unlike Codex
  subagents (§3, explicit-only), skills DO support description-match
  auto-invocation. `[MEDIUM]`
  ([learn.chatgpt.com/docs/build-skills](https://learn.chatgpt.com/docs/build-skills))
- **Skill directory layout:** `SKILL.md` is the only required file;
  optional `scripts/`, `references/`, `assets/` subdirs, plus an
  optional `agents/openai.yaml` for Codex-specific metadata. The
  `agents/openai.yaml` overlay is Codex's analogue to Claude's
  `.claude.frontmatter.yml` — vendor-specific fields stay out of the
  portable `SKILL.md`. `[MEDIUM]`
  ([learn.chatgpt.com/docs/build-skills](https://learn.chatgpt.com/docs/build-skills))
- **Repo posture:** this template's root [`.agents/skills/`](../../../.agents/skills/)
  is picked up by Codex's repo-root scan **with zero extra wiring** —
  the canonical source IS the standard surface Codex consumes. The
  four shipped skills (`build-feature`, `doc-consistency`,
  `refactor-extract`, `refresh-vendor`) carry the portable `name` +
  `description` subset, which is exactly what Codex requires. No
  `.codex/`-side mirror is needed (contrast Claude, which needs the
  `.claude/skills/` mirror). The `markdowns/protocols/` substance layer
  remains the deeper reference these skills point into. `[STABLE]`
- **Slash commands:** Codex ships built-in slash commands (`/agent`,
  `/permissions`, `/login`, `/logout`, `/status`, etc.) for runtime
  control. These are vendor-built-ins, not user-authored skills. `[MEDIUM]`
  ([learn.chatgpt.com/docs/codex/cli](https://learn.chatgpt.com/docs/codex/cli))
- **Plugin ecosystem: mature, remote-default as of 0.143.0.** `codex
  plugin` manages marketplaces; the `plugins` and `plugin_sharing`
  feature flags are stable-on (`codex features list`, 0.139.0). **Remote
  plugins are enabled by default as of 0.143.0** with npm marketplace
  sources and visible remote/local versions; `/plugins` organizes them
  into OpenAI Curated / Workspace / Shared-with-me sections (0.142.0),
  and eligible turns can recommend + install relevant plugins. Skills
  can install their MCP dependencies (`skill_mcp_dependency_install`
  stable). The old `plugin_hooks` feature flag was **removed** — plugin
  lifecycle hooks fold into core `hooks` (§4). Surface moves monthly —
  re-verify before relying. `[VOLATILE]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))
- **Cross-vendor import:** `/import` (0.140.0) selectively imports setup,
  project config, and recent chats **from Claude Code**; `@` opens a
  unified mentions menu for files, plugins, and skills. `[MEDIUM]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))

---

## 3. Subagents (parallel?)

- **File location:** TOML files at `.codex/agents/<name>.toml` (project) or
  `~/.codex/agents/<name>.toml` (personal). Required fields: `name`,
  `description`, `developer_instructions`. `[STABLE]`
- **Per-subagent model pinning — docs YES, binary INCONCLUSIVE.**
  `[MEDIUM]` `low-confidence` The subagents docs list `model` and
  `model_reasoning_effort` as optional agent-file fields (plus
  `sandbox_mode`, `mcp_servers`, `skills.config`), and state "you can
  also include other supported `config.toml` keys in a custom agent
  file." **The binary could not confirm it.** A `--strict-config` probe
  at 0.144.5 accepted an inline `AgentRoleToml` carrying `model`, but
  the **control carrying a nonsense field was accepted too** — the
  struct ignores unknown fields, so acceptance proves nothing about
  whether the key is honored. Treat as docs-sourced until a behavioral
  test (delegate to a pinned agent, observe the model actually used)
  runs. **This is the load-bearing claim for the cross-vendor model
  guardrail — verify it before building on it.**
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents),
  `codex exec --strict-config` probe 2026-08-25)
- **⚠️ `agents.default_subagent_model` does NOT exist at 0.144.5 —
  docs contradicted by binary.** The docs page describes
  `agents.default_subagent_model` and
  `agents.default_subagent_reasoning_effort` as `[agents]` config keys.
  The binary rejects both: `-c agents.default_subagent_model="…"` fails
  with `invalid type: string, expected struct AgentRoleToml`, i.e. the
  key is parsed as an *agent name* whose value must be a role struct.
  Per the channel-reliability ordering, **the binary wins**. There is
  therefore **no global subagent-model default** on Codex at this
  version; pinning must be per-agent. `[MEDIUM]`
  (`codex exec --strict-config -c agents.default_subagent_model=…`
  probe 2026-08-25)
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))
- **Parallel spawn:** YES. `agents.max_threads` (in `[agents]` section of
  `config.toml`) caps concurrent subagent threads — **default 6** when
  unset. **Key existence binary-confirmed at 0.144.5:** under
  `--strict-config`, `-c agents.max_threads=6` is accepted while an
  arbitrary `[agents]` key is rejected as `expected struct
  AgentRoleToml` — so `max_threads` is a recognised scalar key, not an
  agent name. (The *default value* 6 remains docs-sourced.) `[STABLE]`
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))
- **Nesting cap:** `agents.max_depth` defaults to **1** — the root
  thread spawns direct children but children can't spawn deeper
  descendants; raise the value to allow deeper nesting (docs caution
  against it: token/latency/resource cost). **Key existence
  binary-confirmed at 0.144.5** by the same `--strict-config`
  discriminator as `max_threads` above; the *default value* 1 remains
  docs-sourced. `[STABLE]`
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))
  **Cross-vendor head-to-head — REBUILT 2026-08-25** (both halves
  re-verified; the PR #9 pending marker is retired). Fan-out shape:

  | Axis | Codex CLI 0.144.5 | Claude Code 2.1.220 |
  |---|---|---|
  | Default nesting depth | **1** (`agents.max_depth`) | **3** (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`) |
  | Depth configurable? | Yes | Yes |
  | Concurrency cap | **6** (`agents.max_threads`) | **20** (`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`) |
  | Per-session total cap | none documented | **none** (200 cap removed v2.1.224) |
  | Delegation default | **explicit-request-only** | **description-match auto-routing** |
  | Per-agent model pinning | `model` in agent TOML (docs; binary inconclusive) | `model:` frontmatter, defaults `inherit` (docs-confirmed) |
  | Global subagent-model default | **none** (binary rejects `agents.default_subagent_model`) | **none** (no such setting) |

  **The load-bearing difference is no longer depth — it is delegation
  posture.** Codex only spawns subagents on an explicit request, so an
  unpinned expensive model has a bounded blast radius. Claude Code
  auto-routes by description match *and* inherits the session model, so
  an unpinned Claude subagent fleet is the higher cost exposure.
  Neither vendor offers a global subagent-model default; both require
  per-agent pinning. See [`claude-code.md`](claude-code.md) §3 / §10.
- **Delegation modes (0.142.0+) — explicit-request-only by default.**
  Multi-agent delegation is configurable per thread/turn as **disabled /
  explicit-request-only / proactive**. The default posture is
  explicit-request-only: the user runs `/agent`, names the agent, or a
  project/skill instruction requests it. The **exception is ChatGPT
  Ultra**, which can proactively delegate suitable work without an
  explicit ask (0.144.0 warns when high multi-agent concurrency could
  burn usage quickly). Description-match auto-routing (Claude Code's
  default model-invocation) still is NOT a Codex subagent behavior —
  contrast skills (§2), which DO auto-route. `[MEDIUM]`
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))
- **Error propagation (0.142.0):** parent agents now receive terminal
  subagent errors instead of seeing failed work as an empty successful
  completion. `[MEDIUM]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))
- **Job timeout:** `agents.job_max_runtime_seconds` caps per-worker
  runtime — **default 1800 s** when unset; relevant when using
  subagents for CSV batch jobs. **Key existence binary-confirmed at
  0.144.5** by the same `--strict-config` discriminator used for
  `max_depth` / `max_threads` (accepted as a scalar rather than
  rejected as `expected struct AgentRoleToml`); the *default value*
  1800 remains docs-sourced. `[MEDIUM]`
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))
- **Display + batch extras:** optional `nickname_candidates` field
  gives spawned agents readable display names; experimental
  `spawn_agents_on_csv` tool runs one worker per CSV row (workers
  report via `report_agent_job_result`). Subagents inherit the parent
  session's sandbox policy and runtime overrides. `[MEDIUM]`
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))
- **Cross-vendor commentary:** the explicit-only model applies to
  **subagents**, not skills. Skills (§2) DO auto-route by description
  match on Codex, so `/build-feature` and `/refresh-vendor` are
  auto-invocable from `.agents/skills/` here just as on Claude Code.
  Codex subagents, by contrast, require an explicit `/agent <name>` or
  prompt naming. Don't conflate the two surfaces. `[STABLE]`

---

## 4. Hooks

- **Enabled by default — feature flag no longer required.** The
  canonical feature key is now `hooks` (`codex features list` on
  0.139.0 shows `hooks stable true`); `codex_hooks` survives as a
  deprecated alias (it was still the listed name on 0.128.0). Disable
  explicitly with `[features] hooks = false` in `config.toml`. `[MEDIUM]`
  (binary `codex features list` 0.139.0,
  [learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks))
- **Event names (full list as of last-verified, 10 events):**
  `SessionStart`, `SubagentStart`, `PreToolUse`, `PermissionRequest`,
  `PostToolUse`, `PreCompact`, `PostCompact`, `UserPromptSubmit`,
  `SubagentStop`, `Stop`. `PreToolUse` / `PermissionRequest` carry
  permission-decision schemas that can rewrite tool inputs. `[MEDIUM]`
  ([learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks))
- **Configuration locations** (four canonical):
  `~/.codex/hooks.json`, `~/.codex/config.toml` (`[hooks]` table),
  `<repo>/.codex/hooks.json`, `<repo>/.codex/config.toml`. `[STABLE]`
  ([learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks))
- **Handler types:** only `type: "command"` (shell) executes; `prompt`
  and `agent` handler types are parsed but inactive. Configurations
  use matcher groups: an event + a matcher predicate + one or more
  handlers. Handlers receive event payload on stdin and run with the
  session working directory as context. `[MEDIUM]`
  ([learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks))
- **Hook trust model (0.141.0) — ⚠️ security-relevant for automation.**
  Enabled hooks now require **persisted hook trust** before they run.
  `codex exec` (and the global CLI) expose `--dangerously-bypass-hook-trust`
  to run enabled hooks without that persisted trust for a single
  invocation. **Supervised-use-only:** this bypass runs unvetted hook
  code — use it only in automation that already vets hook sources, never
  as a default in scripts. Bypass state persists through `codex exec`
  thread start + resume; blocking `PostToolUse` hooks correctly reject
  code-mode tool calls. `[MEDIUM]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))
- **Plugin-bundled + managed hooks:** plugins can ship hooks via their
  manifest or a default `hooks/hooks.json` (env vars `PLUGIN_ROOT`,
  `PLUGIN_DATA` available); enterprises can enforce managed hooks via
  `requirements.toml`. Note: the dedicated `plugin_hooks` feature flag
  was **removed** — plugin lifecycle hooks now fold into the core `hooks`
  machinery. `[MEDIUM]`
  ([learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks))
- **Vendor coupling:** event names overlap conceptually with Claude Code's
  set (`SessionStart`, `PreToolUse`, `PostToolUse`, `UserPromptSubmit`,
  `Stop`) but are NOT a 1:1 superset. Claude Code exposes 31 events (as of v2.1.219);
  Codex ~10. Cross-vendor parity is per-event translation, not a shared
  set. `[STABLE]`
- **Repo posture:** hooks stay Claude-only by default. Codex hooks
  portabilized only when the hook prevents a destructive non-code
  action (rare). `[STABLE]`

---

## 5. Auth

- **Default mode:** "Sign in with ChatGPT" — OAuth flow against any paid
  ChatGPT subscription (Plus / Pro $100 / Pro $200 / Business / Enterprise
  / Edu) or the Free tier. With no flags, `codex` opens a browser for
  OAuth on first run. `[STABLE]`
  ([learn.chatgpt.com/docs/auth](https://learn.chatgpt.com/docs/auth))
- **Credential storage — three modes via `cli_auth_credentials_store`:**
  - `"file"` — plaintext at `~/.codex/auth.json` under `CODEX_HOME`
    (default). Treat as a password; access tokens live here.
  - `"keyring"` — OS-native credential store (macOS Keychain, Windows
    Credential Manager, Linux Secret Service).
  - `"auto"` — keyring first, falls back to `auth.json`.

  Default behavior is file-based plaintext unless `cli_auth_credentials_store`
  is set (re-verified 2026-07-18 — default unchanged; docs still say
  treat `auth.json` like a password). `[STABLE]`
  ([learn.chatgpt.com/docs/auth](https://learn.chatgpt.com/docs/auth))
- **Managed Bedrock + encrypted OAuth storage (0.140.0):** added managed
  Amazon Bedrock API-key authentication and **encrypted local storage for
  CLI and MCP OAuth credentials** (additive — does NOT change the
  plaintext `auth.json` default above). Device-code login now surfaces
  phishing-recognition warnings (0.144.0). `[MEDIUM]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))
- **API key alternate:** `OPENAI_API_KEY` env var or
  `codex login --with-api-key` (reads the key from stdin, e.g.
  `printenv OPENAI_API_KEY | codex login --with-api-key`). The older
  `--api-key` spelling is gone from the binary. Pay-per-token via the
  OpenAI API; bypasses ChatGPT subscription limits. `[STABLE]`
  (binary `codex login --help` 0.139.0)
- **Device-code flow:** `codex login --device-auth` for headless / SSH
  environments where a browser is unavailable. Renamed from `--device`.
  `[STABLE]` (binary `codex login --help` 0.139.0,
  [learn.chatgpt.com/docs/auth](https://learn.chatgpt.com/docs/auth))
- **Agent identity (experimental):** `codex login --with-agent-identity`
  reads an Agent Identity token (`CODEX_AGENT_IDENTITY`) from stdin.
  `[VOLATILE]` (binary `codex login --help` 0.139.0)
- **Status check:** `codex login status` prints the active `auth_mode`
  and exits 0 when authenticated. Useful as a CI gate. `[STABLE]`
- **Cross-vendor parity:** Claude Code defaults to Anthropic OAuth.
  Per-vendor subscription posture lives in each vendor's knowledge file.
  `[STABLE]`

---

## 6. Rate limits — `[VOLATILE]`

**Re-verify before relying. The Pro $100 2× promotional boost expired
2026-05-31; as of this walk the pricing page carries no active boosts.**

- **Two windows, shared allowance:** Codex enforces a **5-hour rolling
  window** plus **additional weekly limits**. Local messages and cloud
  tasks draw from a combined allowance, not independent pools. Hitting
  either window blocks further use until reset. `[VOLATILE]`
  ([help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan](https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan),
  [learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing))
- **April 9, 2026 restructure (historical):** OpenAI aligned Codex limits
  with API-token usage instead of per-message pricing for Plus, Pro, and
  Business plans. Treat older blog posts citing message-count-only
  limits as stale. `[VOLATILE]`
  ([community.openai.com/t/understanding-the-new-codex-limit-system-after-the-april-9-update/1378768](https://community.openai.com/t/understanding-the-new-codex-limit-system-after-the-april-9-update/1378768))
- **Official sample 5h ranges (pricing page, updated 2026-07-18; now
  model-dependent, so each tier shows a low-model→high-model envelope):**
  - **Plus:** ~15–90 up to ~60–350 messages / 5h.
  - **Pro 5× ($100/mo):** ~75–450 up to ~300–1,750 messages / 5h.
  - **Pro 20× ($200/mo):** ~300–1,800 up to ~1,200–7,000 messages / 5h.

  Sample ranges, not contract. `[VOLATILE]`
  ([learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing))
- **Model families (as of this walk):** GPT-5.6 (Sol / Terra / Luna
  variants) is current alongside GPT-5.5, GPT-5.4, and GPT-5.4-mini;
  GPT-5.3-Codex-Spark is in research preview (Pro-only). The exact model
  chosen shifts the 5h range above. Model-selection detail is owned by
  [`model-capabilities.md`](../model-capabilities.md); GPT-5.6 drift is
  carried to that file's own walk. `[VOLATILE]`
  ([learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing))
- **Usage visibility (0.140.0+):** `/usage` shows daily / weekly /
  cumulative token activity; earned usage-limit **reset credits** are
  redeemable via `/usage` (0.142.0/0.144.0), and configurable rollout
  token budgets warn + abort turns on exhaustion. `[MEDIUM]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))
- **Weekly caps** apply to all paid tiers; on hit, users wait for reset
  or **buy credits** at token-based rates (e.g. GPT-5.5 input ≈125
  credits per million tokens — credits are the core pricing unit,
  consumption computed from token usage). `[VOLATILE]`
  ([learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing),
  [help.openai.com/en/articles/20001106-codex-rate-card](https://help.openai.com/en/articles/20001106-codex-rate-card))
- **Recovery posture:** on rate-limit hit, abort and re-run via
  `cross-vendor-review.sh --to <other-vendor>`. No automatic API-key
  fallback. `[STABLE]`

---

## 7. Cost

All paid ChatGPT plans include the Codex CLI. The Free tier also gets
limited Codex CLI access. `[STABLE]`
([chatgpt.com/pricing](https://chatgpt.com/pricing/),
[learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing))

> **Pricing-page rendering artifact (2026-07-18):** the
> [learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing)
> fetch renders **Pro 20× as "From $100"** (same extraction artifact seen
> on the Claude pricing page). The $200 in the table below is kept as
> correct — the 5h sample-range table (§6) distinguishes 5× from 20×.
> Prefer a browser check for exact Pro-tier pricing.

| Tier | Price | Codex CLI | Notes |
|---|---|---|---|
| **Free** | $0/mo | Yes (limited) | Ad-supported in some regions |
| **Go** | $8/mo | Yes | Ad-supported (US) |
| **Plus** | $20/mo | Yes | Baseline 5h + weekly limits |
| **Pro 5×** | $100/mo | Yes | 5× Plus limits |
| **Pro 20×** | $200/mo | Yes | 20× Plus limits |
| **Business** | $20/user/mo (2+ users, annual) | Yes | Matches Plus limits per seat; pay-as-you-go |
| **Enterprise / Edu** | contact sales | Yes | Custom limits |

- **API alt:** Pay-per-token via OpenAI API (GPT-5.6 / GPT-5.5 / GPT-5.4
  / GPT-5.4-mini). Bypasses subscription rate limits at standard token
  cost. `[STABLE]` ([openai.com/api/pricing](https://openai.com/api/pricing/))
- **Per-call cost in headless mode:** `codex exec --json` emits JSONL
  events including model name and token usage; budget caps live in
  `config.toml` (`[exec]` section). No equivalent of Claude Code's
  `--max-budget-usd` flag is documented. `[MEDIUM]`
- **Credit top-ups:** on hitting included limits, credits are
  purchasable at token-based rates (see §6). The 2026-04/05 Pro
  promotional boost is over (expired 2026-05-31). `[VOLATILE]`
  ([learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing))

---

## 8. MCP (client + server)

- **As client:** stable. Two transports — `stdio` (servers run as a local
  process started by a command) and **Streamable HTTP** (servers reachable
  at a URL). Configured via `[mcp_servers]` blocks in `config.toml` or via
  `codex mcp add`. `[STABLE]`
  ([learn.chatgpt.com/docs/extend/mcp?surface=cli](https://learn.chatgpt.com/docs/extend/mcp?surface=cli))
- **OAuth 2.0 supported:** `codex mcp login <server-name>` runs the OAuth
  flow for HTTP servers requiring auth. Callback port + URL configurable
  via `mcp_oauth_callback_port` / `mcp_oauth_callback_url` in
  `config.toml`. `[STABLE]`
  ([learn.chatgpt.com/docs/extend/mcp?surface=cli](https://learn.chatgpt.com/docs/extend/mcp?surface=cli))
- **As server: FIRST-PARTY.** `codex mcp-server` is a top-level
  subcommand ("Start Codex as an MCP server (stdio)") — verified
  against the binary on both 0.128.0 and 0.139.0. The docs site does
  not document it yet; per the refresh protocol's channel-reliability
  ordering, the binary wins this conflict. `[MEDIUM]`
  (binary `codex --help` 0.139.0)
- **Cross-vendor posture:** MCP cross-vendor servers still deferred —
  shell invocation via [`cross-vendor-review.sh`](../../../scripts/)
  remains today's answer. NOTE: the documented revisit trigger ("any
  vendor ships first-party MCP server") **fired 2026-06-10** when
  `codex mcp-server` was verified; the posture re-evaluation was
  deferred by the supervisor to its own session. `[STABLE]`
- **Remote stdio executor:** `[mcp_servers.<name>]` supports a remote
  executor for running stdio servers off-box; distinct from server-mode.
  `[MEDIUM]`
- **Recent MCP behavior (0.143.0/0.144.0):** MCP tools now use **tool
  search by default**; ChatGPT-hosted MCP servers can opt into session
  authentication; MCP tools can request interactive authentication
  **without an experimental opt-in** (0.144.0). `[MEDIUM]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))

---

## 9. Headless invocation

- **Entry point:** `codex exec "<prompt>"` (alias `codex e`). Runs the
  agent loop without opening the TUI; finishes without human interaction.
  Used by the SDK and by scripts. `[STABLE]`
  ([learn.chatgpt.com/docs/non-interactive-mode](https://learn.chatgpt.com/docs/non-interactive-mode))
- **Sandbox flag — three values:** `--sandbox read-only`,
  `--sandbox workspace-write`, `--sandbox danger-full-access`. `[STABLE]`
  ([learn.chatgpt.com/docs/developer-commands?surface=cli](https://learn.chatgpt.com/docs/developer-commands?surface=cli))
- **Approval flag — four values (interactive `codex` only; removed from `codex exec` in 0.128.0):** `--ask-for-approval untrusted`, `on-request`, `never`, `on-failure` (deprecated). `codex exec` mode runs non-interactive by default in 0.128.0+; no approval flag accepted there. `[STABLE]`
  ([learn.chatgpt.com/docs/developer-commands?surface=cli](https://learn.chatgpt.com/docs/developer-commands?surface=cli))
- **Output-last-message flag:** `--output-last-message <path>` (short
  `-o <path>`). Writes the assistant's final message to a file, stdout
  unchanged. The cross-vendor reviewer rubric reads this file. `[STABLE]`
  ([learn.chatgpt.com/docs/developer-commands?surface=cli](https://learn.chatgpt.com/docs/developer-commands?surface=cli),
  [learn.chatgpt.com/docs/non-interactive-mode](https://learn.chatgpt.com/docs/non-interactive-mode))
- **JSONL stream:** `--json` switches stdout to JSON Lines — one event per
  line, includes model name, tool calls, token usage, errors. Pipe to
  `jq` for parsing. `[STABLE]`
- **Repo skip:** `--skip-git-repo-check` allows running outside a git
  repo. Only set when the environment is known safe. `[STABLE]`
- **Structured output:** `--output-schema <FILE>` constrains the model's
  final response to a JSON Schema. Candidate replacement for the
  rubric's string-matching contract in `cross-vendor-review.sh`
  (evaluation queued, not adopted). `[MEDIUM]`
  (binary `codex exec --help` 0.139.0)
- **Other exec flags (binary 0.139.0):** `--ephemeral` (no session
  files persisted), `--ignore-user-config` (skip `$CODEX_HOME/config.toml`;
  auth still uses `CODEX_HOME`), `--ignore-rules` (skip execpolicy
  `.rules` files), `--enable <FEATURE>` / `--disable <FEATURE>`
  (per-invocation feature toggles), `-p/--profile <name>` (layer
  `$CODEX_HOME/<name>.config.toml`), `--add-dir <DIR>` (extra writable
  roots), `-C/--cd <DIR>` (working root), `-i/--image <FILE>`, `--oss` /
  `--local-provider <lmstudio|ollama>` (local model providers),
  `--strict-config`, `--color <always|never|auto>`. `[MEDIUM]`
  (binary `codex exec --help` 0.139.0)
- **⚠️ `codex exec` READS STDIN even when the prompt is an argument.**
  When stdin is not a TTY, `codex exec` appends stdin to the prompt and
  **blocks waiting for EOF**, printing `Reading additional input from
  stdin...`. It therefore works when a human runs it in a terminal and
  **hangs forever** in CI, background jobs, or piped contexts unless the
  caller closes stdin (`< /dev/null`). Found empirically 2026-08-25 when
  [`cross-vendor-review.sh`](../../../scripts/cross-vendor-review.sh)
  produced zero bytes across two runs totalling 11 minutes; the script
  does not close stdin. `[MEDIUM]` (empirical, binary 0.144.5)
- **`--strict-config` is the config-schema discriminator.** It rejects
  unrecognised keys, which makes it the correct tool for verifying a
  config claim by execution rather than by page-fetch. Caveat found
  2026-08-25: it validates the **table** level but not inside
  `AgentRoleToml` — a nonsense field inside an inline agent struct is
  silently accepted, so it cannot confirm agent-file fields. `[MEDIUM]`
  (empirical, binary 0.144.5)
- **Global reasoning effort leaks into scripted calls.** `codex exec`
  inherits `model_reasoning_effort` from `~/.codex/config.toml`
  (`xhigh` on this machine), with no per-invocation default. A 553-line
  diff review at `xhigh` exceeded 9 minutes. Scripted callers that need
  predictable latency should pass
  `-c model_reasoning_effort="medium"` explicitly. `[MEDIUM]`
  (empirical, binary 0.144.5)
- **Dangerous bypass flags — ⚠️ supervised-use-only.**
  `--dangerously-bypass-approvals-and-sandbox` skips ALL confirmation
  prompts and runs commands **without sandboxing** (only for externally
  sandboxed environments); `--dangerously-bypass-hook-trust` runs enabled
  hooks without persisted hook trust (§4). Both execute unvetted code —
  never wire them into scripts as a default; the cross-vendor review
  invocation below uses neither. `[MEDIUM]`
  (binary `codex exec --help` 0.139.0)
- **Session resumption:** `codex exec resume <session-id>` resumes a
  prior exec session. `[MEDIUM]`
- **Adjacent subcommands (binary 0.139.0):** `codex review` runs a
  **non-interactive code review** against the current repository
  (candidate alternative to `codex exec` for the cross-vendor
  dispatcher — evaluation queued); `codex features list|enable|disable`
  inspects feature flags; `codex update` self-updates; `codex fork`
  forks a prior session; `codex sandbox` runs arbitrary commands in the
  Codex sandbox; `codex cloud` (experimental) browses Codex Cloud
  tasks. **New since last walk:** `codex doctor` (diagnose install /
  config / auth / runtime health), `codex apply` (alias `a`, applies the
  agent's latest diff as `git apply`), `codex delete` + `/delete`
  (permanent session deletion with subagent cleanup, 0.140.0), `codex
  archive`/`unarchive`, `codex completion` (shell completions), `codex
  debug`, `codex app` (desktop app), and experimental `app-server` /
  `exec-server` / `remote-control` (incl. `remote-control pair`,
  0.143.0). `[MEDIUM]` (binary `codex --help` 0.139.0)
- **Cross-vendor review flag set** (consumed by `scripts/cross-vendor-review.sh` per [`cross-vendor-review.md`](../../protocols/cross-vendor-review.md)):

  ```
  codex exec \
    --sandbox read-only \
    --output-last-message <path> \
    "<prompt>"
  ```

  `--ask-for-approval never` was used pre-codex-0.128.0; the flag was
  removed upstream. The active vendor invocation in
  `scripts/cross-vendor-review.sh` is the source of truth.

  `--sandbox read-only` blocks all writes; `codex exec` 0.128.0+ runs
  non-interactive without an approval flag; `--output-last-message`
  captures the reviewer verdict for the script to parse. `[STABLE]`

---

## 10. Gaps / Codex-CLI-down notes

- **Skills: first-party, NOT a gap anymore.** Codex auto-discovers and
  auto-invokes `.agents/skills/` (open Agent Skills standard) — see §2.
  The repo's root `.agents/skills/` works on Codex out of the box. The
  prior "no first-party skills primitive" gap (carried through the
  2026-06-10 walk) is closed as of 2026-06-20. `[MEDIUM]`
  ([learn.chatgpt.com/docs/build-skills](https://learn.chatgpt.com/docs/build-skills))
- **Subagent depth capped at 1 by default** (`max_depth=1`; key
  existence binary-confirmed at 0.144.5, default value docs-sourced;
  raisable via config). The cross-vendor head-to-head is **rebuilt in
  §3** as of 2026-08-25 and the pending marker is retired. Headline:
  the meaningful asymmetry is **delegation posture** (Codex
  explicit-request-only vs Claude description-match auto-routing), not
  nesting depth. `[STABLE]`
- **Hooks default-on since ~0.13x** (canonical flag key `hooks`,
  deprecated alias `codex_hooks`). The old "flag required, silent
  failure" gap is resolved; only relevant if a config explicitly sets
  `hooks = false`. **New (0.141.0):** enabled hooks require persisted
  **hook trust**; `--dangerously-bypass-hook-trust` bypasses it —
  supervised-use-only (§4/§9). `[MEDIUM]` (binary `codex features list`
  0.139.0, [learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks))
- **MCP server-mode now first-party** (`codex mcp-server`, stdio) but
  undocumented on the docs site and unadopted here. Cross-tool fan-out
  stays on shell-invocation cross-vendor review until the deferred
  posture session (§8) decides otherwise. `[MEDIUM]`
  (binary `codex --help` 0.139.0)
- **Auth credentials default to plaintext** at `~/.codex/auth.json`. For
  shared dev machines, set `cli_auth_credentials_store = "keyring"` in
  `~/.codex/config.toml`. `[STABLE]`
- **Rate-limit numbers are sample ranges, not contract.** OpenAI now
  publishes official sample 5h ranges per tier on the pricing page
  (see §6), but variation reflects task complexity — treat as
  envelopes. Older third-party message-count posts are stale and were
  dropped from §6 this walk. `[VOLATILE]`
  ([learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing))
- **Codex-CLI-down posture:** every meta-layer artifact in
  [`markdowns/`](../../) is acceptable in degraded mode. Substance
  (markdown, AGENTS.md, protocols, scripts) is portable; the loss is
  parallel subagent fan-out for deep-dive sessions on heavy surfaces.
  `[STABLE]`

## See also

- [`markdowns/agents/README.md`](../README.md) — index for the three vendor
  knowledge files.
- [`markdowns/meta-layer/cross-vendor-harness.md`](../../meta-layer/cross-vendor-harness.md)
  — per-vendor consumption topology + sync mechanics.
- [`markdowns/protocols/cross-vendor-review.md`](../../protocols/cross-vendor-review.md) —
  downstream consumer (cross-vendor review rubric, the cross-vendor review script).
