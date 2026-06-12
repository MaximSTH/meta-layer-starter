---
name: vendor-knowledge-codex-cli
description: Volatility-tagged knowledge of Codex CLI — canonical file (AGENTS.md native), skills, subagents, hooks, auth, rate limits, cost, MCP, headless. Drives cross-vendor scripts and /refresh-vendor.
status: reference
last-verified: 2026-06-10
---

# Codex CLI — vendor knowledge

Single file. One vendor. Every claim carries a `[STABLE]` / `[MEDIUM]` /
`[VOLATILE]` tag and a URL citation. Walked weekly by [`refresh-vendor.md`](../../protocols/refresh-vendor.md); change-marker semantics (no edit on no-op). Linked from the README at [`markdowns/agents/README.md`](../README.md).

**Install:** `npm install -g @openai/codex` —
see [`developers.openai.com/codex/cli`](https://developers.openai.com/codex/cli)
for platform-specific instructions and authentication setup. (Package
name verified via `npm view @openai/codex` → 0.139.0, 2026-06-10; the
binary it installs is `codex`, not `codex-cli`.)

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

A weekly calendar reminder triggers the cadence — when it fires, open Claude Code in the repo and type `/refresh-vendor <vendor>`. That supervised session walks every claim regardless of tier (Claude reads `last-verified` itself during step 2 of the protocol). The tiers inform per-claim re-tagging and form a ceiling on inter-walk gap: VOLATILE 60 days, MEDIUM 90 days, STABLE yearly.

The `last-verified` frontmatter date is the date of the **last applied change**, not the date of the last walk. Walk dates live in [`markdowns/agents/refresh-log.md`](../refresh-log.md).

---

## 1. Canonical instructions file

- **Native file:** `AGENTS.md`. Codex reads it natively — no shim, no config
  toggle. The format is the open spec stewarded by the Agentic AI Foundation
  under the Linux Foundation. `[STABLE]`
  ([agents.md](https://agents.md),
  [developers.openai.com/codex/guides/agents-md](https://developers.openai.com/codex/guides/agents-md))
- **Hierarchical lookup, three tiers:** (1) **Global** —
  `~/.codex/AGENTS.override.md` then `~/.codex/AGENTS.md` (whichever exists
  first). (2) **Project** — walk from git root down to cwd, checking each
  level for `AGENTS.override.md`, then `AGENTS.md`, then any
  `project_doc_fallback_filenames` configured in `~/.codex/config.toml`.
  (3) **Merge** — Codex concatenates files root-down with blank-line
  separators; the file closest to cwd appears last and overrides earlier
  guidance. `[STABLE]`
  ([developers.openai.com/codex/guides/agents-md](https://developers.openai.com/codex/guides/agents-md))
- **`AGENTS.override.md` precedence:** at every directory level, the
  override file beats the plain `AGENTS.md` at the same level. `[STABLE]`
  ([developers.openai.com/codex/guides/agents-md](https://developers.openai.com/codex/guides/agents-md))
- **Size cap:** Codex stops appending files once the combined size hits
  `project_doc_max_bytes` (default 32 KiB). `[STABLE]`
  ([developers.openai.com/codex/guides/agents-md](https://developers.openai.com/codex/guides/agents-md))
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

- **No first-party skills primitive in the same shape as Claude Code's
  `SKILL.md`.** Codex relies on AGENTS.md instructions + subagents +
  prompts; it does not auto-discover a `~/.codex/skills/` tree. `[MEDIUM]`
  ([developers.openai.com/codex/cli](https://developers.openai.com/codex/cli))
- **Repo posture:** the `markdowns/protocols/` substance layer is
  Codex's portable equivalent — protocols are read into the prompt via
  `AGENTS.md` references. The `.agents/skills/` cross-vendor skill skeleton
  carries `name` + `description` only; on Codex it serves as a
  human-readable protocol pointer rather than an auto-invoked surface.
  `[STABLE]`
- **Slash commands:** Codex ships built-in slash commands (`/agent`,
  `/permissions`, `/login`, `/logout`, `/status`, etc.) for runtime
  control. These are vendor-built-ins, not user-authored skills. `[MEDIUM]`
  ([developers.openai.com/codex/cli/features](https://developers.openai.com/codex/cli/features))
- **Plugin ecosystem: EXISTS as of mid-2026.** `codex plugin
  marketplace` manages plugin marketplaces (verified `codex plugin
  --help`, binary 0.139.0); the `plugins` feature flag is stable and
  enabled by default (`codex features list`). Releases 0.138.0–0.139.0
  added `plugin add/remove/detail --json` with structured output
  (default prompts, remote MCP servers, app templates) and marketplace
  caching. Plugins can bundle hooks (§4). Surface is moving monthly —
  re-verify before relying. `[VOLATILE]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))

---

## 3. Subagents (parallel?)

- **File location:** TOML files at `.codex/agents/<name>.toml` (project) or
  `~/.codex/agents/<name>.toml` (personal). Required fields: `name`,
  `description`, `developer_instructions`. `[STABLE]`
  ([developers.openai.com/codex/subagents](https://developers.openai.com/codex/subagents))
- **Parallel spawn:** YES. `agents.max_threads` (in `[agents]` section of
  `config.toml`) caps concurrent subagent threads — **default 6** when
  unset. `[STABLE]`
  ([developers.openai.com/codex/subagents](https://developers.openai.com/codex/subagents))
- **Nesting cap:** `agents.max_depth` defaults to **1** — a direct child
  agent can spawn, but deeper nesting is blocked. Compounds with Claude
  Code's "subagents cannot spawn subagents" — neither vendor supports
  deep fan-out by default. `[STABLE]`
  ([developers.openai.com/codex/subagents](https://developers.openai.com/codex/subagents))
- **Explicit invocation only:** "Codex only spawns a new agent when you
  explicitly ask it to do so." Auto-routing by description match (Claude
  Code's default model-invocation) is NOT supported — the user runs
  `/agent` or names the agent in the prompt. `[STABLE]`
  ([developers.openai.com/codex/subagents](https://developers.openai.com/codex/subagents))
- **Job timeout:** `agents.job_max_runtime_seconds` caps per-worker
  runtime — **default 1800 s** when unset; relevant when using
  subagents for CSV batch jobs. `[MEDIUM]`
  ([developers.openai.com/codex/subagents](https://developers.openai.com/codex/subagents))
- **Display + batch extras:** optional `nickname_candidates` field
  gives spawned agents readable display names; experimental
  `spawn_agents_on_csv` tool runs one worker per CSV row (workers
  report via `report_agent_job_result`). Subagents inherit the parent
  session's sandbox policy and runtime overrides. `[MEDIUM]`
  ([developers.openai.com/codex/subagents](https://developers.openai.com/codex/subagents))
- **Cross-vendor commentary:** Codex's explicit-only model means the 
  `/build-feature` skill and `/refresh-vendor` skill cannot rely on
  description-match auto-invocation here — they ship as human-invoked
  prompts, not agents. The `.agents/skills/` skeleton carries
  protocol pointers Codex consumes via AGENTS.md. `[STABLE]`

---

## 4. Hooks

- **Enabled by default — feature flag no longer required.** The
  canonical feature key is now `hooks` (`codex features list` on
  0.139.0 shows `hooks stable true`); `codex_hooks` survives as a
  deprecated alias (it was still the listed name on 0.128.0). Disable
  explicitly with `[features] hooks = false` in `config.toml`. `[MEDIUM]`
  (binary `codex features list` 0.139.0,
  [developers.openai.com/codex/hooks](https://developers.openai.com/codex/hooks))
- **Event names (full list as of last-verified, 10 events):**
  `SessionStart`, `SubagentStart`, `PreToolUse`, `PermissionRequest`,
  `PostToolUse`, `PreCompact`, `PostCompact`, `UserPromptSubmit`,
  `SubagentStop`, `Stop`. `PreToolUse` / `PermissionRequest` carry
  permission-decision schemas that can rewrite tool inputs. `[MEDIUM]`
  ([developers.openai.com/codex/hooks](https://developers.openai.com/codex/hooks))
- **Configuration locations** (four canonical):
  `~/.codex/hooks.json`, `~/.codex/config.toml` (`[hooks]` table),
  `<repo>/.codex/hooks.json`, `<repo>/.codex/config.toml`. `[STABLE]`
  ([developers.openai.com/codex/hooks](https://developers.openai.com/codex/hooks))
- **Handler types:** only `type: "command"` (shell) executes; `prompt`
  and `agent` handler types are parsed but inactive. Configurations
  use matcher groups: an event + a matcher predicate + one or more
  handlers. Handlers receive event payload on stdin and run with the
  session working directory as context. `[MEDIUM]`
  ([developers.openai.com/codex/hooks](https://developers.openai.com/codex/hooks))
- **Plugin-bundled + managed hooks:** plugins can ship hooks via their
  manifest or a default `hooks/hooks.json` (env vars `PLUGIN_ROOT`,
  `PLUGIN_DATA` available); enterprises can enforce managed hooks via
  `requirements.toml`. `[MEDIUM]`
  ([developers.openai.com/codex/hooks](https://developers.openai.com/codex/hooks))
- **Vendor coupling:** event names overlap conceptually with Claude Code's
  set (`SessionStart`, `PreToolUse`, `PostToolUse`, `UserPromptSubmit`,
  `Stop`) but are NOT a 1:1 superset. Claude Code exposes ~28 events;
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
  ([developers.openai.com/codex/auth](https://developers.openai.com/codex/auth))
- **Credential storage — three modes via `cli_auth_credentials_store`:**
  - `"file"` — plaintext at `~/.codex/auth.json` under `CODEX_HOME`
    (default). Treat as a password; access tokens live here.
  - `"keyring"` — OS-native credential store (macOS Keychain, Windows
    Credential Manager, Linux Secret Service).
  - `"auto"` — keyring first, falls back to `auth.json`.

  Default behavior is file-based plaintext unless `cli_auth_credentials_store`
  is set. `[STABLE]`
  ([developers.openai.com/codex/auth](https://developers.openai.com/codex/auth))
- **API key alternate:** `OPENAI_API_KEY` env var or
  `codex login --with-api-key` (reads the key from stdin, e.g.
  `printenv OPENAI_API_KEY | codex login --with-api-key`). The older
  `--api-key` spelling is gone from the binary. Pay-per-token via the
  OpenAI API; bypasses ChatGPT subscription limits. `[STABLE]`
  (binary `codex login --help` 0.139.0)
- **Device-code flow:** `codex login --device-auth` for headless / SSH
  environments where a browser is unavailable. Renamed from `--device`.
  `[STABLE]` (binary `codex login --help` 0.139.0,
  [developers.openai.com/codex/auth](https://developers.openai.com/codex/auth))
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
  [developers.openai.com/codex/pricing](https://developers.openai.com/codex/pricing))
- **April 9, 2026 restructure (historical):** OpenAI aligned Codex limits
  with API-token usage instead of per-message pricing for Plus, Pro, and
  Business plans. Treat older blog posts citing message-count-only
  limits as stale. `[VOLATILE]`
  ([community.openai.com/t/understanding-the-new-codex-limit-system-after-the-april-9-update/1378768](https://community.openai.com/t/understanding-the-new-codex-limit-system-after-the-april-9-update/1378768))
- **Official sample 5h ranges (now published on the pricing page;
  variation reflects task complexity):**
  - **Plus:** GPT-5.5 ~15–80 messages / 5h.
  - **Pro 5× ($100/mo):** ~80–400 messages / 5h.
  - **Pro 20× ($200/mo):** ~300–1,600 messages / 5h.

  Sample ranges, not contract. `[VOLATILE]`
  ([developers.openai.com/codex/pricing](https://developers.openai.com/codex/pricing))
- **Weekly caps** apply to all paid tiers; on hit, users wait for reset
  or **buy credits** at token-based rates (e.g. GPT-5.5 input ≈125
  credits per million tokens — credits are the core pricing unit,
  consumption computed from token usage). `[VOLATILE]`
  ([developers.openai.com/codex/pricing](https://developers.openai.com/codex/pricing),
  [help.openai.com/en/articles/20001106-codex-rate-card](https://help.openai.com/en/articles/20001106-codex-rate-card))
- **Recovery posture:** on rate-limit hit, abort and re-run via
  `cross-vendor-review.sh --to <other-vendor>`. No automatic API-key
  fallback. `[STABLE]`

---

## 7. Cost

All paid ChatGPT plans include the Codex CLI. The Free tier also gets
limited Codex CLI access. `[STABLE]`
([chatgpt.com/pricing](https://chatgpt.com/pricing/),
[developers.openai.com/codex/pricing](https://developers.openai.com/codex/pricing))

| Tier | Price | Codex CLI | Notes |
|---|---|---|---|
| **Free** | $0/mo | Yes (limited) | Ad-supported in some regions |
| **Go** | $8/mo | Yes | Ad-supported (US) |
| **Plus** | $20/mo | Yes | Baseline 5h + weekly limits |
| **Pro 5×** | $100/mo | Yes | 5× Plus limits |
| **Pro 20×** | $200/mo | Yes | 20× Plus limits |
| **Business** | per-seat | Yes | Matches Plus limits per seat; pay-as-you-go |
| **Enterprise / Edu** | contact sales | Yes | Custom limits |

- **API alt:** Pay-per-token via OpenAI API (GPT-5.4 / GPT-5.4-mini /
  GPT-5.5). Bypasses subscription rate limits at standard token cost.
  `[STABLE]` ([openai.com/api/pricing](https://openai.com/api/pricing/))
- **Per-call cost in headless mode:** `codex exec --json` emits JSONL
  events including model name and token usage; budget caps live in
  `config.toml` (`[exec]` section). No equivalent of Claude Code's
  `--max-budget-usd` flag is documented. `[MEDIUM]`
- **Credit top-ups:** on hitting included limits, credits are
  purchasable at token-based rates (see §6). The 2026-04/05 Pro
  promotional boost is over (expired 2026-05-31). `[VOLATILE]`
  ([developers.openai.com/codex/pricing](https://developers.openai.com/codex/pricing))

---

## 8. MCP (client + server)

- **As client:** stable. Two transports — `stdio` (servers run as a local
  process started by a command) and **Streamable HTTP** (servers reachable
  at a URL). Configured via `[mcp_servers]` blocks in `config.toml` or via
  `codex mcp add`. `[STABLE]`
  ([developers.openai.com/codex/mcp](https://developers.openai.com/codex/mcp))
- **OAuth 2.0 supported:** `codex mcp login <server-name>` runs the OAuth
  flow for HTTP servers requiring auth. Callback port + URL configurable
  via `mcp_oauth_callback_port` / `mcp_oauth_callback_url` in
  `config.toml`. `[STABLE]`
  ([developers.openai.com/codex/mcp](https://developers.openai.com/codex/mcp))
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

---

## 9. Headless invocation

- **Entry point:** `codex exec "<prompt>"` (alias `codex e`). Runs the
  agent loop without opening the TUI; finishes without human interaction.
  Used by the SDK and by scripts. `[STABLE]`
  ([developers.openai.com/codex/noninteractive](https://developers.openai.com/codex/noninteractive))
- **Sandbox flag — three values:** `--sandbox read-only`,
  `--sandbox workspace-write`, `--sandbox danger-full-access`. `[STABLE]`
  ([developers.openai.com/codex/cli/reference](https://developers.openai.com/codex/cli/reference))
- **Approval flag — four values (interactive `codex` only; removed from `codex exec` in 0.128.0):** `--ask-for-approval untrusted`, `on-request`, `never`, `on-failure` (deprecated). `codex exec` mode runs non-interactive by default in 0.128.0+; no approval flag accepted there. `[STABLE]`
  ([developers.openai.com/codex/cli/reference](https://developers.openai.com/codex/cli/reference))
- **Output-last-message flag:** `--output-last-message <path>` (short
  `-o <path>`). Writes the assistant's final message to a file, stdout
  unchanged. The cross-vendor reviewer rubric reads this file. `[STABLE]`
  ([developers.openai.com/codex/cli/reference](https://developers.openai.com/codex/cli/reference),
  [developers.openai.com/codex/noninteractive](https://developers.openai.com/codex/noninteractive))
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
- **Other exec flags (added by 0.139.0):** `--ephemeral` (no session
  files persisted), `--ignore-user-config` (skip `$CODEX_HOME/config.toml`;
  auth still uses `CODEX_HOME`), `--ignore-rules` (skip execpolicy
  `.rules` files), `--enable <FEATURE>` / `--disable <FEATURE>`
  (per-invocation feature toggles). `[MEDIUM]`
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
  tasks. `[MEDIUM]` (binary `codex --help` 0.139.0)
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

- **No first-party skills primitive.** Cross-vendor skills ship as
  protocol pointers Codex consumes via `AGENTS.md`, not as auto-invoked
  surfaces. Manual `/agent <name>` is the equivalent invocation path.
  `[STABLE]`
- **Subagent depth capped at 1** (`max_depth=1` default). Compounds with
  Claude Code's "subagents cannot spawn subagents." Fan-out wider than
  1-level requires shell-driven orchestration. `[STABLE]`
- **Hooks default-on since ~0.13x** (canonical flag key `hooks`,
  deprecated alias `codex_hooks`). The old "flag required, silent
  failure" gap is resolved; only relevant if a config explicitly sets
  `hooks = false`. `[MEDIUM]` (binary `codex features list` 0.139.0,
  [developers.openai.com/codex/hooks](https://developers.openai.com/codex/hooks))
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
  ([developers.openai.com/codex/pricing](https://developers.openai.com/codex/pricing))
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
