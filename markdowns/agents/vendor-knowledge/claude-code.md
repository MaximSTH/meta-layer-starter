---
name: vendor-knowledge-claude-code
description: Volatility-tagged knowledge of Claude Code (CLI) — canonical file, skills, subagents, hooks, auth, rate limits, cost, MCP, headless. Drives cross-vendor scripts and /refresh-vendor.
status: reference
last-verified: 2026-08-25
---

# Claude Code — vendor knowledge

Single file. One vendor. Every claim carries a `[STABLE]` / `[MEDIUM]` /
`[VOLATILE]` tag and a URL citation. Walked weekly by [`refresh-vendor.md`](../../protocols/refresh-vendor.md); change-marker semantics (no edit on no-op). Linked from the README at [`markdowns/agents/README.md`](../README.md).

**Install:** [`code.claude.com`](https://code.claude.com) — download
Claude Code (Mac / Windows native) or `npm install -g
@anthropic-ai/claude-code` (CLI / IDE extensions).

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
10. Gaps / Claude-Code-down notes

## Volatility legend

Each claim's tag describes how often the underlying content tends to change:

- **`[STABLE]`** — major version bumps only (rare).
- **`[MEDIUM]`** — minor version bumps or quarterly cadence.
- **`[VOLATILE]`** — monthly or faster.

### Verification boundary (2026-08-25 walk)

Executable claims were verified against the **locally installed binary,
v2.1.220**. npm latest at walk time was **v2.1.245**. Claims sourced only
from the changelog or docs for **v2.1.221–v2.1.245 could not be executed
here** and are marked **`low-confidence`** inline, per
[`refresh-vendor.md`](../../protocols/refresh-vendor.md) §"Executable
claims must be verified by execution, not by page-fetch". A resolving
docs URL is evidence the docs site is reachable, not that the claim is
true. Re-run these against an installed ≥2.1.245 binary at the next walk.

A weekly calendar reminder triggers the cadence — when it fires, open Claude Code in the repo and type `/refresh-vendor <vendor>`. That supervised session walks every claim regardless of tier (Claude reads `last-verified` itself during step 2 of the protocol). The tiers inform per-claim re-tagging and form a ceiling on inter-walk gap: VOLATILE 60 days, MEDIUM 90 days, STABLE yearly.

The `last-verified` frontmatter date is the date of the **last applied change**, not the date of the last walk. Walk dates live in [`markdowns/agents/refresh-log.md`](../refresh-log.md).

---

## 1. Canonical instructions file

- **Native file:** `CLAUDE.md` at repo root, plus hierarchical lookup walking up
  the directory tree, plus `~/.claude/CLAUDE.md` as user-level. `[STABLE]`
  ([code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory))
- **`AGENTS.md` is NOT natively read.** Issue #34235 remains open
  (`enhancement` + `duplicate` + `area:core`), no official Anthropic
  merge signal. The memory docs now officially document the workaround:
  a `CLAUDE.md` containing `@AGENTS.md` (import) or a symlink, and
  `/init` reads an existing `AGENTS.md` when generating `CLAUDE.md`
  (with `CLAUDE_CODE_NEW_INIT=1`). **New: `/import` (v2.1.213+)** brings
  another agent's configuration in — but it appends a **one-time copy**
  of `AGENTS.md` into `CLAUDE.md` (plus MCP servers, commands, subagents,
  skills), so it is a migration aid, **not** a replacement for this
  repo's sync hook, which must keep the mirror current on every commit.
  `[MEDIUM]`
  ([github.com/anthropics/claude-code/issues/34235](https://github.com/anthropics/claude-code/issues/34235),
  [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory))
- **Conflict resolution if both files exist:** `CLAUDE.md` is read; `AGENTS.md`
  is ignored by Claude Code natively. In this template, `AGENTS.md` is the
  canonical source and `CLAUDE.md` is auto-mirrored from it by the
  pre-commit hook — so Claude Code reads a verbatim copy of the same
  content the cross-vendor surface reads. `[STABLE]`
- **`.claude/rules/*.md` files** are loaded natively alongside `CLAUDE.md` —
  unconditionally by default, or path-scoped via `paths:` frontmatter
  globs. User-level rules live at `~/.claude/rules/`. The
  `InstructionsLoaded` hook event is observability-only (logs what
  loaded and why); it is not the load mechanism. `[MEDIUM]`
  ([code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory),
  [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks))
- **Also valid project location:** `./.claude/CLAUDE.md`. Monorepo
  exclusions via the `claudeMdExcludes` setting. Block-level HTML
  comments in `CLAUDE.md` are stripped before context injection.
  `[MEDIUM]`
  ([code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory))
- **Auto memory** (v2.1.59+, on by default): Claude-written notes at
  `~/.claude/projects/<project>/memory/`; the first 200 lines / 25KB of
  `MEMORY.md` load each session. Toggle via `autoMemoryEnabled` setting
  or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`; relocate with
  `autoMemoryDirectory`. **Index enforcement (v2.1.210):** after a
  `MEMORY.md` write, Claude Code measures it against the 200-line / 25KB
  read limit and reminds Claude to shorten it when near, or returns an
  error when over (content past the limit is dropped on next load). As
  of v2.1.211 the check strips YAML frontmatter + block-level HTML
  comments before measuring, so only loaded content counts. Memory
  files carry a `modified` ISO-8601 frontmatter timestamp written on
  each save (v2.1.214+; added only to files that already have
  frontmatter). The memory directory is **excluded** from the
  `cleanupPeriodDays` retention sweep. `CLAUDE_CODE_PROJECT_DIR_NAME`
  (v2.1.234+, **`low-confidence`** — post-2.1.220, not executed here) pins
  the `<project>` directory name. `[MEDIUM]`
  ([code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory))
- **CLAUDE.md loading limits + scopes:** a CLAUDE.md up to **4 MiB**
  loads in full; larger is skipped entirely (target <200 lines for
  adherence). Managed-policy scope: `/Library/Application
  Support/ClaudeCode/CLAUDE.md` (macOS), `/etc/claude-code/CLAUDE.md`
  (Linux/WSL), `C:\Program Files\ClaudeCode\CLAUDE.md` (Windows), or
  inline via the `claudeMd` managed-settings key — none excludable by
  `claudeMdExcludes`. `CLAUDE.local.md` is the gitignored per-project
  personal layer. Imports resolve max **4 hops**; an import resolving
  outside the working directory triggers a one-time approval dialog.
  `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` loads memory files
  from `--add-dir` directories. `[MEDIUM]`
  ([code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory))
- **Memory imports:** `CLAUDE.md` supports `@path/to/file.md` import syntax
  for splitting context. `[STABLE]`
  ([code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory))

---

## 2. Skills / protocols

- **File location:** `.claude/skills/<skill-name>/SKILL.md` (project) or
  `~/.claude/skills/<skill-name>/SKILL.md` (personal). Plugin skills live at
  `<plugin>/skills/<skill-name>/SKILL.md`. `[STABLE]`
  ([code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills))
- **Frontmatter — fully-supported fields (20):** `name`, `description`,
  `disable-model-invocation`, `user-invocable`, `allowed-tools`,
  `disallowed-tools`, `model`, `effort`, `context`, `agent`,
  `background`, `hooks`, `paths`, `arguments`, `argument-hint`,
  `when_to_use`, `shell`, `metadata`, `license`, `compatibility`. Only
  `description` is recommended; all others optional. `background`
  applies **only** with `context: fork` — default `true`; set `false` to
  wait for the forked subagent in the invoking turn (v2.1.218+).
  Boolean fields accept `yes`/`no`/`on`/`off`/`1`/`0` in any case
  alongside `true`/`false` (v2.1.218+). `[MEDIUM]`
  ([code.claude.com/docs/en/skills#frontmatter-reference](https://code.claude.com/docs/en/skills))
- **Cross-vendor portable subset — SIX fields, corrected 2026-08-25.**
  The Agent Skills spec subset is `name`, `description`, `license`,
  `compatibility`, `metadata`, `allowed-tools`. (This file previously
  said `name` + `description` only — an undercount.) Everything else is
  Claude-Code-specific. Outside Claude Code — claude.ai skill uploads,
  the Skills API, `package_skill.py` — a non-spec field is a **hard
  error**, not an ignored key: `Unexpected key(s) in SKILL.md
  frontmatter: …`.
  **This repo enforces a stricter rule than the spec.**
  [`scripts/check-skill-frontmatter.sh`](../../../scripts/check-skill-frontmatter.sh)
  (pre-commit) allows only **`name` + `description`** in
  `.agents/skills/` and fails the commit on anything else. Six is the
  spec ceiling; two is our floor, and the gate wins. ⚠️ Note the gate's
  rationale comment lists `allowed-tools` as "Claude Code specific" —
  that is factually wrong (it is one of the spec's six portable fields),
  though the stricter *policy* may still be intentional. Flagged
  2026-08-25; policy decision left to the supervisor. `[MEDIUM]`
  ([code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills),
  [agentskills.io](https://agentskills.io))
- **Invocation modes:** model-invoked (auto, by description match) or
  user-invoked (`/skill-name`). `disable-model-invocation: true` blocks the
  former; `user-invocable: false` blocks the latter. `[STABLE]`
- **Open standard:** Claude Code follows
  [agentskills.io](https://agentskills.io) (cross-tool) and adds Claude-Code
  extensions (invocation control, subagent execution, dynamic context
  injection via `` !`<command>` ``). `[STABLE]`
- **Bundled skills shipped with the CLI:** `/simplify`, `/batch`, `/debug`,
  `/loop`, `/claude-api`, `/code-review`, `/init`, `/review`,
  `/security-review`, plus `/run`, `/verify`, `/run-skill-generator`
  (v2.1.145+), plus `/doctor` (v2.1.205 — was a built-in command before;
  it is the one bundled skill exempt from `disableBundledSkills`, hide it
  via `DISABLE_DOCTOR_COMMAND` or a `skillOverrides` `"doctor": "off"`
  entry), plus more. Docs additionally name `/dataviz`,
  `/deep-research`, `/design-sync`, and `/fewer-permission-prompts`.
  **Auto-invocation narrowed:** Claude no longer runs `/verify` or
  `/code-review` on its own (v2.1.215), and `/deep-research` starts only
  when invoked manually (v2.1.218) — all three are now user-invoked.
  `/code-review` runs as a background subagent (v2.1.218). Disable via
  the `disableBundledSkills` setting; per-skill visibility via
  `skillOverrides`. Listed in
  [code.claude.com/docs/en/commands](https://code.claude.com/docs/en/commands). `[MEDIUM]`
- **`claude ultrareview` subcommand** (also reachable as `/code-review
  ultra`): cloud-hosted multi-agent review of the current branch or a
  PR number / base branch, prints findings. Options: `--json` (raw
  `bugs.json` payload), `--timeout <minutes>` (default 30). `[MEDIUM]`
  (`claude ultrareview --help`, v2.1.220)
- **`context: fork` skills run in the BACKGROUND by default**
  (v2.1.218) — opt out per skill with `background: false`. Relevant to
  any protocol skill in this repo that later adopts `context: fork`.
  `[MEDIUM]` (CHANGELOG 2.1.218)
- **Live reload:** edits to `~/.claude/skills/`, project `.claude/skills/`,
  or `--add-dir` `.claude/skills/` take effect within the current session
  without restart. New top-level directories require restart. `[MEDIUM]`
- **`SKILL.md` body cap (best practice):** keep under 500 lines per Anthropic
  guidance; move detail to sibling files referenced from the skill. The
  repo's protocol-substance pattern keeps the body <20 LOC and offloads to
  `markdowns/protocols/<topic>.md`. `[STABLE]`

---

## 3. Subagents (parallel?)

- **File location:** `.claude/agents/<name>.md` (project, walks up from cwd)
  or `~/.claude/agents/<name>.md` (user). CLI-defined subagents pass JSON via
  `--agents` and live only for that session. `[STABLE]`
  ([code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents))
- **Parallel spawn:** YES. The main agent invokes multiple `Agent` tool calls
  in a single message, and they run in parallel. `[STABLE]`
- **Subagents CAN spawn nested subagents — default depth 3, and the
  limit IS configurable.** A subagent with the `Agent` tool in its
  `tools` list spawns its own subagents; only the top-level subagent's
  summary returns to the main conversation. **Default depth is 3**
  (three layers below the main conversation); at the limit Claude Code
  withholds the `Agent` tool from every subagent *except* a fork. Set
  **`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`** to change it (`1` disables
  nesting entirely). Documented version history: depth 5 for
  v2.1.172–.216 → 1 for v2.1.217–.218 → **3 from v2.1.219**. To bar a
  specific subagent from nesting, omit `Agent` from its `tools` or add
  it to `disallowedTools`. The `Agent(agent_type)` allowlist syntax
  applies only to a main-thread `claude --agent` run, not inside a
  subagent definition. `[MEDIUM]`
  ([code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents),
  CHANGELOG 2.1.217 / 2.1.219)
- **Caps — the per-session cap is GONE; a concurrency cap replaced it.**
  The 200-subagent-per-session spawn cap
  (`CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION`, added v2.1.212) was
  **removed in v2.1.224** (**`low-confidence`** — post-2.1.220, not
  executed here); docs state plainly there is *no per-session cap on
  total subagents*. What remains is a **20
  concurrent** limit (`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`, v2.1.217);
  exceeding it fails with `Concurrent subagent limit reached`. Sessions
  with ultracode active are exempt. Forks started with `/subtask` take a
  slot but are never blocked, and resuming a finished subagent takes a
  fresh slot without checking the limit — so the running count can
  exceed 20. **Consequence: concurrency is bounded, total spend is
  not.** `[MEDIUM]`
  ([code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents),
  CHANGELOG 2.1.217 / 2.1.224)
- **Fork mode is ON by default in interactive sessions (v2.1.232;
  `low-confidence` — post-2.1.220, not executed here).** A
  `subagent_type: "fork"` subagent inherits the full conversation and
  prompt cache. While fork mode is on, Claude Code runs *all* spawned
  subagents (fork and non-fork) in the background and removes the
  `Agent` tool's `run_in_background` parameter. Control with
  `CLAUDE_CODE_FORK_SUBAGENT` (`1` on for non-interactive / Agent SDK,
  `0` off everywhere); to keep fork mode but bar forks, deny
  `Agent(fork)` in `permissions`. `[MEDIUM]`
  ([code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents))
- **`agent teams` is a separate primitive.** For multi-agent communication
  across separate sessions; not used in this repo's foundation. `[MEDIUM]`
- **Frontmatter — supported fields:** `name`, `description`, `tools`,
  `disallowedTools`, `model`, `permissionMode`, `mcpServers`, `hooks`,
  `maxTurns`, `skills`, `initialPrompt`, `memory`, `effort`, `background`,
  `isolation`, `color`. `name` + `description` are the required pair.
  (`prompt` is a `--agents` JSON key, not a field in the file-based
  frontmatter table.) Plugin subagents ignore `hooks`, `mcpServers`,
  `permissionMode` for security. `[MEDIUM]`
- **`model` defaults to `inherit` — subagents run the parent session's
  model unless pinned.** Accepts `sonnet`, `opus`, `haiku`, `fable`, a
  full model ID, or `inherit`. **Cost consequence:** with no
  `.claude/agents/` definitions and no `model:` pinned, every subagent —
  including the built-in `Explore` search/fan-out agent — inherits the
  session model and effort. Pair with §3's depth-3 nesting and the
  absent per-session cap when reasoning about blast radius. Pinning
  `model:` per agent file is the enforcement lever; there is **no
  setting or env var that downgrades subagents relative to the main
  session** (settings reference verified 2026-08-25: `model`,
  `availableModels`, `modelPicker`, `enforceAvailableModels`,
  `modelOverrides`, `fallbackModel`, `advisorModel`, `agent` — none does
  this). `[MEDIUM]`
  ([code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents),
  [code.claude.com/docs/en/settings-reference](https://code.claude.com/docs/en/settings-reference))
- **Built-in subagents:** `Explore`, `Plan`, `general-purpose`, plus skill-
  forked agents via `context: fork`. `[STABLE]`
- **Background-by-default (v2.1.198; superseded in part by fork mode
  above).** Claude runs subagents in the background by default unless it
  needs the result immediately; force it with `background: true`. Once
  fork mode is on (v2.1.232, the interactive default) the "unless it
  needs the result immediately" escape is gone — `run_in_background` is
  removed and every spawn is backgrounded. Remove built-in Explore/Plan via
  `CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS=1` (v2.1.198). The `/agents`
  interactive creation wizard was removed (v2.1.198) — author files in
  `.claude/agents/` directly or ask Claude to write one; file locations
  and frontmatter are unchanged. `[MEDIUM]`
  ([code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents))

---

## 4. Hooks

- **File location:** `~/.claude/settings.json` (user) or `.claude/settings.json`
  (project, committed) or `.claude/settings.local.json` (gitignored). Plugin
  hooks live at `<plugin>/hooks/hooks.json`. Skill / subagent frontmatter
  carries scoped hooks. `[STABLE]`
  ([code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks))
- **Event names (full list as of last-verified):** `SessionStart`, `Setup`,
  `SessionEnd`, `UserPromptSubmit`, `UserPromptExpansion`, `Stop`,
  `StopFailure`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure`,
  `PostToolBatch`, `PermissionRequest`, `PermissionDenied`,
  `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`,
  `TeammateIdle`, `InstructionsLoaded`, `ConfigChange`, `FileChanged`,
  `CwdChanged`, `DirectoryAdded`, `PreCompact`, `PostCompact`,
  `Notification`, `MessageDisplay`, `WorktreeCreate`, `WorktreeRemove`,
  `Elicitation`, `ElicitationResult`. **31 events** — `DirectoryAdded`
  added v2.1.219 (fires after `/add-dir` or the SDK `register_repo_root`
  control request; matcher filters on `slash_command` /
  `register_repo_root`). `[MEDIUM]`
  ([code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks))
- **⚠️ Matcher-semantics change (v2.1.214) — can silently narrow an
  existing hook.** A single-segment `dir/**` in a hook `if:` condition
  now matches only `<cwd>/dir`; write `**/dir/**` for any-depth
  matching. `deny` / `ask` **permission** rules keep their any-depth
  match, so the two syntaxes no longer mean the same thing. Audit any
  `if:` condition written before v2.1.214. `[MEDIUM]`
  (CHANGELOG 2.1.214)
- **Agent-frontmatter hooks require workspace trust (v2.1.218):** hooks
  declared in a subagent file now require that file's own folder to have
  accepted workspace trust before they run. `[MEDIUM]`
  (CHANGELOG 2.1.218)
- **Hook handler types:** `command` (shell, JSON on stdin), `http` (POST),
  `mcp_tool` (call an MCP server tool), `prompt` (send to Claude), `agent`
  (spawn subagent — experimental). All accept `if`, `timeout`, `statusMessage`,
  `once`. `[MEDIUM]`
- **Vendor coupling:** event names are Claude-specific. Codex CLI exposes ~6
  events with different names + semantics. Cross-vendor parity is per-event
  translation, not a shared set. `[STABLE]`
- **Repo posture:** hooks stay Claude-only by default. Portabilize only
  when a hook prevents a destructive non-code action (rare). `[STABLE]`

---

## 5. Auth

- **Default mode:** OAuth subscription (Pro / Max 5x / Max 20x / Team /
  Enterprise). Token cached in OS keystore. `[STABLE]`
  ([support.claude.com/en/articles/11145838](https://support.claude.com/en/articles/11145838-use-claude-code-with-your-pro-or-max-plan))
- **Alternates:** `ANTHROPIC_API_KEY` env var, AWS Bedrock, Google Vertex,
  Azure Foundry. Bare mode (`--bare`) skips OAuth + keystore reads, so API
  key or `apiKeyHelper` is required. `[STABLE]`
  ([code.claude.com/docs/en/headless#start-faster-with-bare-mode](https://code.claude.com/docs/en/headless))
- **No free tier sufficient for sustained use.** Free Claude.ai users do not
  get Claude Code. `[STABLE]` ([claude.com/pricing](https://claude.com/pricing))
- **Cross-vendor parity:** Codex defaults to ChatGPT OAuth. Per-vendor
  subscription posture lives in each vendor's knowledge file. `[STABLE]`

---

## 6. Rate limits — `[VOLATILE]`

**Re-verify before relying. Window doubled in May 2026; weekly caps were
introduced 2025-08-28 and stayed flat through the May 2026 doubling.
⚠️ The separate Agent-SDK monthly credit announced for 2026-06-15 was
PAUSED and never took effect — `claude -p` still draws from subscription
usage limits. See the Agent SDK bullet below.**

- **5-hour rolling window** is the primary limit; resets per first-prompt
  timestamp. `[VOLATILE]`
  ([anthropic.com/news/higher-limits-spacex](https://www.anthropic.com/news/higher-limits-spacex))
- **May 2026 announcement:** 5-hour limits **doubled** for Pro / Max / Team /
  seat-based Enterprise. Peak-hours throttle removed. Weekly caps unchanged.
  `[VOLATILE]`
  ([9to5google.com/2026/05/06/claude-code-is-getting-higher-usage-limits-doubled-for-most-users](https://9to5google.com/2026/05/06/claude-code-is-getting-higher-usage-limits-doubled-for-most-users/))
- **Approximate post-doubling 5h windows (third-party reporting; Anthropic
  does not publish absolute numbers):** Pro ~88k tokens; Max 5x ~225 messages
  / ~176k tokens; Max 20x ~900 messages / ~440k tokens. Treat as orders of
  magnitude, not contract. `[VOLATILE]`
  ([northflank.com/blog/claude-rate-limits-claude-code-pricing-cost](https://northflank.com/blog/claude-rate-limits-claude-code-pricing-cost),
  [intuitionlabs.ai/articles/claude-max-plan-pricing-usage-limits](https://intuitionlabs.ai/articles/claude-max-plan-pricing-usage-limits))
- **Weekly caps (introduced 2025-08-28):** apply to heavy users on Pro and
  Max. Anthropic does not publish absolute numbers. `[VOLATILE]`
  ([jdhodges.com/blog/claude-ai-usage-limits](https://www.jdhodges.com/blog/claude-ai-usage-limits/))
- **Agent SDK credit — ANNOUNCED, THEN PAUSED. Not in effect.**
  `[VOLATILE]` A separate monthly credit for `claude -p` / Agent SDK
  usage (Pro $20, Max 5x $100, Max 20x $200, Team $20 standard / $100
  premium) was announced for **2026-06-15**. Anthropic paused it; the
  support article now reads: *"Nothing has changed: Claude Agent SDK,
  `claude -p`, and third-party app usage still draw from your
  subscription's usage limits."* No new timeline announced.
  **Operational consequence:** scripted `claude -p` — including
  [`cross-vendor-review.sh`](../../../scripts/cross-vendor-review.sh) —
  shares the interactive 5-hour window, so exhaustion recovers in
  **hours**, not on a monthly credit refresh. The prior entry in this
  file asserted the credit as live fact; corrected 2026-08-25.
  ⚠️ Single-channel claim — corroborated only by the support article
  below; re-verify next walk.
  ([support.claude.com/en/articles/15036540](https://support.claude.com/en/articles/15036540-use-the-claude-agent-sdk-with-your-claude-plan))
- **Rate-limit error surface in headless mode:** stream-json events include
  `error: "rate_limit"` in the `system/api_retry` event. Use this to detect
  exhaustion programmatically. `[STABLE]`
  ([code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless))
- **Recovery posture:** on rate-limit hit, abort and re-run via
  `cross-vendor-review.sh --to <other-vendor>`. No automatic API-key
  fallback. Scripted `claude -p` exhaustion is **5-hour-window**
  exhaustion (the paused SDK credit never landed), so waiting out the
  window is a real same-day option alongside the vendor switch.
  `[MEDIUM]`
- **Usage-limit auto-continue (v2.1.198+/.234):** Claude Code resumes a
  session automatically when a claude.ai usage limit resets; disable via
  `/config` → "Continue automatically at usage limit".
  **`low-confidence`** — post-2.1.220, not executed here. `[MEDIUM]`
  (CHANGELOG 2.1.234)

---

## 7. Cost

- **Free:** $0/mo. Does NOT include Claude Code. `[VOLATILE]`
  ([claude.com/pricing](https://claude.com/pricing))
- **Pro:** $17/mo annual ($200/yr) or $20/mo monthly. Includes Claude Code.
  `[VOLATILE]` ([claude.com/pricing](https://claude.com/pricing))
- **Max 5x:** $100/mo — 5× Pro usage. Includes Claude Code. `[VOLATILE]`
- **Max 20x:** $200/mo — 20× Pro usage. Includes Claude Code. `[VOLATILE]`
  (Resolved 2026-07-18 via
  [support.claude.com/articles/11049741](https://support.claude.com/en/articles/11049741-what-is-the-max-plan);
  the prior "From $100 for both Max tiers" reading was a
  [claude.com/pricing](https://claude.com/pricing) WebFetch extraction
  artifact — the pricing-page fetch still mis-extracts $100 for Max 20x,
  so prefer the support-article channel for Max pricing.)
- **Team:** Standard seat $20/mo annual ($25 monthly); Premium seat
  $100/mo annual ($125 monthly). Includes Claude Code. `[VOLATILE]`
  ([claude.com/pricing](https://claude.com/pricing))
- **Enterprise:** ~$20/seat plus usage at API rates; custom pricing on
  consultation. Includes Claude Code. `[VOLATILE]`
  ([claude.com/pricing](https://claude.com/pricing))
- **API alt:** Pay-per-token via Claude API at standard model rates (Opus,
  Sonnet, Haiku). Subscriptions reach API-rate purchase once limits hit.
  `[STABLE]` ([anthropic.com/api](https://www.anthropic.com/api))
- **Headless / Agent SDK cost is NOT credit-based.** The 2026-06-15
  credit was paused (§6) — scripted `claude -p` still shares the
  interactive subscription window. `[VOLATILE]`
- **Cost-estimate mechanics:** `/cost`, the status line, and
  `--max-budget-usd` include a **1.1× US-only-inference premium** for
  data-residency workspaces (v2.1.239; **`low-confidence`** —
  post-2.1.220, not executed here). Organizations can override list
  price with contracted rates via the `modelPricing` managed setting
  (v2.1.243). All figures are client-side estimates and can differ from
  the actual bill. `[MEDIUM]` (CHANGELOG 2.1.239 / 2.1.243)
- **Per-call cost in headless mode:** `--output-format json` emits
  `total_cost_usd` and a per-model breakdown. Use `--max-budget-usd` to cap
  spend per invocation. `[STABLE]`
  ([code.claude.com/docs/en/headless#get-structured-output](https://code.claude.com/docs/en/headless),
  [code.claude.com/docs/en/cli-reference](https://code.claude.com/docs/en/cli-reference))

---

## 8. MCP (client + server)

- **As client:** mature. Four transports — `stdio`, `http` (recommended for
  remote, alias `streamable-http` in JSON config), `sse` (deprecated),
  `websocket` (for servers that push events unprompted; JSON config only
  via `.mcp.json` / `claude mcp add-json` — no OAuth, no `--transport`
  flag support). Add others via `claude mcp add --transport <type>
  <name> <url>`. Configured in `.mcp.json`, `~/.claude.json`, or scoped
  to a subagent / skill via the `mcpServers` frontmatter field.
  **WebSocket conflict RESOLVED at the binary channel (2026-08-25) —
  re-tagged `[MEDIUM]` → `[STABLE]`.** The binary's `add-json` help text
  still reads "stdio or SSE", but that is a stale help label, not
  behavior: a live probe ran
  `claude mcp add-json <name> '{"type":"ws","url":"wss://…"}'` → *"Added
  ws MCP server … to local config"*, while a control payload
  (`"type":"carrierpigeon"`) was rejected with *"Invalid configuration"*
  — proving the binary validates the type rather than accepting
  anything. Probe was run in an isolated scratch cwd and removed.
  WebSocket specifics: `type: "ws"` takes the same `url`, `headers`,
  `headersHelper`, `timeout`, `alwaysLoad` fields as `http`; auth is
  header-only (no OAuth); `--transport` does **not** accept `ws`; and
  ws servers do **not** appear in `claude mcp list` (use `claude mcp get`
  or `/mcp`). `[STABLE]`
  ([code.claude.com/docs/en/mcp](https://code.claude.com/docs/en/mcp),
  `claude mcp --help` v2.1.220, live `add-json` probe 2026-08-25)
- **OAuth 2.0 supported** for HTTP servers requiring auth. `[STABLE]`
- **As server:** YES via `claude mcp serve` — exposes Claude Code's
  built-in tools (Read, Write, Edit, Bash, Glob, Grep, LS, etc.) over stdio
  to other MCP clients (Claude Desktop, Cursor, Windsurf). No network
  exposure; security via process isolation. `[MEDIUM]`
  ([github.com/anthropics/claude-code/issues/631](https://github.com/anthropics/claude-code/issues/631),
  [ksred.com/claude-code-as-an-mcp-server-an-interesting-capability-worth-understanding](https://www.ksred.com/claude-code-as-an-mcp-server-an-interesting-capability-worth-understanding/))
- **Server-mode caveat:** Claude Code's *configured* MCP servers do NOT pass
  through. Clients that connect to `claude mcp serve` see only Claude Code's
  own tools, not the GitHub / Slack / etc. servers Claude Code itself uses.
  `[MEDIUM]`
- **Cross-vendor posture:** MCP cross-vendor servers deferred. Codex does
  not ship first-party MCP server-mode. Cross-vendor review (shell
  invocation via [`cross-vendor-review.sh`](../../../scripts/)) is today's
  answer. Trigger to revisit: any peer vendor ships first-party MCP
  server, repeated cross-vendor issues, or routine multi-turn cross-vendor
  workflow. `[STABLE]`

---

## 9. Headless invocation

- **Entry point:** `claude -p "<prompt>"` (alias `--print`). Runs the same
  agent loop as interactive mode, then exits. Used by the SDK and by
  scripts. `[STABLE]`
  ([code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless))
- **Skills in `-p` — REVERSED from pre-May-2026 posture:** user-invoked
  skills and custom commands DO work in `-p` mode — include
  `/skill-name` in the prompt string and Claude Code expands the first
  skill plus up to 5 more stacked after it, stopping at the first token
  that isn't an inline user-invocable skill (this confirms the §10
  leading-token-only expansion finding). Strictly-interactive commands
  like `/login` are unavailable, but `/config key=value` (v2.1.181),
  `/model`, `/effort`, `/fast`, `/color`, `/rename` accept a value
  argument and `/mcp` prints a text status summary — all in `-p`
  (v2.1.205). Auto-invocation by description match also works. Re-tagged
  `[STABLE]` → `[MEDIUM]` because the behavior flipped within a year.
  `[MEDIUM]`
  ([code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless);
  `claude --help` v2.1.210: `--bare` "Skills still resolve via
  /skill-name")
- **Bare mode (`--bare`):** skips hooks, LSP, plugin sync, attribution,
  auto-memory, background prefetches, keychain reads, and `CLAUDE.md`
  auto-discovery (per the binary; docs also list skills/MCP
  auto-discovery — binary wins on detail: skills still resolve via
  `/skill-name`). Auth is strictly `ANTHROPIC_API_KEY` or
  `apiKeyHelper`. Recommended for CI / scripted calls; will become the
  default for `-p` in a future release. `[MEDIUM]`
  (`claude --help` v2.1.210,
  [code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless))
- **Tool approval flags:** `--allowedTools "Read,Edit,Bash"`,
  `--permission-mode acceptEdits | auto | bypassPermissions | manual |
  dontAsk | plan` (the surfaced enum name is now `manual`, the alias for
  the old `default`, added v2.1.200; `default` still resolves. `auto` =
  background classifier reviews commands), `--permission-prompt-tool
  <mcp-tool>`. Under `-p` the **starting** permission mode is `manual`
  on every plan — pass the mode you want explicitly. `[STABLE]`
  (`claude --help` v2.1.220,
  [code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless))
- **Output formats:** `text` (default), `json` (with `total_cost_usd`,
  `session_id`, `result`), `stream-json` (NDJSON, includes `system/init`,
  `system/api_retry`, `stream_event`). `--json-schema` enforces a schema;
  the validated payload lands in the `structured_output` field. `[STABLE]`
  ([code.claude.com/docs/en/headless#get-structured-output](https://code.claude.com/docs/en/headless))
- **Cost / budget caps:** `--max-budget-usd <amount>`, `--max-turns <n>`,
  `--fallback-model <name[,name...]>` (comma-separated fallback chain).
  `[STABLE]` (`claude --help` v2.1.210)
- **Headless mechanics (added since last walk):** piped stdin capped at
  10MB (v2.1.128+, hard error above); background Bash tasks terminated
  ~5s after the final result (v2.1.163+), while background subagents /
  workflows are waited on up to a 10-min ceiling (v2.1.182,
  `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS`, `0` = no limit); `--json-schema`
  now hard-errors on an invalid schema (v2.1.205; previously ignored →
  unstructured text) and `system/init` carries a `capabilities` array
  (v2.1.205) for feature-detection. Flags: `--tools` (restrict built-in
  tool set), `--safe-mode` (all customizations disabled),
  `--disable-slash-commands`, `--effort <low|medium|high|xhigh|max>`,
  `--fork-session`, `--input-format stream-json`,
  `--include-partial-messages`, `--no-session-persistence`,
  `--exclude-dynamic-system-prompt-sections`, `--forward-subagent-text`
  (v2.1.211), `--replay-user-messages`, `--append-subagent-system-prompt`
  (v2.1.205). `[MEDIUM]` (`claude --help` v2.1.220,
  [code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless))
- **Added since v2.1.210** (binary-verified at v2.1.220 unless noted):
  flags `--brief`, `--include-hook-events`, `--prompt-suggestions`,
  `--file`, `--from-pr`, `--betas`, `--setting-sources`, `--plugin-url`,
  `--session-id`, `--strict-mcp-config`, `--bg`/`--background`,
  `-w`/`--worktree`, `--tmux`, `-n`/`--name`, `--chrome`/`--no-chrome`,
  `--ax-screen-reader`, `--allow-dangerously-skip-permissions`,
  `--system-prompt`. `-p` **rejects** `--bg`. Stream mechanics:
  `system/init` gains `mcp_server_errors` (v2.1.219, CI can fail on a
  non-empty array) alongside `capabilities` and `plugin_errors`; nested
  subagents at depth-2+ now appear under `--forward-subagent-text`
  (v2.1.219); the exit drain scales with queued bytes capped at 30s
  (v2.1.214, was ~2s and truncated large responses); `--mcp-config`
  under `-p` waits for pending servers up to `MCP_TIMEOUT` 30s
  (v2.1.221); `--resume <id>` now resolves across projects (v2.1.223) —
  both **`low-confidence`**, post-2.1.220 and not executed here;
  SIGTERM exits 143 after running `SessionEnd` hooks. `[MEDIUM]`
  (`claude --help` v2.1.220,
  [code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless))
- **Continuation:** `--continue` resumes most recent; `--resume <session-id>`
  resumes a specific session. `[STABLE]`
- **Cross-vendor review flag set** (consumed by `scripts/cross-vendor-review.sh` per [`cross-vendor-review.md`](../../protocols/cross-vendor-review.md)):
  `claude -p "$PROMPT" --allowedTools "Read,Grep,Glob"` — no `--bare`,
  no extra read-only flag; the tool allowlist is the read-only
  equivalent. The reviewer rubric injects `Do NOT execute, write, or
  modify files.` Prompt assembly is an injection surface per the
  skills-in-`-p` gap note in §10 — expansion is leading-token-only
  (canary test, 2026-06-10), and the script's fixed `From:` prefix
  occupies that position; the property holds only while the prefix
  stays first in `PROMPT`. `[MEDIUM]`
- **⚠️ SECURITY — a `-p` review without `--bare` executes the hooks of
  the directory it is LAUNCHED FROM (recorded 2026-08-25, unfixed).**
  Docs state it plainly: *"Without
  `--bare`, a `-p` session runs the hooks in a project's
  `.claude/settings.json` and connects the servers in its `.mcp.json`,
  even in a folder you've never trusted. A `-p` session shows no
  workspace trust dialog and no per-server approval prompt."*
  [`cross-vendor-review.sh:117`](../../../scripts/cross-vendor-review.sh)
  invokes `claude -p "$PROMPT" --allowedTools "Read,Grep,Glob"` with no
  `--bare`. **Precision matters:** the script passes `$TARGET` as prompt
  text only and never changes directory, so the configuration that
  executes is the **dispatcher's own working directory**, not `$TARGET`.
  The exposure is therefore conditional — it bites when the dispatcher
  is launched from inside an untrusted checkout (the normal case, since
  you review your own branch from your own repo). The `--allowedTools`
  allowlist constrains **Claude's** tools; it does not stop that
  directory's hooks from running. Adding `--bare` is the fix, but not a
  one-liner: auth then becomes strictly `ANTHROPIC_API_KEY` /
  `apiKeyHelper`. **Deliberately out of scope for this walk — tracked as
  an open residual.** `[MEDIUM]`
  ([code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless),
  `scripts/cross-vendor-review.sh:108-117`)

---

## 10. Gaps / Claude-Code-down notes

- **Subagent → subagent nesting:** supported, **default depth 3 and
  configurable** via `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` (see §3). No
  longer a Claude-side constraint on fan-out.
  **Cross-vendor head-to-head — REBUILT 2026-08-25** (pending marker
  retired; both halves re-verified — Claude at binary v2.1.220, Codex at
  binary 0.144.5). The old "Claude fixed depth 5 vs Codex raisable"
  framing is gone: both vendors are configurable, and **depth is no
  longer the interesting axis**. Claude nests 3 deep by default vs
  Codex 1; Claude allows 20 concurrent vs Codex 6; Claude's per-session
  total cap was removed while Codex documents none.
  **The load-bearing difference is delegation posture.** Codex spawns
  subagents only on explicit request; Claude Code auto-routes by
  description match *and* inherits the session model — so Claude has the
  greater **automatic fan-out exposure under documented defaults**. That
  is a statement about fan-out, not an absolute cost ranking: actual
  cost also depends on model prices, workload, real routing behavior and
  local config, and no delegate-and-observe test was run. Neither vendor
  offers a global subagent-model default; per-agent pinning is the
  documented mechanism on both, though whether Codex honors it is
  unverified. Full table in [`codex-cli.md`](codex-cli.md) §3. `[MEDIUM]`
- **`AGENTS.md` not native:** if Claude Code ships native support, the
  pre-commit duplicate-and-sync hook becomes redundant. Track via
  Issue #34235. Interim: Anthropic now officially documents a
  `CLAUDE.md` containing only `@AGENTS.md` (import) or a symlink —
  could replace the sync hook today (repo restructure deferred,
  supervisor decision 2026-06-10). `[MEDIUM]`
- **Skills in `-p`:** no longer a gap — both auto-invocation and
  `/skill-name` prompt-string expansion work (see §9). Injection
  surface: expansion fires only when the prompt BEGINS with the
  `/skill-name` token — verified empirically 2026-06-10 via canary
  skill (leading token expanded even with
  `disable-model-invocation: true`; the same token at line-start
  mid-prompt did not expand). Scripted callers must keep interpolated
  content (briefs, diffs, rubrics) out of the leading prompt position —
  the safety is assembly-order dependent, not inherent.
  Description-match auto-invocation remains the cross-vendor-portable
  authoring path. Docs now corroborate the empirical finding: expansion
  is "the first skill plus up to 5 more stacked, stopping at the first
  token that isn't an inline user-invocable skill." `[MEDIUM]`
  (empirical test v2.1.170; docs/skills confirmation v2.1.210)
- **MCP server passthrough:** `claude mcp serve` does not relay configured
  upstream MCP servers. Cross-tool fan-out via shell-invocation cross-vendor review, not MCP
  proxying. `[MEDIUM]`
- **Rate-limit anchor numbers are unofficial.** Anthropic publishes
  multipliers ("5×", "20×", "doubled"), not absolute message / token caps.
  Treat the numbers in §6 as orders of magnitude. `[VOLATILE]`
- **Claude-Code-down posture:** every meta-layer artifact in
  [`markdowns/`](../../) is acceptable in degraded mode. Skills and
  protocols ship to `.agents/` too, so peer vendors consume the same
  substance. The hard dependency is the `.claude/` integration layer —
  substance is portable. `[STABLE]`

## See also

- [`markdowns/agents/README.md`](../README.md) — index for the three vendor
  knowledge files.
- [`markdowns/meta-layer/cross-vendor-harness.md`](../../meta-layer/cross-vendor-harness.md)
  — per-vendor consumption topology + sync mechanics.
- [`markdowns/protocols/cross-vendor-review.md`](../../protocols/cross-vendor-review.md) —
  downstream consumer (cross-vendor review rubric, the cross-vendor review script).
