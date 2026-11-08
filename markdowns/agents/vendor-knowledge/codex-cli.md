---
name: vendor-knowledge-codex-cli
description: Volatility-tagged knowledge of Codex CLI — canonical file (AGENTS.md native), skills, subagents, hooks, auth, rate limits, cost, MCP, headless. Drives cross-vendor scripts and /refresh-vendor.
status: reference
last-verified: 2026-11-08
---

# Codex CLI — vendor knowledge

Single file. One vendor. Every claim carries a `[STABLE]` / `[MEDIUM]` /
`[VOLATILE]` tag and a URL citation. Walked weekly by [`refresh-vendor.md`](../../protocols/refresh-vendor.md); change-marker semantics (no edit on no-op). Linked from the README at [`markdowns/agents/README.md`](../README.md).

**Install:** `npm install -g @openai/codex` —
see [`learn.chatgpt.com/docs/codex/cli`](https://learn.chatgpt.com/docs/codex/cli)
for platform-specific instructions and authentication setup. (Package
name verified via `npm view @openai/codex` → **0.167.0 latest,
2026-11-08**; local binary introspected at **0.162.1** (Homebrew);
0.145.0–0.162.1 walked via binary + GitHub release notes, 0.163.0–0.167.0
via release notes only. The binary it installs is `codex`, not
`codex-cli`.) The docs page now leads with a standalone installer
(`curl -fsSL https://chatgpt.com/codex/install.sh | sh`) and still lists
npm and Homebrew. `[STABLE]`

**Docs host migration (2026-07-18):** the docs moved from
`developers.openai.com/codex/*` to `learn.chatgpt.com/docs/*` with a
**non-1:1 path remap** (e.g. `/codex/subagents` →
`/docs/agent-configuration/subagents`, `/codex/skills` →
`/docs/build-skills`). Old URLs 308-redirect but are no longer
canonical; every citation below points at the new home. Re-checked
2026-11-08: every `learn.chatgpt.com` citation returns 200 with no
redirect (host has not moved again); `help.openai.com` articles return
403 to scripted fetches.

## TOC

1. Canonical instructions file
2. Skills / protocols
3. Subagents (parallel?)
4. Hooks
5. Auth
6. Rate limits (VOLATILE)
7. Cost
8. MCP (client only since 0.154.0)
9. Headless invocation
10. Gaps / Codex-CLI-down notes

## Volatility legend

Each claim's tag describes how often the underlying content tends to change:

- **`[STABLE]`** — major version bumps only (rare).
- **`[MEDIUM]`** — minor version bumps or quarterly cadence.
- **`[VOLATILE]`** — monthly or faster.

### Verification boundary (2026-11-08 walk)

Binary channel is **0.162.1 installed**; npm latest is **0.167.0**.
Claims about 0.163.0–0.167.0 are release-notes-only and tagged
**`low-confidence`** per
[`refresh-vendor.md`](../../protocols/refresh-vendor.md). Where a claim
was tested, the probe and its **control** are cited inline. Probes ran
in a scratch `CODEX_HOME` with **no auth**: an accepted config proceeds
to a 401 before any model call, a rejected one fails at config load —
so schema claims were verified without spending model calls. Behavior
that needs a live, authenticated run — notably whether a subagent
`model` pin is **honored at spawn** — remains `low-confidence`.

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
- **⚠️ Project-level `AGENTS.md` is trust-gated (0.150.0).** "Untrusted
  projects no longer supply project-level `AGENTS.md` instructions"
  (release rust-v0.150.0 #39837); 0.147.0 already required explicit
  trust for unfamiliar local projects (#36960). A project that is not
  in the user's trusted list therefore runs **without** its project
  `AGENTS.md`. Non-interactive runs surface the same gate: `codex exec`
  in a non-git, untrusted directory fails with "Not inside a trusted
  directory and --skip-git-repo-check was not specified" (execution,
  binary 0.162.1). `[MEDIUM]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))
- **Repo posture:** `AGENTS.md` at the repo root is the canonical
  instructions file. Codex reads it natively — no `.codex/settings`
  glue required — **provided the project is trusted** (above); an
  adopter's fresh clone is untrusted until they accept it. The
  pre-commit hook auto-mirrors AGENTS.md to CLAUDE.md so Claude Code's
  native lookup sees the same content. `[MEDIUM]` (was `[STABLE]`;
  retagged for the trust precondition)

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
  `/etc/codex/skills` (system admin), plus bundled system skills
  (`skill-creator`, `skill-installer`). Same-name skills are not
  merged. `[MEDIUM]`
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
  portable `SKILL.md`. `agents/openai.yaml` carries UI metadata,
  invocation policy and tool dependencies; `allow_implicit_invocation`
  defaults to `true` (when `false`, explicit `$skill` still works).
  `[MEDIUM]`
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
- **Slash commands:** Codex ships built-in slash commands for runtime
  control. The CLI page's sample session shows `/init`, `/status`,
  `/permissions`, `/model`, `/review`; `/agent`, `/login`, `/logout`
  were not re-confirmed this walk (the full list lives on a separate
  slash-commands page, not fetched). Release notes add `/export`
  (0.148.0), `/cd`/`/pwd`/`/cwd` (0.149.0), `/worktree` (0.154.0),
  `/daemon` (0.156.0), `/mcp login` (0.161.0). These are
  vendor-built-ins, not user-authored skills. `[MEDIUM]`
  ([learn.chatgpt.com/docs/codex/cli](https://learn.chatgpt.com/docs/codex/cli),
  [github.com/openai/codex/releases](https://github.com/openai/codex/releases))
- **Plugin ecosystem: mature, remote-default as of 0.143.0.** `codex
  plugin` manages marketplaces; the `plugins` and `plugin_sharing`
  feature flags are stable-on (`codex features list`, 0.139.0; still so at 0.162.1). **Remote
  plugins are enabled by default as of 0.143.0** with npm marketplace
  sources and visible remote/local versions; `/plugins` organizes them
  into OpenAI Curated / Workspace / Shared-with-me sections (0.142.0),
  and eligible turns can recommend + install relevant plugins. Skills
  can install their MCP dependencies (`skill_mcp_dependency_install`
  stable). The old `plugin_hooks` feature flag was **removed** — plugin
  lifecycle hooks fold into core `hooks` (§4). **Since last walk:**
  portable Agent Plugins manifests and workspace publishing
  (0.146.0/0.147.0); `codex plugin add|list|marketplace|remove` manages
  local + remote marketplaces from the CLI (0.153.0; `codex plugin
  --help` 0.162.1). `features list` 0.162.1: `plugins`,
  `plugin_sharing`, `remote_plugin` stable-on; `recommended_plugins`
  stable-off. Surface moves monthly — re-verify before relying.
  `[VOLATILE]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))
- **Cross-vendor import:** `/import` (0.140.0) selectively imports setup,
  project config, and recent chats **from Claude Code**; expanded in
  0.145.0/0.147.0 to **Cursor** as well (settings, MCP servers,
  plugins, sessions, commands, project-scoped memories, Cursor-managed
  skills). `@` opens a unified mentions menu for files, plugins, and
  skills. `[MEDIUM]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))

---

## 3. Subagents (parallel?)

- **File location:** TOML files at `.codex/agents/<name>.toml` (project) or
  `~/.codex/agents/<name>.toml` (personal). Required fields: `name`,
  `description`, `developer_instructions`. `[STABLE]`
- **Agent files are strictly deserialized (binary 0.162.1) — the
  `model` key is SCHEMA-CONFIRMED; honoring at spawn is NOT.** This
  reverses the 2026-08-25 "binary INCONCLUSIVE" finding. A standalone
  agent file under `$CODEX_HOME/agents/` is now parsed with unknown
  fields rejected and known fields typed (`codex exec --strict-config`
  probes, scratch `CODEX_HOME`, 2026-11-08):
  `zzz_nonsense = 1` → `unknown field`; `model = 1` → `invalid type:
  integer, expected a string`; `model_reasoning_effort = 1` → `expected
  a string`; `sandbox_mode = "bogus"` → `expected one of read-only,
  workspace-write, danger-full-access`. So `model` and
  `model_reasoning_effort` are recognised, typed agent-file fields
  `[MEDIUM]` (verified by execution). The old caveat ("`AgentRoleToml`
  ignores unknown fields") now holds **only for inline
  `[agents.<name>]` tables** in `config.toml`, where `model = 1` and a
  nonsense field are still both accepted; the inline table's own fields
  (`description`, `config_file`, `nickname_candidates`) are typed.
  Release rust-v0.145.0–0.149.0 context: #39299 "Restrict agent roles
  to bounded configuration overrides".
  **Whether a pinned `model` is honored when a subagent actually spawns
  remains `low-confidence`:** no spawn was attempted this walk (it needs
  an authenticated run). The 2026-08-25 behavioral attempt (0.144.5)
  failed one step earlier: `codex exec --json` with an explicit
  "delegate to <agent>" prompt produced `collab_tool_call` events with
  **empty `receiver_thread_ids`** — no subagent thread spawned; the
  plain-text reply mimicked successful delegation. Headless spawning is
  unverified at 0.162.1 too. **Consequence for the model guardrail:** no
  Codex enforcement artifact ships until a spawn is demonstrable.
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents),
  agent-file probes 2026-11-08, `--json` delegation probe 2026-08-25)
- **⚠️ A malformed agent file is dropped with only a warning.** Even
  under `--strict-config`, a bad agent file yields `warning: Ignoring
  malformed agent role definition: …` and the run continues **without
  that agent** — a typo in a pin silently removes the agent instead of
  failing. Any enforcement artifact must check for this warning.
  `[MEDIUM]` (execution, binary 0.162.1)
- **Agent-file field semantics (docs).** Model fields: `model`,
  `model_reasoning_effort`, `model_reasoning_summary`,
  `model_verbosity`. Capability reduction: set feature keys to false
  (`features.shell_tool`, `features.apps`, `features.plugins`); disable
  skills via `skills.config`. **Correction:** the docs now state that
  `sandbox_mode`, `approval_policy`, `model_provider` and `mcp_servers`
  in an agent file do **NOT** override the parent config — the prior
  walk listed `sandbox_mode` / `mcp_servers` as optional override
  fields. (The binary still type-checks `sandbox_mode`, so it parses;
  parsing ≠ applying.) `[MEDIUM]` docs-only
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))
- **⚠️ REVERSAL — `agents.default_subagent_model` and
  `agents.default_subagent_reasoning_effort` ARE real keys at 0.162.1.**
  At 0.144.5 the binary parsed them as agent *names*
  (`expected struct AgentRoleToml`). At 0.162.1, under
  `--strict-config`, `-c agents.default_subagent_model="gpt-5.4-mini"`
  and `-c agents.default_subagent_reasoning_effort="low"` are accepted;
  type controls `=1` and `={x=1}` are rejected with `expected a
  string`, while the nonsense-key control `agents.zzz_nonsense=1` is
  still rejected as `expected struct AgentRoleToml` — so these are
  typed scalar keys, not agent names. Likely landed in 0.145.0
  ("Stabilized the opt-in multi-agent V2 experience with configurable
  sub-agent models, reasoning levels, concurrency…"; #33550 "Unify
  multi-agent settings under `agents`", #33631 "Honor configured model
  defaults for spawned agents"). Docs: "Explicit spawn values override
  `agents.default_subagent_model` and
  `agents.default_subagent_reasoning_effort`." **Codex therefore now
  has a global subagent-model default.** Key existence `[MEDIUM]`
  verified by execution; **honored at spawn: `low-confidence`** — not
  tested, and it may apply only under multi-agent V2
  (`multi_agent_v2` is `stable false`, i.e. opt-in, in `codex features
  list` 0.162.1). 0.163.0 adds an opt-in "subagent model context
  defaults" feature (#52659) — `low-confidence`.
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents),
  `codex exec --strict-config` probes 2026-11-08)
- **Subagents on by default:** `agents.enabled` (boolean; binary types
  it — `"x"` → `expected a boolean`) defaults to `true` per docs:
  "Current Codex releases enable subagent workflows by default."
  `multi_agent` is `stable true` in `features list` 0.162.1. `[MEDIUM]`
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))
- **Parallel spawn:** YES. The docs' key is now
  `agents.max_concurrent_threads_per_session`; `agents.max_threads` is
  documented as a **legacy alias** ("Existing configurations can keep
  using `agents.max_threads` as a legacy alias"). Both are typed `usize`
  in the binary (`"six"`/`"x"` → `expected usize`). **Default value is
  no longer stated anywhere:** docs say "When you leave [it] unset,
  Codex chooses the default." The previously recorded default 6 is
  unsourced as of this walk. `[MEDIUM]` (was `[STABLE]`; key renamed)
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents),
  `--strict-config` probes 2026-11-08)
- **Nesting cap:** `agents.max_depth` still exists (typed `i32`;
  `"one"` → `expected i32`, binary 0.162.1) and limits how deep
  children may spawn. The previously recorded **default 1 is no longer
  stated on the docs page** — unsourced as of this walk. Raising it
  multiplies token/latency cost. `[MEDIUM]` (was `[STABLE]`)
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))
  **Cross-vendor head-to-head — UPDATED 2026-11-08.** The Codex column
  is re-verified at binary 0.162.1. The Claude model rows follow the
  2026-11-08 `claude-code` walk (supervisor ruling); the Claude depth
  and concurrency figures are quoted from the `claude-code` walk, which
  re-verified them at 2.1.319 — [`claude-code.md`](claude-code.md) §3 is
  canonical for that column.

  | Axis | Codex CLI 0.162.1 | Claude Code (see `claude-code.md` §3) |
  |---|---|---|
  | Default nesting depth | **unstated** (`agents.max_depth` exists; docs no longer give 1) | **3** (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, 2.1.319) |
  | Depth configurable? | Yes | Yes |
  | Concurrency cap | **unstated** (`agents.max_concurrent_threads_per_session`; `max_threads` legacy alias) | **20** (`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`, 2.1.319) |
  | Per-session total cap | none documented | **none** (200 cap removed v2.1.224) |
  | Delegation default | **explicit request** (proactive only at the Ultra intelligence level) | **description-match auto-routing** |
  | Per-agent model pinning | `model` in agent TOML — schema-confirmed by execution; honored-at-spawn `low-confidence` | `model:` frontmatter, defaults `inherit`; overridable per invocation |
  | Global subagent-model default | **`agents.default_subagent_model`** (binary-typed key; honored-at-spawn `low-confidence`) | **`CLAUDE_CODE_SUBAGENT_MODEL`** (ranks below frontmatter since 2.1.251) |
  | Hard enforcement | none found | **`CLAUDE_CODE_SUBAGENT_MODEL_FORCE`** (2.1.257) |

  **The load-bearing difference is still delegation posture.** Codex
  spawns subagents only on an explicit request at most intelligence
  levels, so an unpinned expensive model has a bounded blast radius.
  Claude Code auto-routes by description match *and* inherits the
  session model unless pinned. ⚠️ **Scope of this conclusion:** the
  evidence supports *greater automatic fan-out exposure under
  documented defaults*. It does not establish an absolute cost ranking,
  which also depends on per-model prices, workload shape, real routing
  behavior, and local configuration. No delegate-and-observe test has
  succeeded on Codex.
  **Both vendors now offer a global subagent-model default**, which
  retires the prior "neither vendor" statement. The evidence is
  asymmetric: Claude Code also ships a hard-enforcement switch, while on
  Codex both the global key and the per-agent `model` are only
  **schema-confirmed**, and whether a spawn honors them is unverified.
  Do not treat the Codex pin as an established capability.
  See [`claude-code.md`](claude-code.md) §3 / §10.
- **Delegation posture — explicit request by default; "Ultra" is an
  intelligence level, not a plan.** The docs no longer use the
  "disabled / explicit-request-only / proactive" labels; they say "At
  most intelligence levels, ask for delegation explicitly" and "With
  Ultra, ChatGPT can proactively delegate work when parallel agents
  would materially improve speed or quality … Ultra is available only
  to eligible accounts and supported models." **Correction:** the prior
  walk's "ChatGPT Ultra" exception read as a subscription plan; Ultra
  is the `ultra` reasoning/intelligence level (listed in
  `supported_reasoning_levels` in `codex debug models`, binary 0.162.1;
  see §9). `features list` 0.162.1 shows `multi_agent_mode` and
  `collaboration_modes` as `removed`. Description-match auto-routing
  (Claude Code's default) is still NOT a Codex subagent behavior —
  contrast skills (§2), which DO auto-route. `[MEDIUM]`
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))
- **Error propagation (0.142.0+):** parent agents receive terminal
  subagent errors instead of seeing failed work as an empty successful
  completion; 0.160.0 also delivers subagent configuration/preparation
  failures to the parent. Nested subagent token usage counts toward
  root goal budgets (0.151.0). `[MEDIUM]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))
- **Job timeout:** `agents.job_max_runtime_seconds` (typed `u64`; `"x"`
  → `expected u64`, binary 0.162.1) caps per-worker runtime. The
  previously recorded **default 1800 s is not stated on the current
  docs page** — unsourced as of this walk. `[MEDIUM]`
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))
- **Display + batch extras:** `nickname_candidates` (inline-table field,
  binary-typed as a sequence) gives spawned agents readable display
  names. `spawn_agents_on_csv` / `report_agent_job_result` **no longer
  appear on the subagents docs page** — not re-verified this walk; do
  not rely on them without a fresh check. `[MEDIUM]` `low-confidence`
  ([learn.chatgpt.com/docs/agent-configuration/subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))
- **Subagent reasoning effort from the model catalog (`low-confidence`).**
  The bundled catalog (`codex debug models`, binary 0.162.1) carries
  `multi_agent_reasoning_effort: "xhigh"` on `gpt-6-astra` and
  `gpt-6.1-sol` (the live catalog also on `gpt-6.1-terra`). The field's semantics are undocumented, but it
  suggests subagents spawned under those models default to `xhigh`, a
  cost-relevant default. Unverified at spawn. `[VOLATILE]`
- **Cross-vendor commentary:** the explicit-request model applies to
  **subagents**, not skills. Skills (§2) DO auto-route by description
  match on Codex, so `/build-feature` and `/refresh-vendor` are
  auto-invocable from `.agents/skills/` here just as on Claude Code.
  Codex subagents, by contrast, need an explicit `/agent <name>` or a
  prompt that names them; the one exception is proactive delegation at
  the Ultra intelligence level. Don't conflate the two surfaces.
  `[STABLE]`

---

## 4. Hooks

- **Enabled by default — feature flag no longer required.** The
  canonical feature key is `hooks` (`codex features list` 0.162.1 shows
  `hooks stable true`). `codex_hooks` survives as a deprecated alias:
  it is still accepted under `--strict-config` at 0.162.1, and the docs
  say "Use `hooks`, not `codex_hooks`, which still works only as a
  deprecated alias." Disable explicitly with `[features] hooks = false`
  in `config.toml`. `[MEDIUM]`
  (binary `codex features list` + `--strict-config` 0.162.1,
  [learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks))
- **Event names — 12 recognised by binary 0.162.1 (was 10); 14 per
  docs.** The 12 recognised events are `SessionStart`, **`SessionEnd`**
  (release rust-v0.145.0 #33895), `SubagentStart`, `PreToolUse`,
  `PermissionRequest`, `PostToolUse`, `PreCompact`, `PostCompact`,
  `UserPromptSubmit`, `SubagentStop`, `Stop`, and **`Interrupt`**
  (rust-v0.150.0 #40511, fires when an active top-level turn is
  interrupted). Probe method: a `hooks.json` carrying a bogus handler
  type is rejected only under an event name the binary recognises,
  while under `ZzzBogusEvent` it is silently ignored (scratch
  `CODEX_HOME`, 2026-11-08). Unknown event names are therefore
  **silently ignored, not errors** — a misspelled event never fires.
  The docs also list **`PreModelRequest`** and **`PostModelRequest`**,
  which are NOT recognised by 0.162.1. They arrive with rust-v0.164.0
  #55144 ("observation-only model request lifecycle hooks") and are
  `low-confidence` until a binary ≥0.164 is probed. `PreToolUse` /
  `PermissionRequest` carry permission-decision schemas that can
  rewrite tool inputs. `[MEDIUM]`
  ([learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks),
  hooks.json probes 2026-11-08)
- **Configuration locations** (four canonical):
  `~/.codex/hooks.json`, `~/.codex/config.toml` (`[hooks]` table),
  `<repo>/.codex/hooks.json`, `<repo>/.codex/config.toml`. Also enabled
  plugins (`hooks/hooks.json` or a `hooks` entry in
  `.codex-plugin/plugin.json`) and managed `requirements.toml`; all
  sources merge. **Project hooks load only when the project's `.codex/`
  layer is trusted.** `[STABLE]`
  ([learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks))
- **Handler types — `command` AND `mcp_tool` execute (correction).**
  The binary's handler enum is `command`, `mcp_tool`, `prompt`, `agent`
  (from the parse error `unknown variant … expected one of …`, binary
  0.162.1). `mcp_tool` "calls a tool on an already-connected MCP
  server" (rust-v0.148.0 #38705, enabled in sessions rust-v0.149.0
  #39296). `command` hooks can run asynchronously with `async: true`
  (rust-v0.148.0 #37533). Per the docs, `prompt` and `agent` are still
  "parsed but skipped". Configurations use matcher groups (an event + a
  matcher predicate + one or more handlers). Command handlers receive
  the event payload on stdin and run with the session working
  directory as context. `[MEDIUM]`
  ([learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks))
- **Hook trust model (0.141.0) — ⚠️ security-relevant for automation.**
  Enabled non-managed hooks require **persisted hook trust** before
  they run. Trust is tied to each hook's **hash**, so a changed hook is
  skipped until it is re-reviewed; `/hooks` reviews them. Managed hooks
  are trusted by policy. `codex exec` (and the global CLI) expose
  `--dangerously-bypass-hook-trust` (still in `codex exec --help`
  0.162.1) to run enabled hooks without persisted trust for a single
  invocation. **Supervised-use-only:** this bypass runs unvetted hook
  code. Use it only in automation that already vets hook sources, never
  as a default in scripts. `[MEDIUM]`
  ([learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks),
  [github.com/openai/codex/releases](https://github.com/openai/codex/releases))
- **Plugin-bundled + managed hooks:** plugins can ship hooks via their
  manifest or a default `hooks/hooks.json`. The env vars `PLUGIN_ROOT`
  and `PLUGIN_DATA` are available, plus `CLAUDE_PLUGIN_ROOT` /
  `CLAUDE_PLUGIN_DATA` for compatibility. Enterprises enforce managed
  hooks via `[hooks]` in `requirements.toml` (`managed_dir`,
  `windows_managed_dir`). `allow_managed_hooks_only = true` ignores
  user, project, session and plugin hooks. The dedicated `plugin_hooks`
  feature flag stays **removed** (`features list` 0.162.1); plugin
  lifecycle hooks fold into core `hooks`. `[MEDIUM]`
  ([learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks))
- **Vendor coupling:** event names overlap conceptually with Claude Code's
  set (`SessionStart`, `SessionEnd`, `PreToolUse`, `PostToolUse`,
  `UserPromptSubmit`, `Stop`) but are NOT a 1:1 superset. Claude Code
  exposes 33 events (quoted from
  [`claude-code.md`](claude-code.md) §4, v2.1.319 — that file is
  authoritative for the Claude count); Codex has 12 at binary 0.162.1
  (14 per docs, `low-confidence` for 0.164+). Cross-vendor
  parity is per-event translation, not a shared set. `[STABLE]`
- **Repo posture:** hooks stay Claude-only by default. Codex hooks
  portabilized only when the hook prevents a destructive non-code
  action (rare). `[STABLE]`

---

## 5. Auth

- **Default mode:** "Sign in with ChatGPT", an OAuth flow against a paid
  ChatGPT subscription (Plus / Pro / Business / Enterprise / Edu) or
  the Free tier. The auth page no longer lists plans and defers to the
  pricing page's "Feature availability" (§7). With no flags, `codex`
  opens a browser for OAuth on first run. `[STABLE]`
  ([learn.chatgpt.com/docs/auth](https://learn.chatgpt.com/docs/auth))
- **⚠️ Credential storage — FOUR modes via `cli_auth_credentials_store`
  (was three).** The binary enum is `file`, `keyring`, `auto`,
  `ephemeral`. A bogus value is rejected with `unknown variant …
  expected one of …` (`--strict-config` probe, binary 0.162.1).
  - `"file"`: plaintext `auth.json` under `CODEX_HOME`. Treat it as a
    password; access tokens live here.
  - `"keyring"`: OS-native credential store (macOS Keychain, Windows
    Credential Manager, Linux Secret Service). Per the docs it "fails if
    it is unavailable".
  - `"auto"`: OS store first, falls back to `auth.json`.
  - `"ephemeral"` (**new**): in-memory, for the life of the process
    only.

  **The default is no longer stated on the docs page.** The prior
  "plaintext `file` by default" claim was docs-sourced and is now
  **unverified**; checking it needs an authenticated login, which this
  walk did not run. Release notes add that auth guidance "now accounts
  for keyring storage instead of implying credentials always reside in
  `auth.json`" (#49361). `features list` 0.162.1 shows
  `secret_auth_storage` as `stable false`. Until re-verified, assume
  plaintext is possible and set `keyring` explicitly on shared machines
  (§10). `[MEDIUM]` (was `[STABLE]`) `low-confidence` on the default
  ([learn.chatgpt.com/docs/auth](https://learn.chatgpt.com/docs/auth))
- **Managed Bedrock + encrypted OAuth storage (0.140.0):** managed
  Amazon Bedrock API-key authentication plus **encrypted local storage
  for CLI and MCP OAuth credentials**. Later additions:
  - Bedrock Runtime as a built-in provider with AWS profiles (0.148.0)
    and credentials from configured commands (0.155.0).
  - Workload-identity token exchange (0.147.0–0.148.0). Per the docs,
    when workload identity is selected "Codex rejects `codex login` and
    `codex logout`".
  - A built-in **Google Cloud Vertex AI** provider,
    `model_provider = "gcp"` (rust-v0.165.0 #56265), `low-confidence`.
  - Bedrock setup wizard on by default (rust-v0.164.0),
    `low-confidence`.

  `[MEDIUM]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases),
  [learn.chatgpt.com/docs/auth](https://learn.chatgpt.com/docs/auth))
- **API key alternate:** `OPENAI_API_KEY` env var or
  `codex login --with-api-key`, which reads the key from stdin, e.g.
  `printenv OPENAI_API_KEY | codex login --with-api-key`. The older
  `--api-key` spelling is gone. Pay-per-token via the OpenAI API;
  bypasses ChatGPT subscription limits. `[STABLE]`
  (binary `codex login --help` 0.162.1)
- **Access-token login (new):** `codex login --with-access-token` reads
  an access token from stdin, e.g.
  `printenv CODEX_ACCESS_TOKEN | codex login --with-access-token`.
  `[MEDIUM]` (binary `codex login --help` 0.162.1,
  [learn.chatgpt.com/docs/auth](https://learn.chatgpt.com/docs/auth))
- **Device-code flow:** `codex login --device-auth` for headless / SSH
  environments where a browser is unavailable (the docs label it
  "beta"). Renamed from `--device`. `[STABLE]`
  (binary `codex login --help` 0.162.1,
  [learn.chatgpt.com/docs/auth](https://learn.chatgpt.com/docs/auth))
- **Agent identity login REMOVED from the CLI:**
  `codex login --with-agent-identity` is **rejected by the parser** at
  0.162.1 (`error: unexpected argument '--with-agent-identity' found`,
  verified by execution 2026-11-08 — so it is removed, not merely
  hidden from help like the `--yolo` aliases) and is not on the auth
  docs page. Agent identity still appears as plumbing in release notes
  (#34631, #37356); whether any other entry point exposes it was not
  checked. `[VOLATILE]` (execution + `codex login --help` 0.162.1)
- **Status check:** `codex login status` prints the active `auth_mode`
  and exits 0 when authenticated. Useful as a CI gate. `[STABLE]`
  (binary `codex login --help` 0.162.1 lists `status`)
- **Cross-vendor parity:** Claude Code defaults to Anthropic OAuth.
  Per-vendor subscription posture lives in each vendor's knowledge file.
  `[STABLE]`

---

## 6. Rate limits — `[VOLATILE]`

**Re-verify before relying.** As of 2026-11-08 the pricing page carries
an active promotion: **"GPT-5.6 Sol's promotional pricing is available
at least through November 21, 2026"** (learn.chatgpt.com/docs/pricing).
The API-billing promo end date is a different surface and lives in
[`model-capabilities.md`](../model-capabilities.md) (OpenAI section);
the two dates differ and are not reconciled here — the Codex page's
"at least through" phrasing is not strictly inconsistent with it. Both are docs-only, read via a summarizing fetcher. The
earlier Pro $100 2× boost expired 2026-05-31.

- **Two windows, shared allowance:** Codex enforces a **5-hour rolling
  window** plus **weekly limits** ("Weekly limits may also apply"; no
  figures are published). Local messages and cloud tasks draw from a
  combined allowance. **Pro is now different:** "Pro plans currently
  have no five-hour limit." Plus and Team get an earlier warning once
  less than half of the 5h allowance remains (rust-v0.152.0 /
  0.153.0). `[VOLATILE]` docs-only (help.openai.com returned 403 this
  walk)
  ([learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing),
  [help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan](https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan))
- **April 9, 2026 restructure (historical):** OpenAI aligned Codex limits
  with API-token usage instead of per-message pricing for Plus, Pro, and
  Business plans. Treat older blog posts citing message-count-only
  limits as stale. `[VOLATILE]`
  ([community.openai.com/t/understanding-the-new-codex-limit-system-after-the-april-9-update/1378768](https://community.openai.com/t/understanding-the-new-codex-limit-system-after-the-april-9-update/1378768))
- **Official sample 5h ranges, now PER MODEL (pricing page,
  2026-11-08).** Local messages per 5 hours, Plus and Standard
  Business:

  | Model | Messages / 5h |
  |---|---|
  | GPT-6 Astra | 5–45 |
  | GPT-6.1 Sol | 15–160 |
  | GPT-6.1 Terra | 35–285 |
  | GPT-6 Sol | 15–150 |
  | GPT-6 Luna | 350–3,000 |

  This replaces the 2026-07-18 per-tier envelopes (Plus ~15–90 up to
  ~60–350; Pro 5× and Pro 20× ranges), which are no longer on the page.
  Pro has no 5h limit (above). These are sample ranges, not a contract.
  `[VOLATILE]` docs-only
  ([learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing))
- **Model lineup (for Codex behavior only; SSOT is
  [`model-capabilities.md`](../model-capabilities.md)).** _Declared
  quote: the slugs, retirement date and default model in this bullet
  and in §9 are quoted from `model-capabilities.md` as of 2026-11-08;
  if they disagree, that file wins. The per-model 5h ranges and credit
  rates in this section are Codex-plan facts and live here._
  - **Two catalogs.** With the operator's `CODEX_HOME`, `codex debug
    models` reads the **live, server-refreshed** catalog
    (`~/.codex/models_cache.json`; 2026-11-08 refresh by a 0.164.0
    client), which lists `gpt-6.1-sol`, `gpt-6-astra`, **`gpt-6.1-terra`**,
    `gpt-6-sol`, `gpt-6-luna`, `gpt-5.6-sol/terra/luna`, plus hidden
    `gpt-reserve` and `codex-auto-review` (no `gpt-5.5`, no daybreak
    slugs). The live catalog is account- and time-dependent. An
    unconfigured scratch `CODEX_HOME` shows the **bundled** offline
    catalog (binary 0.162.1, 11 slugs), which lists `gpt-6-astra`, `gpt-6.1-sol`, `gpt-6-sol`, `gpt-6-luna`,
    `gpt-5.6-sol/terra/luna` ("Older…") and `gpt-5.5` ("Legacy coding
    model"). Hidden slugs are `gpt-daybreak-blue/red-latest` (cyber,
    gated) and `codex-auto-review`.
  - **GPT-5.4 / GPT-5.4-mini are absent** from the catalog and the Codex
    pricing page, and GPT-5.3-Codex-Spark is not on the pricing page.
  - GPT-5.5 retired from Codex with ChatGPT sign-in on 2026-10-14 (per
    the pricing page).
  - `gpt-6.1-terra` is in the live catalog the 0.162.1 CLI already
    reads (verified by execution 2026-11-08); release notes add it to
    the *bundled* catalog in rust-v0.165.0/0.166.0 (`low-confidence`).
  - The chosen model shifts the 5h range above. The default model is
    covered in §9.

  `[VOLATILE]`
- **Usage visibility (0.140.0+):** `/usage` shows token activity and
  became an analytics dashboard (account usage, token totals,
  plugin/skill activity) in 0.156.0. Earned usage-limit **reset
  credits** are redeemable via `/usage`. Rate-limit banners offer
  check-usage / manage-credits / reset / manage-plan actions (0.152.0).
  Configurable rollout token budgets warn and abort turns on exhaustion.
  `[MEDIUM]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))
- **Credits (pricing page, 2026-11-08).** On hitting limits, users wait
  for reset or **buy credits**, priced per 1M tokens at Standard speed:

  | Model | Input | Cached input | Output |
  |---|---|---|---|
  | GPT-6 Astra | 250 | 25 | 1,250 |
  | GPT-6.1 Sol | 50 | 2.5 | 250 |
  | GPT-6.1 Terra | 25 | 1.25 | 125 |
  | GPT-6 Sol | 50 | 5 | 250 |
  | GPT-6 Luna | 2.5 | 0.25 | 12.5 |
  | GPT-5.6 Sol | 100 | 10 | 500 |
  | GPT-5.6 Terra | 50 | 5 | 300 |
  | GPT-5.6 Luna | 5 | 0.5 | 30 |

  Fast mode costs 2× and Ultrafast 6× for purchased credits and
  Enterprise pay-as-you-go. The prior "GPT-5.5 input ≈125 credits"
  example is no longer on the page. `[VOLATILE]` docs-only
  ([learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing);
  [help.openai.com/en/articles/20001106-codex-rate-card](https://help.openai.com/en/articles/20001106-codex-rate-card)
  returned 403 this walk)
- **Recovery posture:** on rate-limit hit, abort and re-run via
  `cross-vendor-review.sh --to <other-vendor>`. No automatic API-key
  fallback. `[STABLE]`

---

## 7. Cost

All paid ChatGPT plans include the Codex CLI. The Free tier also gets
limited Codex access (Free users get GPT-6 Luna at Standard speed in
the desktop app, subject to rollout). `[STABLE]`
([chatgpt.com/pricing](https://chatgpt.com/pricing/),
[learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing))

> **Pricing-page rendering (2026-11-08):** the page reads Pro "From
> $100/month" and "Plans at $100, $200, or $500 USD per month". This
> resolves the 2026-07-18 "From $100" ambiguity and adds a **$500**
> Pro tier. The fetch was model-summarized, so prefer a browser check
> for exact Pro-tier pricing.

| Tier | Price | Codex CLI | Notes |
|---|---|---|---|
| **Free** | $0/mo | Yes (limited) | Ad-supported in some regions |
| **Go** | $8/mo | Yes | Ad-supported (US) |
| **Plus** | $20/mo | Yes | 5h (per-model, §6) + weekly limits |
| **Pro** | $100 / $200 / $500 per mo | Yes | **No 5h limit** currently (§6); weekly limits may apply |
| **Business** | $20/user/mo annual (2+ users); **$25 monthly** | Yes | Standard Business shares the Plus 5h table (§6). Release notes relabel "Business Pro Lite" as **"Business Premium"** (rust-v0.150.0 #40301); that tier is not on the pricing page |
| **Enterprise / Edu** | contact sales | Yes | Custom limits |

`[VOLATILE]` docs-only. No "Ultra" plan exists: "Ultra" is a reasoning
level (§3, §9).

- **API alt:** pay-per-token via the OpenAI API (GPT-6 / GPT-6.1 /
  GPT-5.6 / GPT-5.5 / GPT-5.4 families). Bypasses subscription rate
  limits at standard token cost. Per-model rates live in
  [`model-capabilities.md`](../model-capabilities.md) (SSOT). `[STABLE]`
  ([developers.openai.com/api/docs/pricing](https://developers.openai.com/api/docs/pricing);
  openai.com/api/pricing returns 403 to scripted fetches)
- **Per-call cost in headless mode:** `codex exec --json` emits JSONL
  events including model name and token usage; budget caps live in
  `config.toml` (`[exec]` section). No equivalent of Claude Code's
  `--max-budget-usd` flag is documented. `/status` shows estimated
  thread credits/cost for eligible workspaces (0.148.0). `[MEDIUM]`
- **Credit top-ups:** on hitting included limits, credits are
  purchasable at token-based rates (§6 table). Active promo: GPT-5.6
  Sol promotional pricing; both end dates are recorded in §6.
  `[VOLATILE]`
  ([learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing))

---

## 8. MCP (client only since 0.154.0)

- **As client:** stable. Two transports: `stdio` (servers run as a
  local process started by a command) and **Streamable HTTP** (servers
  reachable at a URL). Configured via `[mcp_servers]` blocks in
  `config.toml` or via `codex mcp add`. `codex mcp` subcommands at
  0.162.1 are `list`, `get`, `add`, `remove`, `login`, `logout`.
  `[STABLE]` (binary `codex mcp --help` 0.162.1,
  [learn.chatgpt.com/docs/extend/mcp?surface=cli](https://learn.chatgpt.com/docs/extend/mcp?surface=cli))
- **OAuth 2.0 supported:** `codex mcp login <server-name>` runs the
  OAuth flow for HTTP servers that require auth (`--no-browser` for
  terminals without one; `/mcp login <name>` in-session since 0.161.0).
  Callback port and URL are configurable via `mcp_oauth_callback_port`
  / `mcp_oauth_callback_url` (both accepted by `--strict-config`
  0.162.1), with a per-server override
  `mcp_servers.<name>.oauth.callback_port`. Confidential clients use
  `codex mcp add --oauth-client-secret` (0.158.0); the secret is saved
  in `config.toml`. `[STABLE]`
  ([learn.chatgpt.com/docs/extend/mcp?surface=cli](https://learn.chatgpt.com/docs/extend/mcp?surface=cli))
- **⚠️ As server: REMOVED (0.154.0).** `codex mcp-server` is gone. The
  release notes say "The deprecated `codex mcp-server` entry point is
  no longer available" (rust-v0.154.0 #42993). The subcommand is absent
  from `codex --help` 0.162.1, and `codex mcp-server --help` falls
  through to the top-level help. The docs say the command and the
  standalone `codex-mcp-server` binary "have been removed" and point to
  the Codex **app server** (`codex app-server`, experimental), which is
  a different protocol. This reverses the 2026-06-10 → 2026-08-25
  "FIRST-PARTY server mode" claim. `[MEDIUM]` (binary `codex --help`
  0.162.1, release rust-v0.154.0,
  [learn.chatgpt.com/docs/developer-commands?surface=cli](https://learn.chatgpt.com/docs/developer-commands?surface=cli))
- **Cross-vendor posture:** cross-vendor MCP servers remain deferred,
  and shell invocation via [`cross-vendor-review.sh`](../../../scripts/)
  is still the answer. The revisit trigger ("any vendor ships
  first-party MCP server") fired 2026-06-10 on `codex mcp-server`; that
  instance **no longer exists** as of 0.154.0. Of the three harness
  vendors, only Claude Code ships one (`claude mcp serve`); neither
  Codex nor Antigravity does. `[STABLE]`
- **Remote stdio executor:** `[mcp_servers.<name>]` supports a remote
  executor for running stdio servers off-box. This is distinct from
  server mode. `[MEDIUM]`
- **Recent MCP behavior:**
  - Tool search became the default in 0.143.0. The `tool_search` /
    `search_tool` feature flags now read `removed` in `features list`
    0.162.1; I did not verify whether that means always-on.
  - MCP tools can request interactive authentication without an opt-in
    (0.144.0).
  - Opt-in MCP 2026-07-28 protocol (0.147.0).
  - Per-tool `output_token_limit` (0.152.0), and server names may
    contain `:` `@` `/` `.` (0.152.0).
  - A configurable discovery grace period for optional servers
    (0.151.0).
  - Touch ID verification for MCP requests on supported Macs (0.155.0).

  `[MEDIUM]`
  ([github.com/openai/codex/releases](https://github.com/openai/codex/releases))

---

## 9. Headless invocation

- **Entry point:** `codex exec "<prompt>"` (alias `codex e`). Runs the
  agent loop without opening the TUI and finishes without human
  interaction. Used by the SDK and by scripts. Exec subcommands at
  0.162.1 are `resume`, `fork` (0.148.0) and `review`. Docs:
  "`codex exec` runs in a read-only sandbox" by default. The exec
  banner at 0.162.1 shows `approval: never`, `sandbox: read-only`.
  `[STABLE]` (binary `codex exec --help` 0.162.1,
  [learn.chatgpt.com/docs/non-interactive-mode](https://learn.chatgpt.com/docs/non-interactive-mode))
- **Sandbox flag — three values:** `--sandbox read-only`,
  `--sandbox workspace-write`, `--sandbox danger-full-access`. `[STABLE]`
  (binary `codex exec --help` 0.162.1,
  [learn.chatgpt.com/docs/developer-commands?surface=cli](https://learn.chatgpt.com/docs/developer-commands?surface=cli))
- **Approval flag — TWO values now (was four); interactive `codex`
  only.** `--ask-for-approval` / `-a` accepts only `on-request` and
  `never`. `untrusted` and `on-failure` are both rejected with `invalid
  value … for '--ask-for-approval'` (execution, binary 0.162.1).
  `untrusted` was retired in rust-v0.149.0 (#39630); the docs list only
  `on-request` and `never`. `codex exec` still accepts no approval
  flag (removed in 0.128.0). `--full-auto` is gone from both `codex`
  and `codex exec` ("unexpected argument", 0.162.1); the docs say "no
  longer supported; use `--sandbox workspace-write`". `[STABLE]`
  ([learn.chatgpt.com/docs/developer-commands?surface=cli](https://learn.chatgpt.com/docs/developer-commands?surface=cli))
- **Auto-reviewed approvals:** `--approve-for-me` (0.147.0; both
  `codex` and `codex exec`) routes approval requests through automatic
  review using the workspace-write sandbox. It **conflicts with
  `--sandbox`**: clap reports "`--approve-for-me` cannot be used with
  `--sandbox`" (0.162.1). `[MEDIUM]` (binary `codex exec --help`
  0.162.1)
- **⚠️ Hidden alias flags — security-relevant for script audits.** Two
  aliases parse but **do not appear in `--help`**:
  - **`--yolo`** = `--dangerously-bypass-approvals-and-sandbox`. Clap
    reports the canonical name: `codex --yolo --approve-for-me` →
    "the argument '--dangerously-bypass-approvals-and-sandbox' cannot
    be used with '--approve-for-me'".
  - **`--not-so-yolo`** = `--approve-for-me`.

  Both are accepted by `codex` and `codex exec` (execution, binary
  0.162.1; docs name `--not-so-yolo` and reference `--yolo`). **A grep
  audit for `dangerously` misses `--yolo`.** Any script or CI scan for
  unsafe Codex invocations must match `--yolo` too. `[MEDIUM]`
- **Output-last-message flag:** `--output-last-message <path>` (short
  `-o <path>`). Writes the assistant's final message to a file and
  leaves stdout unchanged. The cross-vendor reviewer rubric reads this
  file. `[STABLE]` (binary `codex exec --help` 0.162.1,
  [learn.chatgpt.com/docs/non-interactive-mode](https://learn.chatgpt.com/docs/non-interactive-mode))
- **JSONL stream:** `--json` switches stdout to JSON Lines, one event
  per line, including model name, tool calls, token usage and errors.
  Pipe to `jq` for parsing. `[STABLE]`
- **Repo skip:** `--skip-git-repo-check` allows running outside a git
  repo. Only set it when the environment is known safe. The error
  without it now reads "Not inside a **trusted** directory and
  --skip-git-repo-check was not specified" (0.162.1; see §1
  trust-gating). `[STABLE]`
- **Structured output:** `--output-schema <FILE>` constrains the model's
  final response to a JSON Schema. Candidate replacement for the
  rubric's string-matching contract in `cross-vendor-review.sh`
  (evaluation queued, not adopted). `[MEDIUM]`
  (binary `codex exec --help` 0.162.1)
- **Other exec flags (binary 0.162.1):**
  - Unchanged since 0.139.0:
    - `--ephemeral`: no session files persisted.
    - `--ignore-user-config`: skips `$CODEX_HOME/config.toml`; auth
      still uses `CODEX_HOME`.
    - `--ignore-rules`: skips execpolicy `.rules` files.
    - `--enable <FEATURE>` / `--disable <FEATURE>`.
    - `-p/--profile <name>`: layers `$CODEX_HOME/<name>.config.toml`.
    - `--add-dir <DIR>`.
    - `-C/--cd <DIR>`.
    - `-i/--image <FILE>`.
    - `-m/--model <MODEL>`.
    - `--oss` / `--local-provider <lmstudio|ollama>`.
    - `--strict-config`.
    - `--color <always|never|auto>`.
  - **New since last walk:**
    - `--worktree`: runs in a new managed Git worktree (0.154.0;
      worktrees default-on in 0.156.0).
    - `--thread-source <SOURCE>`.
    - `--cyber-access-program <standard|daybreak_blue|daybreak_red>`:
      per-turn Cyber access program, OpenAI provider only (0.161.0).
      Daybreak becomes default-enabled for eligible accounts in
      rust-v0.163.0, `low-confidence`.
  - Top-level only:
    - `--remote <ADDR>` and `--remote-auth-token-env`: connect the TUI
      to a remote app server.
    - `--no-daemon` (0.156.0).
    - `--search`: live web search.

  `[MEDIUM]` (binary `codex --help` / `codex exec --help` 0.162.1)
- **⚠️ `codex exec` READS STDIN even when the prompt is an argument —
  still true at 0.162.1, now documented.** The help text says: "If stdin
  is piped and a prompt is also provided, stdin is appended as a
  `<stdin>` block". The docs say Codex "treats the prompt as the
  instruction and the piped content as additional context". The run
  prints `Reading additional input from stdin...` and **blocks until
  EOF**. Re-verified by execution 2026-11-08: `sleep 10 | codex exec
  "hi"` printed only that line and stayed blocked until a 6 s alarm;
  with `</dev/null` it proceeds immediately. It works when a human runs
  it in a terminal, and in CI, background jobs or piped contexts it
  **blocks for as long as stdin stays open** — indefinitely when the
  inherited stdin never reaches EOF — unless the caller closes stdin
  (`< /dev/null`).
  [`cross-vendor-review.sh`](../../../scripts/cross-vendor-review.sh)
  closes stdin on every vendor branch (fixed 2026-08-25). `[MEDIUM]`
  (execution + `codex exec --help` 0.162.1)
- **`--strict-config` is the config-schema discriminator.** It rejects
  unrecognised table-level keys (`unknown configuration field`), which
  makes it the right tool for verifying a config claim by execution
  rather than by page-fetch. Scope at 0.162.1:
  - It validates table-level keys and scalar types.
  - It does NOT validate fields inside inline `[agents.<name>]`
    tables beyond their few typed fields.
  - Standalone agent files are strictly deserialized, but failures
    there are **warnings**, not errors (§3).
  - It does NOT validate enum-like string values that are checked
    later. See the reasoning-effort bullet below.

  An accepted config with no auth proceeds to a 401 before any model
  call, so schema probes cost nothing. `[MEDIUM]` (execution, binary
  0.162.1)
- **Default model and reasoning effort (binary 0.162.1).**
  - **The bundled default model is `gpt-6.1-sol`.** The exec banner in
    a fresh, unconfigured `CODEX_HOME` shows `model: gpt-6.1-sol`;
    release rust-v0.159.1/0.161.0 say "GPT-6.1 Sol is now the default
    model". This follows a brief `gpt-6-astra` default in 0.153.4.
  - Catalog `supported_reasoning_levels` (`codex debug models`) are
    `low, medium, high, xhigh, max, ultra` on most current models.
    Luna variants and `codex-auto-review` top out at `max`; `gpt-5.5`
    tops out at `xhigh`. **`ultra` is new**: SDK in 0.149.0, Bedrock
    in 0.161.0. `none` and `minimal` are listed for no model.
  - **⚠️ An invalid effort value is NOT rejected at config load:**
    `-c model_reasoning_effort="bogus"` passes `--strict-config` and the
    banner echoes `reasoning effort: bogus`. Only the type is checked
    (`=1` → `expected a string`). Config acceptance therefore proves
    nothing about an effort value's validity; check it against the
    catalog. The dispatcher's `medium` is valid because every catalog
    model lists it.
  - In a fresh home the banner shows `reasoning effort: none` while the
    catalog's `default_reasoning_level` for `gpt-6.1-sol` is `low`.
    The effective default is unverified.
  - Model inventory and rates belong to
    [`model-capabilities.md`](../model-capabilities.md) (SSOT).

  `[VOLATILE]` (execution + `codex debug models` 0.162.1)
- **Global reasoning effort leaks into scripted calls.** `codex exec`
  inherits `model_reasoning_effort` from `~/.codex/config.toml`
  (`xhigh` on the reference machine), with no per-invocation default.
  A 553-line diff review at `xhigh` exceeded 9 minutes. Scripted
  callers that need predictable latency should pass
  `-c model_reasoning_effort="medium"` explicitly. The dispatcher does
  (fixed 2026-08-25). `[MEDIUM]` (empirical, binary 0.144.5;
  re-confirmed 0.162.1)
- **⚠️ Global MODEL and NOTIFY also leak into scripted calls —
  dispatcher FIXED 2026-11-08.** `codex exec` with no `-m` inherits the
  operator's global `model`: on the reference machine **`gpt-6-astra`**,
  the frontier tier, at 250 input credits per 1M tokens versus 50 for
  `gpt-6.1-sol` (§6). It also runs the operator's turn-ended `notify`
  hook — on the reference machine a Computer Use client that raised a
  macOS Automation prompt mid-review. The dispatcher now passes
  `-m "$REVIEW_MODEL"` from `--tier` (default `workhorse` =
  `gpt-6.1-sol`, per [`model-capabilities.md`](../model-capabilities.md)
  "Code review on Tier 1/Tier 2 → workhorse"; supervisor ruling
  2026-11-08: Sol, with the authoring model free to escalate) and
  `-c 'notify=[]'`. **Probed 2026-11-08 (0.162.1, real turns):** the
  exec banner shows `model: gpt-6.1-sol`; `-c notify=["touch",<sentinel>]`
  created the sentinel, so a `-c` value **replaces** the config hook, and
  `-c notify=[]` runs none. `notify` is typed as a sequence
  (`--strict-config` rejects `notify=1`). End-to-end dispatcher run
  2026-11-08 returned a formatted review with `Reviewer: codex /
  gpt-6.1-sol (tier: workhorse)`. `[MEDIUM]` (execution, binary 0.162.1)
- **Dangerous bypass flags — ⚠️ supervised-use-only.**
  - `--dangerously-bypass-approvals-and-sandbox` (hidden alias
    **`--yolo`**, above) skips ALL confirmation prompts and runs
    commands **without sandboxing**. Use it only in externally
    sandboxed environments.
  - `--dangerously-bypass-hook-trust` runs enabled hooks without
    persisted hook trust (§4).

  Both execute unvetted code; never wire them into scripts as a
  default. The cross-vendor review invocation below uses neither.
  `[MEDIUM]` (binary `codex exec --help` 0.162.1)
- **Session resumption / forking:** `codex exec resume <session-id>`
  (or `--last`) resumes a prior exec session. `codex exec fork` forks
  one (0.148.0). `[MEDIUM]` (binary `codex exec --help` 0.162.1)
- **Adjacent subcommands (binary 0.162.1):**
  - `codex review` runs a **non-interactive code review**, now with
    `--uncommitted`, `--base <BRANCH>`, `--commit <SHA>`, `--title`.
    It is a candidate alternative to `codex exec` for the cross-vendor
    dispatcher; evaluation is queued.
  - Still present: `features list|enable|disable`, `update`, `fork`,
    `sandbox`, `cloud` (experimental), `doctor` (`--network-only` in
    rust-v0.166.0, `low-confidence`), `apply`/`a`, `delete`,
    `archive`/`unarchive`, `completion`, `debug`, `app`, `app-server`,
    `exec-server`, `remote-control`.
  - **New since last walk:**
    - `codex agents`: agent command center over the shared local
      app-server daemon (0.149.0).
    - `codex queue`: message an existing session (0.149.0;
      `--resume` in rust-v0.166.0, `low-confidence`).
    - `codex resume`: top-level session resume.
    - `codex migrate-rollouts`.
    - `codex debug models`: renders the bundled model catalog as
      JSON, works offline.
    - `codex debug prompt-input`.
    - `codex app-server daemon|proxy|generate-ts|generate-json-schema`.
  - **Removed:** `codex mcp-server` (0.154.0, §8).

  `[MEDIUM]` (binary `codex --help` 0.162.1)
- **Cross-vendor review flag set** (consumed by
  `scripts/cross-vendor-review.sh` per
  [`cross-vendor-review.md`](../../protocols/cross-vendor-review.md)):

  ```
  codex exec \
    -m "$REVIEW_MODEL" \
    --sandbox read-only \
    -c 'model_reasoning_effort="medium"' \
    -c 'notify=[]' \
    --output-last-message <path> \
    "<prompt>" </dev/null
  ```

  **Every flag is verified at binary 0.162.1.** The exact set was run
  in a scratch git repo with no auth, and the banner showed `model:
  gpt-6.1-sol`, `sandbox: read-only`, `reasoning effort: medium` before
  the expected 401; a real end-to-end run then completed (model-leak
  bullet above). `$REVIEW_MODEL` is tier-resolved: `workhorse` =
  `gpt-6.1-sol`, `frontier` = `gpt-6-astra`, `light` = `gpt-6-luna`.
  `--ask-for-approval never` was used before codex
  0.128.0; the flag was removed upstream. The active vendor invocation
  in `scripts/cross-vendor-review.sh` is the source of truth.

  `--sandbox read-only` blocks all writes. `codex exec` 0.128.0+ runs
  non-interactive without an approval flag. `--output-last-message`
  captures the reviewer verdict for the script to parse. `</dev/null`
  prevents the stdin hang. `[STABLE]`

---

## 10. Gaps / Codex-CLI-down notes

- **Skills: first-party, NOT a gap anymore.** Codex auto-discovers and
  auto-invokes `.agents/skills/` (open Agent Skills standard); see §2.
  The repo's root `.agents/skills/` works on Codex out of the box. The
  prior "no first-party skills primitive" gap (carried through the
  2026-06-10 walk) is closed as of 2026-06-20. `[MEDIUM]`
  ([learn.chatgpt.com/docs/build-skills](https://learn.chatgpt.com/docs/build-skills))
- **Subagent caps: keys exist, defaults unstated.** `agents.max_depth`,
  `agents.max_concurrent_threads_per_session` (legacy alias
  `max_threads`) and `agents.job_max_runtime_seconds` are typed keys at
  binary 0.162.1. The docs no longer state their defaults (previously
  1 / 6 / 1800), so treat those numbers as unsourced. The cross-vendor
  head-to-head is **updated in §3** (2026-11-08). Headline: the
  meaningful asymmetry is still **delegation posture** (Codex
  explicit-request by default vs Claude description-match
  auto-routing), and **both vendors now offer a global subagent-model
  default**. Only Claude Code's is enforceable today; Codex's is
  schema-confirmed, with honored-at-spawn `low-confidence`. `[MEDIUM]`
- **Hooks default-on since ~0.13x** (canonical flag key `hooks`,
  deprecated alias `codex_hooks`). The old "flag required, silent
  failure" gap is resolved; it only matters if a config explicitly sets
  `hooks = false`.
  - Enabled hooks require persisted, hash-keyed **hook trust**.
    `--dangerously-bypass-hook-trust` bypasses it and is
    supervised-use-only (§4/§9).
  - Project hooks load only from a trusted `.codex/` layer.
  - **Unknown event names are silently ignored** (§4), so a misspelled
    event never fires.

  `[MEDIUM]` (binary `codex features list` + hooks.json probes 0.162.1,
  [learn.chatgpt.com/docs/hooks](https://learn.chatgpt.com/docs/hooks))
- **MCP server mode: GONE (0.154.0).** `codex mcp-server` was removed
  (§8). Cross-tool fan-out stays on shell-invocation cross-vendor
  review. The 2026-06-10 trigger instance no longer exists. `[MEDIUM]`
  (binary `codex --help` 0.162.1, release rust-v0.154.0)
- **Auth credentials may be plaintext** at `$CODEX_HOME/auth.json` (the
  `file` store). The docs no longer state which store is the default
  (§5, `low-confidence`). On shared dev machines, set
  `cli_auth_credentials_store = "keyring"` explicitly in
  `~/.codex/config.toml`. `[MEDIUM]`
- **Project instructions need trust.** A fresh adopter clone is
  untrusted, so Codex skips its project `AGENTS.md` until the user
  trusts the project (§1). `[MEDIUM]`
- **Rate-limit numbers are sample ranges, not contract.** OpenAI
  publishes per-model sample 5h ranges on the pricing page (§6), and
  Pro currently has no 5h limit. Variation reflects task complexity, so
  treat the figures as envelopes. `[VOLATILE]`
  ([learn.chatgpt.com/docs/pricing](https://learn.chatgpt.com/docs/pricing))
- **Codex-CLI-down posture:** every meta-layer artifact in
  [`markdowns/`](../../) works in degraded mode. Substance (markdown,
  AGENTS.md, protocols, scripts) is portable; what's lost is parallel
  subagent fan-out for deep-dive sessions on heavy surfaces. `[STABLE]`

## See also

- [`markdowns/agents/README.md`](../README.md) — index for the three vendor
  knowledge files.
- [`markdowns/meta-layer/cross-vendor-harness.md`](../../meta-layer/cross-vendor-harness.md)
  — per-vendor consumption topology + sync mechanics.
- [`markdowns/protocols/cross-vendor-review.md`](../../protocols/cross-vendor-review.md) —
  downstream consumer (cross-vendor review rubric, the cross-vendor review script).
