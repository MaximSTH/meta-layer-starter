---
name: vendor-knowledge-claude-code
description: Volatility-tagged knowledge of Claude Code (CLI) — canonical file, skills, subagents, hooks, auth, rate limits, cost, MCP, headless. Drives cross-vendor scripts and /refresh-vendor.
status: reference
last-verified: 2026-11-08
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

### Verification boundary (2026-11-08 walk)

Executable claims were verified against the **locally installed binary,
v2.1.319** — equal to npm latest (`npm view @anthropic-ai/claude-code
version` → 2.1.319). Channels, in order: `claude --help` and subcommand
`--help` output; a `strings` scan of the binary for options registered
with `.hideHelp()`, the hook-event enum, and env-var names; execution
probes (each in a fresh scratch dir with `CLAUDE_CONFIG_DIR` pointed at
scratch, no API calls, removed afterwards); the upstream CHANGELOG
(2.1.221–2.1.319); then the docs site. **No probe made an API call**, so
runtime behaviour that needs a live session (fork mode, auto-continue,
`-p` skill expansion, per-invocation model override, the absent
per-session cap) is changelog/docs-sourced and stays **`low-confidence`**
inline, per [`refresh-vendor.md`](../../protocols/refresh-vendor.md)
§"Executable claims must be verified by execution, not by page-fetch".
"Binary strings" means the name is compiled into the binary — evidence
the option/variable exists, not proof of its runtime semantics. A
resolving docs URL is evidence the docs site is reachable, not that the
claim is true. The 2026-08-25 boundary (binary v2.1.220, changelog-only
for .221–.245) is superseded.

A weekly calendar reminder triggers the cadence — when it fires, open Claude Code in the repo and type `/refresh-vendor <vendor>`. That supervised session walks every claim regardless of tier (Claude reads `last-verified` itself during step 2 of the protocol). The tiers inform per-claim re-tagging and form a ceiling on inter-walk gap: VOLATILE 60 days, MEDIUM 90 days, STABLE yearly.

The `last-verified` frontmatter date is the date of the **last applied change**, not the date of the last walk. Walk dates live in [`markdowns/agents/refresh-log.md`](../refresh-log.md).

---

## 1. Canonical instructions file

- **Native file:** `CLAUDE.md` at repo root, plus hierarchical lookup walking up
  the directory tree, plus `~/.claude/CLAUDE.md` as user-level. `[STABLE]`
  ([code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory))
- **`AGENTS.md` IS natively read since v2.1.277 — but only as a
  fallback. REVERSED 2026-11-08** (this file previously said "NOT
  natively read"). A built-in plugin (`cc-plugin-agents-md@builtin`;
  `agents-md@builtin` before v2.1.285) reads `AGENTS.md` under the
  default **Project instructions** value `claude-md-or-agents-md`:
  `AGENTS.md` loads **only when no `CLAUDE.md`, `.claude/CLAUDE.md`, or
  `CLAUDE.local.md` exists in the working directory or above it**
  (`~/.claude/CLAUDE.md`, managed `CLAUDE.md` and `.claude/rules/` don't
  count and keep loading alongside). Other values: `claude-md-and-agents-md`
  (both; skips an `AGENTS.md` already imported/symlinked), `claude-md`,
  `managed-only`. Set via `/config` → Project instructions, or
  `pluginConfigs["cc-plugin-agents-md@builtin"].options.instructionFiles`
  — honored only in user, `--settings`, or managed settings; **ignored
  in project/local settings**, so a repo cannot opt itself into
  reading both. Gaps: **a `CLAUDE.local.md` counts as a `CLAUDE.md`**, so
  adding one silently stops `AGENTS.md` loading; the feature can be
  unavailable on the **first session after upgrading from ≤2.1.276**;
  anything under `.agents/` (e.g. `.agents/skills/`) is never read.
  Subdirectory `AGENTS.md` files load lazily when Claude reads a file
  there. Issue #34235 **closed as duplicate 2026-10-22**. Confidence:
  changelog + docs + binary strings (plugin ID and the
  `no CLAUDE.md found; AGENTS.md loaded:` notice are compiled in); a
  behavioural `--init-only` probe was **inconclusive** (the
  `InstructionsLoaded` hook fired for a `CLAUDE.md` control but not for
  an `AGENTS.md`-only project — absence of evidence, not refutation), so
  runtime loading is **`low-confidence`**. `/init` with
  `CLAUDE_CODE_NEW_INIT=1` still reads an existing `AGENTS.md`;
  `/import` (v2.1.213+; also `claude import codex|gemini|cursor
  [--dry-run] [--yes]`) still appends a **one-time copy** — a migration
  aid, not a sync. `[MEDIUM]`
  (CHANGELOG 2.1.277 / 2.1.281 / 2.1.285 / 2.1.290,
  [code.claude.com/docs/en/memory#agents-md](https://code.claude.com/docs/en/memory),
  [github.com/anthropics/claude-code/issues/34235](https://github.com/anthropics/claude-code/issues/34235),
  `claude import --help` 2.1.319)
- **Conflict resolution if both files exist:** under the default
  `claude-md-or-agents-md`, `CLAUDE.md` is read and `AGENTS.md` is
  **not** — native support does not change this repo's behaviour, since
  both files exist. In this template, `AGENTS.md` is the canonical
  source and `CLAUDE.md` is auto-mirrored from it by the pre-commit hook
  — so Claude Code reads a verbatim copy of the same content the
  cross-vendor surface reads. `[STABLE]`
  ([code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory))
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
  (v2.1.234+) pins the `<project>` directory name — it applies only when
  set **alongside `CLAUDE_CONFIG_DIR`**. Variable name present in the
  binary strings at 2.1.319; runtime effect not executed
  (**`low-confidence`** on the `CLAUDE_CONFIG_DIR` dependency — docs
  only). `[MEDIUM]`
  ([code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory),
  binary strings 2.1.319)
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
- **Bundled skills shipped with the CLI** (docs label each entry
  **Skill** or **Workflow**): `/simplify`, `/batch`, `/debug`, `/loop`,
  `/claude-api`, `/code-review`, `/run`, `/verify`,
  `/run-skill-generator` (v2.1.145+), `/doctor` (v2.1.205 — the one
  bundled skill exempt from `disableBundledSkills`; hide it via
  `DISABLE_DOCTOR_COMMAND` or a `skillOverrides` `"doctor": "off"`
  entry), `/dataviz`, `/design-sync`, `/fewer-permission-prompts`, plus
  newer `/design`, `/slides`, `/update-config`, `/workflow-authoring`,
  `/claude-in-chrome`, `/artifact-capabilities`, `/artifact-diagramming`.
  **Corrected 2026-11-08:** `/deep-research` is now a bundled
  **Workflow**, not a skill; `/review` is an **alias of `/code-review`**
  (v2.1.223), not a separate skill; the docs list `/init` and
  `/security-review` as built-in commands, not skills.
  **Auto-invocation:** `/verify` and `/deep-research` run only when you
  invoke them (docs). The earlier claim that Claude no longer runs
  `/code-review` on its own (v2.1.215) is now doubtful: the docs no
  longer mark it invoke-only, and v2.1.246 lets Claude "also" start it
  on its own on Bedrock/Vertex/Foundry — implying it already can on
  first-party (**`low-confidence`** — changelog ambiguous on when that
  changed). Disable via the `disableBundledSkills` setting; per-skill
  visibility via `skillOverrides`. Listed in
  [code.claude.com/docs/en/commands](https://code.claude.com/docs/en/commands). `[MEDIUM]`
  (CHANGELOG 2.1.215 / 2.1.223 / 2.1.246)
- **`claude ultrareview` subcommand** (also reachable as `/code-review
  ultra`): cloud-hosted multi-agent review of the current branch or a
  PR number / base branch, prints findings. Options: `--json` (raw
  `bugs.json` payload), `--timeout <minutes>` (**default 45**, was 30 at
  v2.1.220), `--post` / `--no-post` (post findings to the PR as you;
  default no-post), `--trust-workspace` (trust the folder for this run
  only, for scripts/CI). `[MEDIUM]`
  (`claude ultrareview --help` 2.1.319)
- **`context: fork` skills run in the BACKGROUND by default**
  (v2.1.218) — opt out per skill with `background: false`. Relevant to
  any protocol skill in this repo that later adopts `context: fork`.
  `[MEDIUM]` (CHANGELOG 2.1.218)
- **Live reload:** edits to `~/.claude/skills/`, project `.claude/skills/`,
  or `--add-dir` `.claude/skills/` take effect within the current session
  without restart. A top-level skills directory created mid-session is
  picked up with `/reload-skills` (no restart needed). Skills synced
  from your claude.ai account land in `~/.claude/skills/synced/`.
  `[MEDIUM]` ([code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills))
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
  subagent definition. Re-verified 2026-11-08: unchanged; the env-var
  name and its at-limit message ("ask them to raise
  CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH") are in the binary strings.
  `[MEDIUM]`
  ([code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents),
  CHANGELOG 2.1.217 / 2.1.219, binary strings 2.1.319)
- **Caps — the per-session cap is GONE; a concurrency cap replaced it.**
  The 200-subagent-per-session spawn cap
  (`CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION`, added v2.1.212) was
  **removed in v2.1.224**; docs state plainly there is *no limit on the
  total number of subagents over a session*. (**`low-confidence`** —
  changelog + docs; the variable name still appears in the binary's
  env-var allow-lists, which neither proves nor disproves enforcement,
  and a >200-spawn runtime test was not run.) What remains is a **20
  concurrent** limit (`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`, v2.1.217;
  name and error text in the binary strings at 2.1.319);
  exceeding it fails with `Concurrent subagent limit reached`. Sessions
  with ultracode active are exempt. Forks started with `/subtask` take a
  slot but are never blocked, and resuming a finished subagent takes a
  fresh slot without checking the limit — so the running count can
  exceed 20. **Consequence: concurrency is bounded, total spend is
  not.** `[MEDIUM]`
  ([code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents),
  CHANGELOG 2.1.217 / 2.1.224)
- **Fork mode is ON by default everywhere** — in the interactive
  terminal since v2.1.232, and in `claude -p`, the Agent SDK, the
  desktop app and VS Code since **v2.1.302** (**`low-confidence`** —
  changelog + docs; not executed, needs a live session). A
  `subagent_type: "fork"` subagent inherits the full conversation,
  model and prompt cache. In interactive terminal, VS Code and desktop
  sessions, fork mode backgrounds every main-conversation spawn and
  Claude cannot wait for a subagent; in `claude -p` / the SDK, a
  subagent's own nested `Agent` calls run in the **foreground** (the
  spawning subagent waits). `CLAUDE_CODE_FORK_SUBAGENT=0` turns fork
  mode off (the old "`1` to enable for non-interactive" is obsolete);
  `claude mcp serve` never offers forks; to keep fork mode but bar
  forks, deny `Agent(fork)` in `permissions`. A fork at the depth limit
  keeps `Agent` listed but the call returns an error. `[MEDIUM]`
  ([code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents),
  CHANGELOG 2.1.232 / 2.1.302)
- **`agent teams` is a separate primitive.** For multi-agent communication
  across separate sessions; not used in this repo's foundation. `[MEDIUM]`
- **Frontmatter — supported fields:** `name`, `description`, `tools`,
  `disallowedTools`, `model`, `permissionMode`, `mcpServers`, `hooks`,
  `maxTurns`, `autoCompactWindow`, `skills`, `initialPrompt`, `memory`,
  `effort`, `background`, `omitClaudeMd` (v2.1.271 — start without
  user/project/local `CLAUDE.md`), `isolation`, `color`, `experimental`
  (map; `cacheTtl` key). `name` + `description` are the required pair.
  (`prompt` is a `--agents` JSON key, not a field in the file-based
  frontmatter table.) Plugin subagents ignore `hooks`, `mcpServers`,
  `permissionMode` for security. Built-in Explore and Plan start
  without `CLAUDE.md` and the git-status snapshot. Subagents on a
  different model from the main conversation use that model's saved
  effort level or its default, not the session's (v2.1.317). `[MEDIUM]`
  ([code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents),
  CHANGELOG 2.1.271 / 2.1.317)
- **`model` falls back to the parent session's model unless something
  sets it.** Accepts `sonnet`, `opus`, `haiku`, `fable`, a full model
  ID, or `inherit`. **Cost consequence:** with no
  `.claude/agents/` definitions and no `model:` pinned, every subagent —
  including the built-in `Explore` search/fan-out agent — inherits the
  session model and effort. **This repo's guardrail (2026-08-25):**
  [`.claude/agents/Explore.md`](../../../.claude/agents/Explore.md)
  shadows the built-in and
  [`.claude/agents/web-research.md`](../../../.claude/agents/web-research.md)
  covers web research, both pinned `model: sonnet` / `effort: medium`.
  **Shadowing + pin verification — CANONICAL RECORD (other files quote
  this bullet):** (1) a project agent file named `Explore` replaces the
  built-in in the Agent tool listing (sentinel-description probe);
  (2) the `model:` pin governs the spawned agent at the **API-request
  level** — with the pinned file present, the `--debug-file` log of an
  Opus parent session shows requests to both `claude-opus-5` and
  `claude-sonnet-5`; (3) control arm: the same task in a directory with
  NO project agent logs `claude-opus-5` only, confirming built-in
  inheritance. (An earlier check relied on the subagent's self-reported
  identity; superseded — self-report proves what the agent said, not
  which model served it.) All probes 2026-08-25, binary v2.1.220. Pair with §3's depth-3 nesting and the
  absent per-session cap when reasoning about blast radius.
  **⚠️ CORRECTED 2026-11-08 — the frontmatter pin is a DEFAULT, not
  enforcement.** The probes above showed the pin governs a spawn that
  passes no model; they never tested an override. The documented
  resolution order is: (1) the per-invocation `model` parameter on the
  Agent tool call (an alias: `sonnet`/`opus`/`haiku`/`fable`; restored
  v2.1.72), (2) the definition's `model:` frontmatter (where
  `model: inherit` selects the main model), (3) `CLAUDE_CODE_SUBAGENT_MODEL`
  (where the value `inherit` is the same as leaving it unset), (4) the main conversation's
  model. So Claude can override `.claude/agents/Explore.md`'s pin on any
  call; the Agent tool schema shipped to the model says the same
  ("Takes precedence over the agent definition's model frontmatter").
  A family alias in the parameter or frontmatter resolves to the main
  model's exact version when the main model is in that family. Built-in
  Explore with no project shadow runs on the main conversation's model —
  except that a Fable session on a subscription runs Explore on the
  `opus` alias. (**`low-confidence`** — docs + tool schema; no
  API-level override probe run.)
  **Previous claim REVERSED: "there is no setting or env var that
  downgrades subagents relative to the main session" was FALSE, and was
  already false at the 2026-08-25 walk** (that walk checked only the
  settings reference, not env vars). `CLAUDE_CODE_SUBAGENT_MODEL`
  existed by v2.1.147 at the latest; before v2.1.251 it **overrode
  everything**, frontmatter and `model: inherit` included; since
  v2.1.251 it is a **default** below the per-invocation parameter and
  the frontmatter (setting the variable itself to `inherit` = unset; it
  also does not by itself change built-in Explore/Plan).
  `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1`
  (v2.1.257) applies `CLAUDE_CODE_SUBAGENT_MODEL` (or the main model, if
  unset) to **every** subagent, teammate and workflow agent, ignoring
  frontmatter and per-invocation models — **the only hard enforcement**
  (forks and `model: inherit` forked skills still run on the main
  model). `CLAUDE_CODE_WORKFLOW_SUBAGENT_MODEL` (v2.1.296) does the same
  for workflow agents only. Both main variable names are in the binary
  strings at 2.1.319; runtime effect not executed (**`low-confidence`**
  on the precedence/enforcement semantics — changelog + docs only). No `settings.json`
  key does this (`teammateDefaultModel` was removed in v2.1.234).
  `[MEDIUM]`
  ([code.claude.com/docs/en/sub-agents#choose-a-model](https://code.claude.com/docs/en/sub-agents),
  [code.claude.com/docs/en/settings-reference](https://code.claude.com/docs/en/settings-reference),
  CHANGELOG 2.1.72 / 2.1.147 / 2.1.251 / 2.1.257 / 2.1.296, binary
  strings 2.1.319)
- **Built-in subagents:** `Explore`, `Plan`, `general-purpose`, plus skill-
  forked agents via `context: fork`. `[STABLE]`
- **Background-by-default (v2.1.198; superseded in part by fork mode
  above).** Claude runs subagents in the background by default unless it
  needs the result immediately; force it with `background: true`. In
  interactive terminal, VS Code and desktop sessions with fork mode on
  (the default), the "unless it needs the result immediately" escape is
  gone and every main-conversation spawn is backgrounded; turn fork mode
  off (`CLAUDE_CODE_FORK_SUBAGENT=0`) to let Claude wait. Background
  subagents get a reduced built-in tool set (docs list it). Remove built-in Explore/Plan via
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
  `Elicitation`, `ElicitationResult`, `PreModelSwitch`,
  `PostModelSwitch`. **33 events** (31 → 33 on 2026-11-08):
  `PreModelSwitch` (sequential, before a requested model switch — can
  block it) and `PostModelSwitch` (async, after any model change,
  including ones Claude Code makes itself) were added in v2.1.251;
  `DirectoryAdded` was added in v2.1.219 (fires after `/add-dir` or the SDK
  `register_repo_root` control request; matcher filters on
  `slash_command` / `register_repo_root`). Count confirmed against the
  hook-event list compiled into the binary (exactly 33 names) and the
  docs table (33 rows). `[MEDIUM]`
  ([code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks),
  binary strings 2.1.319, CHANGELOG 2.1.251)
- **⚠️ Matcher-semantics change (v2.1.214) — can silently narrow an
  existing hook.** A single-segment `dir/**` in a hook `if:` condition
  now matches only `<cwd>/dir`; write `**/dir/**` for any-depth
  matching. `deny` / `ask` **permission** rules keep their any-depth
  match, so the two syntaxes no longer mean the same thing. Audit any
  `if:` condition written before v2.1.214. `[MEDIUM]`
  (CHANGELOG 2.1.214)
- **Agent-frontmatter hooks require workspace trust (v2.1.218):** hooks
  declared in a project subagent file run only after that file's own
  folder has accepted the workspace trust dialog. **A `-p` session does
  not count as accepting it**, so those hooks never run under `-p` in an
  untrusted folder. Skill-frontmatter hooks, by contrast, follow the
  settings-file rule and *do* register in a `-p` run in an untrusted
  folder. Settings-file hooks: an interactive session holds them until
  trust is accepted; a `-p`/SDK session treats the folder as trusted. `[MEDIUM]`
  (CHANGELOG 2.1.218,
  [code.claude.com/docs/en/hooks#workspace-trust](https://code.claude.com/docs/en/hooks))
- **Hook handler types (still 5):** `command` (shell, JSON on stdin;
  exec form via `args`; `async` / `asyncRewake`), `http` (POST),
  `mcp_tool` (call an MCP server tool), `prompt` (send to Claude),
  `agent` (spawn subagent — still experimental). Common fields: `if`,
  `timeout`, `statusMessage`, `once` — **narrowed 2026-11-08:** `once`
  is honored **only** in skill frontmatter (ignored in settings files
  and agent frontmatter), and `if` is evaluated **only** on the tool
  events (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`,
  `PermissionRequest`, `PermissionDenied`) — on any other event a hook
  with `if` never runs. Added: `onFailure: "continue" | "block"` for
  `command` and `http` hooks (v2.1.295); agent-type hooks no longer run
  on `PermissionRequest` (v2.1.280); prompt and agent hooks are capped
  at 12 concurrent per event and 24 per session (v2.1.302 / v2.1.312).
  Plugins additionally get a separate JavaScript "mod" hook surface
  (`tool.check`, `agent.spawn`, `prompt.submit`, …) that is distinct
  from the 33 settings events. `[MEDIUM]`
  ([code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks),
  CHANGELOG 2.1.280 / 2.1.295 / 2.1.302 / 2.1.312)
- **Vendor coupling:** event names are Claude-specific. Codex CLI exposes
  12 events at 0.162.1 (per the codex-cli walk; see
  [`codex-cli.md`](codex-cli.md) §4) with different names + semantics. Cross-vendor parity is per-event
  translation, not a shared set. `[STABLE]`
- **Repo posture:** hooks stay Claude-only by default. Portabilize only
  when a hook prevents a destructive non-code action (rare). `[STABLE]`

---

## 5. Auth

- **Default mode:** OAuth subscription (Pro / Max / Ultra / Team /
  Enterprise — "Max 20x" was renamed **Ultra**, see §7). Token cached in
  OS keystore. A set `ANTHROPIC_API_KEY` env var takes precedence over
  the subscription and bills at API rates. `claude auth
  login|logout|status` and `claude setup-token` (long-lived token,
  subscription required) manage it from the shell. `[STABLE]`
  ([support.claude.com/en/articles/11145838](https://support.claude.com/en/articles/11145838-use-claude-code-with-your-pro-max-or-ultra-plan),
  `claude --help` / `claude auth --help` 2.1.319)
- **Alternates:** `ANTHROPIC_API_KEY` env var, Amazon Bedrock, Google
  Cloud's Agent Platform (the docs' current name for Vertex), Microsoft
  Foundry, Claude Platform on AWS, Claude apps gateway. Bare mode
  (`--bare`) skips OAuth + keystore reads, so Anthropic auth is strictly
  `ANTHROPIC_API_KEY` or `apiKeyHelper`; third-party providers use their
  own credentials. `[STABLE]`
  ([code.claude.com/docs/en/headless#start-faster-with-bare-mode](https://code.claude.com/docs/en/headless),
  `claude --help` 2.1.319)
- **No free tier sufficient for sustained use.** Free Claude.ai users do not
  get Claude Code. `[STABLE]` ([claude.com/pricing](https://claude.com/pricing))
- **Cross-vendor parity:** Codex defaults to ChatGPT OAuth. Per-vendor
  subscription posture lives in each vendor's knowledge file. `[STABLE]`

---

## 6. Rate limits — `[VOLATILE]`

**Re-verify before relying. Window doubled in May 2026; weekly caps were
introduced 2025-08-28 and stayed flat through the May 2026 doubling.
⚠️ The separate Agent-SDK monthly credit announced for 2026-06-15 was
PAUSED and never took effect — `claude -p` under OAuth still draws from
subscription usage limits. A *different* monthly **API** credit
(2026-10-07) exists for Max / Ultra / Team; it covers `claude -p` only
when run with an API key. See the Agent SDK bullets below.**

- **5-hour window + weekly limit** on Pro and Max (the 5-hour window
  resets per first-prompt timestamp). **Ultra:** weekly limit only — 
  verified Ultra accounts have **no 5-hour limit** (a temporary limit
  applies until verification). Max and Ultra also have a **separate
  weekly Fable limit** (Fable may use up to 50% of the weekly limit).
  Limits are shared across Claude and Claude Code. A response already
  in progress at the 5-hour limit may get a small, capped "wrapping up"
  allowance. `[VOLATILE]`
  ([support.claude.com/en/articles/11145838](https://support.claude.com/en/articles/11145838-use-claude-code-with-your-pro-max-or-ultra-plan),
  [support.claude.com/en/articles/17728952](https://support.claude.com/en/articles/17728952-what-is-the-ultra-plan),
  [anthropic.com/news/higher-limits-spacex](https://www.anthropic.com/news/higher-limits-spacex))
- **May 2026 announcement:** 5-hour limits **doubled** for Pro / Max / Team /
  seat-based Enterprise. Peak-hours throttle removed. Weekly caps unchanged.
  `[VOLATILE]`
  ([9to5google.com/2026/05/06/claude-code-is-getting-higher-usage-limits-doubled-for-most-users](https://9to5google.com/2026/05/06/claude-code-is-getting-higher-usage-limits-doubled-for-most-users/))
- **Approximate post-doubling 5h windows (third-party reporting; Anthropic
  does not publish absolute numbers):** Pro ~88k tokens; Max 5x ~225 messages
  / ~176k tokens; Max 20x ~900 messages / ~440k tokens. Treat as orders of
  magnitude, not contract. **Not re-verified 2026-11-08** (pages resolve;
  content not re-read). The Max 20x figures predate its rename to Ultra,
  which is now weekly-only (10× Pro per week) for verified accounts, so
  they no longer describe a current plan. `[VOLATILE]`
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
  draws from the same subscription limits as interactive use, not a
  monthly credit. On Pro and Max that means the 5-hour window
  (recovers in **hours**); on a verified **Ultra** account there is no
  5-hour window, so exhaustion hits the weekly limit and can take
  **days** (see "Recovery posture" below). The prior entry in this
  file asserted the credit as live fact; corrected 2026-08-25.
  Re-verified 2026-11-08: the June 15 pause notice still stands.
  ⚠️ Still a single-channel claim (that support article); re-verify
  next walk.
  ([support.claude.com/en/articles/15036540](https://support.claude.com/en/articles/15036540-use-the-claude-agent-sdk-with-your-claude-plan))
- **Monthly API credits for Max / Ultra / Team (update dated
  2026-10-07) — a separate program from the paused SDK credit.**
  Monthly credits: Max $100, Ultra $200, Team $20 per Standard seat and
  $100 per Premium seat (pooled, capped at $500). They are not available
  on Free, Pro or Enterprise. Claimed by linking a Claude Console
  organization. They cover the Claude API, Managed Agents, the Agent
  SDK, and `claude -p` **only when run with an API key from the linked
  Console org**. They do **not** cover interactive Claude Code, and
  they do not change plan limits; signed in with OAuth, `claude -p`
  still draws from plan limits. They don't roll over. **Operational
  consequence:** this changes the `--bare` tradeoff (§9) for eligible
  operators — `--bare` forces API-key auth, which can now draw from
  these credits rather than pure pay-per-token. `[VOLATILE]`
  ([support.claude.com/en/articles/17154008](https://support.claude.com/en/articles/17154008-monthly-api-credits-for-max-ultra-and-team-plans),
  [support.claude.com/en/articles/15036540](https://support.claude.com/en/articles/15036540-use-the-claude-agent-sdk-with-your-claude-plan))
- **Rate-limit error surface in headless mode:** stream-json events include
  `error: "rate_limit"` in the `system/api_retry` event. Use this to detect
  exhaustion programmatically. `[STABLE]`
  ([code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless))
- **Recovery posture:** on rate-limit hit, abort and re-run via
  `cross-vendor-review.sh --to <other-vendor>`. No automatic API-key
  fallback. On **Pro and Max**, scripted `claude -p` exhaustion is
  usually **5-hour-window** exhaustion (the paused SDK credit never
  landed), so waiting out the window is a real same-day option
  alongside the vendor switch. **On a verified Ultra account there is
  no 5-hour window** — exhaustion means the **weekly** limit, so
  recovery takes days and the vendor switch is the only same-day
  option. `[MEDIUM]`
- **Usage-limit auto-continue (v2.1.234):** Claude Code resumes a
  session automatically when a claude.ai usage limit resets; disable via
  `/config` → "Continue automatically at usage limit". Later fixes cap
  automatic continuation at three times without a prompt from you
  (v2.1.314). **`low-confidence`** — changelog only; not executed (needs
  a live session at a limit). `[MEDIUM]`
  (CHANGELOG 2.1.234 / 2.1.314)

---

## 7. Cost

- **Free:** $0/mo. Does NOT include Claude Code. `[VOLATILE]`
  ([claude.com/pricing](https://claude.com/pricing))
- **Pro:** $17/mo annual ($200/yr) or $20/mo monthly. Includes Claude Code.
  `[VOLATILE]` ([claude.com/pricing](https://claude.com/pricing))
- **Max:** $100/mo — 5× Pro usage per 5 hours and per week; Fable
  included up to half the weekly limit; monthly API credits (amount in §6). Now
  a **single tier**. Includes Claude Code. `[VOLATILE]`
  ([support.claude.com/articles/11049741](https://support.claude.com/en/articles/11049741-what-is-the-max-plan),
  [claude.com/pricing](https://claude.com/pricing))
- **Ultra (formerly Max 20x — RENAMED, corrected 2026-11-08):** $200/mo.
  "The Max 20x plan is now called the Ultra plan"; existing subscribers
  moved over with no price change. **10× Pro usage per week**, no 5-hour
  limit for verified accounts, a separate weekly Fable limit, monthly
  API credits (amount in §6). Includes Claude Code. The earlier "pricing page
  mis-extracts $100 for Max 20x" caveat is obsolete. `[VOLATILE]`
  ([support.claude.com/articles/17728952](https://support.claude.com/en/articles/17728952-what-is-the-ultra-plan),
  [claude.com/pricing](https://claude.com/pricing))
- **Team:** Standard seat $20/mo annual ($25 monthly); Premium seat
  $100/mo annual ($125 monthly; 5× standard usage). Includes Claude
  Code. `[VOLATILE]`
  ([claude.com/pricing](https://claude.com/pricing))
- **Enterprise:** US$20/seat/month billed annually, **20-seat minimum**,
  plus usage at API rates. Includes Claude Code. `[VOLATILE]`
  ([claude.com/pricing](https://claude.com/pricing))
- **Fable on plans:** included on Max, Ultra and Team Premium seats (up
  to 50% of weekly limits); runs on pay-as-you-go usage credits on Pro
  and Team Standard. Model rates live in
  [`model-capabilities.md`](../model-capabilities.md) (SSOT) — not
  restated here. `[VOLATILE]`
  ([support.claude.com/articles/15424964](https://support.claude.com/en/articles/15424964-claude-fable-models-on-your-plan))
- **API alt:** Pay-per-token via Claude API at standard model rates (Opus,
  Sonnet, Haiku). Subscriptions reach API-rate purchase once limits hit.
  `[STABLE]` ([anthropic.com/api](https://www.anthropic.com/api))
- **Headless / Agent SDK cost under OAuth is NOT credit-based.** The
  2026-06-15 credit was paused (§6), so OAuth-authenticated scripted
  `claude -p` still shares the interactive subscription limits. Only
  `claude -p` run with an API key from a Console org linked to a Max /
  Ultra / Team plan draws from that plan's monthly API credits (§6).
  `[VOLATILE]`
- **Default model and aliases (behaviour, not prices):** `default`
  resolves to **Opus 5.5** on every first-party plan — Pro and Team
  Standard moved from Sonnet to Opus in v2.1.280. Aliases: `default`,
  `best` (new; the `fable` model where available, else `opus`),
  `fable`, `opus`, `sonnet`, `haiku`, `sonnet[1m]`, `opus[1m]`,
  `opusplan`. On the Anthropic API, `opus` → Opus 5.5, **`sonnet` →
  Sonnet 5.5** (v2.1.284), `haiku` → Haiku 5.5 (v2.1.293), `fable` →
  Fable 5.1 (v2.1.257). Other providers resolve aliases to older
  versions. Model IDs and rates: [`model-capabilities.md`](../model-capabilities.md)
  (SSOT). `[VOLATILE]`
  ([code.claude.com/docs/en/model-config](https://code.claude.com/docs/en/model-config),
  `claude --help` 2.1.319 (`--model` examples `fable`/`opus`/`sonnet`),
  CHANGELOG 2.1.257 / 2.1.280 / 2.1.284 / 2.1.293 / 2.1.301)
- **Cost-estimate mechanics:** `/cost`, the status line, and
  `--max-budget-usd` include a **1.1× US-only-inference premium** for
  data-residency workspaces (v2.1.239). Organizations can override list
  price with contracted rates via the `modelPricing` managed setting
  (v2.1.243; markup via `multiplier > 1` needs v2.1.271+). All figures
  are client-side estimates and can differ from the actual bill.
  Changelog + docs; not executed (needs a billed session) —
  **`low-confidence`** on the runtime mechanics. `[MEDIUM]`
  (CHANGELOG 2.1.239 / 2.1.243,
  [code.claude.com/docs/en/costs](https://code.claude.com/docs/en/costs))
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
  **Re-probed 2026-11-08 at 2.1.319** (isolated `CLAUDE_CONFIG_DIR`):
  same accept/reject result, and the `add-json` help text now reads
  "stdio, SSE, HTTP, or WebSocket", so the stale label is gone.
  WebSocket specifics: `type: "ws"` takes the same `url`, `headers`,
  `headersHelper`, `timeout`, `alwaysLoad` fields as `http`; auth is
  header-only (no OAuth); `--transport` does **not** accept `ws` (help
  lists `stdio, sse, http`). **CORRECTED 2026-11-08:** ws servers **do**
  appear in `claude mcp list` since v2.1.285 — the probe listed
  `wsprobe: wss://… (WS) - ✘ Failed to connect`. ws messages over 16
  MiB close the connection (v2.1.295). `--transport http` now tries
  HTTP first and falls back to SSE. `[STABLE]`
  ([code.claude.com/docs/en/mcp](https://code.claude.com/docs/en/mcp),
  `claude mcp add --help` / `add-json --help` 2.1.319, live `add-json`
  + `mcp list` probe 2026-11-08, CHANGELOG 2.1.285 / 2.1.295)
- **OAuth 2.0 supported** for HTTP servers requiring auth. `[STABLE]`
- **As server:** YES via `claude mcp serve` — exposes Claude Code's
  built-in tools (Read, Write, Edit, Bash, Glob, Grep, LS, etc.) over stdio
  to other MCP clients (Claude Desktop, Cursor, Windsurf). No network
  exposure; security via process isolation. Still stdio-only at 2.1.319
  (`claude mcp serve --help`: `-d`, `--verbose`). Since v2.1.302 it
  never offers fork subagents; long tool calls send progress updates
  every 30s. Issue #631 is closed. `[MEDIUM]`
  ([github.com/anthropics/claude-code/issues/631](https://github.com/anthropics/claude-code/issues/631),
  [ksred.com/claude-code-as-an-mcp-server-an-interesting-capability-worth-understanding](https://www.ksred.com/claude-code-as-an-mcp-server-an-interesting-capability-worth-understanding/))
- **Server-mode caveat:** Claude Code's *configured* MCP servers do NOT pass
  through. Clients that connect to `claude mcp serve` see only Claude Code's
  own tools, not the GitHub / Slack / etc. servers Claude Code itself uses.
  `[MEDIUM]`
- **Cross-vendor posture:** MCP cross-vendor servers deferred. Codex does
  not ship first-party MCP server-mode (`codex mcp-server` was removed
  in 0.154.0, per the codex-cli walk; see [`codex-cli.md`](codex-cli.md)). Cross-vendor review (shell
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
  `/skill-name` at the start of the prompt string and Claude Code
  expands it. **CORRECTED 2026-11-08:** through `claude -p` or the Agent
  SDK, Claude Code loads **only the first skill**, and the rest of the
  line becomes its arguments. The "first skill plus up to five more
  stacked" behaviour applies only at the interactive terminal prompt.
  This is consistent with, and slightly tighter than, the §10
  leading-token-only finding (**`low-confidence`** — docs only; not
  executed, needs an API call). Strictly-interactive commands
  like `/login` are unavailable, but `/config key=value` (v2.1.181),
  `/model`, `/effort`, `/fast`, `/color`, `/rename` accept a value
  argument and `/mcp` prints a text status summary — all in `-p`
  (v2.1.205); `/output-style` too (v2.1.269). Auto-invocation by
  description match also works. Re-tagged
  `[STABLE]` → `[MEDIUM]` because the behavior flipped within a year.
  `[MEDIUM]`
  ([code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless),
  [code.claude.com/docs/en/skills#stack-several-skills-in-one-message](https://code.claude.com/docs/en/skills);
  `claude --help` 2.1.319: `--bare` "Skills still resolve via
  /skill-name")
- **Bare mode (`--bare`):** skips hooks (those defined in settings and
  by installed plugins), LSP, plugin sync, attribution, auto-memory,
  background prefetches, keychain reads, and `CLAUDE.md` auto-discovery,
  and sets `CLAUDE_CODE_SIMPLE=1`. The docs also list skills and MCP
  auto-discovery; the binary wins on detail, since skills still resolve
  via `/skill-name`. Anthropic auth is strictly `ANTHROPIC_API_KEY` or
  `apiKeyHelper` via `--settings`; third-party providers use their own
  credentials. **Changed v2.1.286:** connects only the MCP servers named
  on the command line, sends the model no system reminders, and starts
  no background tasks; Claude gets the Bash, file-read and file-edit
  tools. Hooks passed via `--settings` or a flag-loaded plugin still
  don't run. Recommended for CI / scripted calls; will become the
  default for `-p` in a future release. `[MEDIUM]`
  (`claude --help` 2.1.319, CHANGELOG 2.1.286,
  [code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless))
- **Tool approval flags:** `--allowedTools "Read,Edit,Bash"`,
  `--disallowedTools`, `--permission-mode acceptEdits | auto |
  bypassPermissions | manual | dontAsk | plan` (the surfaced enum name
  is `manual`, the alias for the old `default`, added v2.1.200;
  `default` still parses — verified by execution 2026-11-08. `auto` =
  background classifier reviews commands), `--permission-prompt-tool
  <mcp-tool>` (**now hidden from `--help`** — registered with
  `.hideHelp()` and still documented in cli-reference), and new
  `--permission-prompts host|none` (`none` auto-denies anything that
  would prompt and tells Claude not to retry).
  **⚠️ `--allowedTools` AUTO-APPROVES; it does not RESTRICT.** Docs:
  *"Calls to tools you didn't list run if they need no approval"* —
  e.g. reads in the working directories and the read-only Bash command
  set. To restrict the tool set, use `--tools` (built-in set only) or
  `--restricted`. **Starting mode under `-p`:** the built-in default
  is Manual (`default`; reaffirmed v2.1.302 after 2.1.285–2.1.301
  briefly started 3P/telemetry-off `-p` runs in auto), but
  `--permission-mode` **and `permissions.defaultMode` from any
  settings file outrank it**. Pass the mode you want explicitly.
  `[STABLE]`
  (`claude --help` 2.1.319, binary strings 2.1.319,
  [code.claude.com/docs/en/headless#auto-approve-tools](https://code.claude.com/docs/en/headless),
  [code.claude.com/docs/en/permission-modes](https://code.claude.com/docs/en/permission-modes),
  CHANGELOG 2.1.285 / 2.1.302)
- **Output formats:** `text` (default), `json` (with `total_cost_usd`,
  `session_id`, `result`), `stream-json` (NDJSON, includes `system/init`,
  `system/api_retry`, `stream_event`). `--json-schema` enforces a schema;
  the validated payload lands in the `structured_output` field; it is
  absent when a run ends without valid structured output, so check
  before use. `[STABLE]`
  ([code.claude.com/docs/en/headless#get-structured-output](https://code.claude.com/docs/en/headless))
- **Cost / budget caps:** `--max-budget-usd <amount>` (subagent spend
  counts), `--max-turns <n>`, `--fallback-model <name[,name...]>`
  (comma-separated fallback chain). **`--max-turns` is now hidden from
  `--help`** — registered with `.hideHelp()` and still documented in
  cli-reference; it is not removed. `[STABLE]` (`claude --help` 2.1.319,
  binary strings 2.1.319,
  [code.claude.com/docs/en/cli-reference](https://code.claude.com/docs/en/cli-reference))
- **Headless mechanics:** piped stdin capped at 10MB (v2.1.128+, hard
  error above). **CHANGED v2.1.292:** background commands that the main
  conversation started are now **waited for** (until exit or their time
  limit) instead of being stopped ~5s after the final result. Otherwise,
  remaining work is stopped after 10 minutes of continuous idle waiting
  (`CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS`, `0` = no limit). Background
  subagents and workflows run to completion because their result is
  part of the output. `-p` now exits **1 with an error** on startup
  failure, instead of 0 with no output (v2.1.314). A stderr warning
  appears starting 10 days before a stored claude.ai sign-in ends
  (v2.1.318). `--json-schema` hard-errors on an invalid schema (v2.1.205;
  **verified by execution 2026-11-08**: `Error: --json-schema is not
  valid JSON`) and `system/init` carries a `capabilities` array
  (v2.1.205) for feature-detection. Flags: `--tools` (restrict built-in
  tool set), `--safe-mode` (all customizations — `CLAUDE.md`, skills,
  plugins, hooks, MCP servers, custom commands and agents, output
  styles, workflows, … — disabled; **auth, model selection, built-in
  tools and permissions work normally**; managed policy still applies;
  sets `CLAUDE_CODE_SAFE_MODE=1`),
  `--disable-slash-commands`, `--effort <low|medium|high|xhigh|max>`,
  `--fork-session`, `--input-format stream-json`,
  `--include-partial-messages`, `--no-session-persistence`,
  `--exclude-dynamic-system-prompt-sections`, `--forward-subagent-text`
  (v2.1.211), `--replay-user-messages`. `--append-subagent-system-prompt`
  (v2.1.205) is **hidden from `--help`** but still registered.
  `[MEDIUM]` (`claude --help` 2.1.319, binary strings 2.1.319,
  [code.claude.com/docs/en/cli-reference](https://code.claude.com/docs/en/cli-reference),
  [code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless))
- **Added since v2.1.210** (binary-verified at v2.1.220 unless noted):
  flags `--brief`, `--include-hook-events`, `--prompt-suggestions`,
  `--file`, `--from-pr`, `--betas`, `--setting-sources`, `--plugin-url`,
  `--session-id`, `--strict-mcp-config`, `--bg`/`--background`,
  `-w`/`--worktree`, `--tmux`, `-n`/`--name`, `--chrome`/`--no-chrome`,
  `--ax-screen-reader`, `--allow-dangerously-skip-permissions`,
  `--system-prompt`. `-p` **rejects** `--bg` — **verified by execution
  2026-11-08** (*"--bg and --print conflict"*). Stream mechanics:
  `system/init` gains `mcp_server_errors` (v2.1.219, CI can fail on a
  non-empty array) alongside `capabilities` and `plugin_errors`; nested
  subagents at depth-2+ now appear under `--forward-subagent-text`
  (v2.1.219); the exit drain scales with queued bytes capped at 30s
  (v2.1.214, was ~2s and truncated large responses); `--mcp-config`
  under `-p` waits for pending servers up to `MCP_TIMEOUT` 30s
  (v2.1.221); `--resume <id>` searches the current project and its
  worktrees, then every other project on the machine (v2.1.223) — both
  docs-confirmed but **`low-confidence`** (not executed; need live
  servers or stored sessions); SIGTERM exits 143 after running
  `SessionEnd` hooks. `[MEDIUM]`
  (`claude --help` v2.1.220,
  [code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless),
  [code.claude.com/docs/en/cli-reference](https://code.claude.com/docs/en/cli-reference))
- **Added since v2.1.220** (present in `claude --help` 2.1.319 and not
  previously named here): flags `--restricted` (removes the built-in
  code-running tools and WebFetch unless `--tools` names them; ignores
  user/project/local settings files; confines file tools to the working
  directories; refuses `bypassPermissions`), `--permission-prompts
  host|none`, `--system-prompt-snapshot on|off`, `--autocompact
  <auto|tokens>`, `--cloud`, `--environment`, `--desktop`,
  `--remote-control`, `--teleport`, `--ide`. Subcommands: `agents`,
  `attach`, `logs`, `stop|kill`, `rm`, `respawn`, `purge`, `auth`,
  `auto-mode`, `gateway`, `import`, `install`, `setup-token`, `doctor`,
  `update|upgrade`. `[MEDIUM]` (`claude --help` 2.1.319)
- **Continuation:** `--continue` resumes most recent; `--resume <session-id>`
  resumes a specific session. `[STABLE]`
- **Cross-vendor review flag set** (consumed by `scripts/cross-vendor-review.sh` per [`cross-vendor-review.md`](../../protocols/cross-vendor-review.md)),
  **as the script runs it** ([`cross-vendor-review.sh`](../../../scripts/cross-vendor-review.sh),
  claude branch): `claude -p "$PROMPT" --safe-mode --model
  "$REVIEW_MODEL" --tools "Read,Grep,Glob" --allowedTools
  "Read,Grep,Glob" </dev/null` (900s perl `alarm` timeout).
  `$REVIEW_MODEL` comes from `--tier` (default `workhorse` = `sonnet`,
  which resolves to **Sonnet 5.5**, v2.1.284; `frontier` = `opus`,
  `light` = `haiku`). No `--bare`. Every flag is present in
  `claude --help` 2.1.319.
  **Why `--tools` (added 2026-11-08):** `--allowedTools` only
  auto-approves the listed tools and removes nothing (§9 "Tool approval
  flags"), and **`--safe-mode` keeps permissions working normally**, so
  the operator's user-level `permissions.allow` rules stayed in force
  inside a review run. `--tools` restricts the built-in tool set itself.
  **Behaviorally probed 2026-11-08 (v2.1.319), three arms, scratch
  repo, stream-json `system/init` + `tool_use` events:** (A) old flags
  without `--tools` — 26 tools at init, and the reviewer **ran `gh api
  /zen` via the operator's `Bash(gh api:*)` allow rule** (exposure
  demonstrated; the reference operator also allow-lists `WebFetch`,
  `WebSearch` and `Read(//Users/<operator>/**)`); (B) with `--tools` —
  init tools exactly `Glob`/`Grep`/`Read`, reply `NO_BASH`; (C) with
  `--tools` — a `Read` of a nonce file succeeded, so review reads still
  work. A `permissions.defaultMode` in operator settings can no longer
  widen the tool set either, since the tools are absent rather than
  merely unapproved. The rubric's `Do NOT execute, write, or modify
  files.` remains prompt text; `--tools` is the enforcement. Prompt assembly is an injection
  surface per the skills-in-`-p` gap note in §10 — expansion is
  leading-token-only (canary test, 2026-06-10), and the script's fixed
  `From:` prefix occupies that position; the property holds only while
  the prefix stays first in `PROMPT`.
  **RESOLVED 2026-11-08** (fix/dispatcher-hardening-2026-11-08; was the
  open residual from the 2026-11-08 walk). `[MEDIUM]`
  (`scripts/cross-vendor-review.sh` claude branch, `claude --help` 2.1.319,
  three-arm probe 2026-11-08,
  [code.claude.com/docs/en/headless#auto-approve-tools](https://code.claude.com/docs/en/headless),
  [code.claude.com/docs/en/cli-reference](https://code.claude.com/docs/en/cli-reference))
- **⚠️ SECURITY — a `-p` review without `--bare` executes the hooks of
  the directory it is LAUNCHED FROM — RESOLVED via `--safe-mode`.**
  Docs: *"Without `--bare`, a `-p` session runs the hooks in a project's
  `.claude/settings.json` and connects the servers in its `.mcp.json`,
  even in a folder you've never trusted. A `-p` session shows no
  workspace trust dialog and no per-server approval prompt."* The script
  passes `$TARGET` as prompt text only and never changes directory, so
  the exposure was the **dispatcher's own working directory's**
  configuration, not `$TARGET`'s. Recorded 2026-08-25 at the then-line
  `:117`. **Fixed** by adding `--safe-mode` rather than `--bare`, which
  would force API-key auth. Behaviourally probed 2026-08-25 at v2.1.220
  under `-p`: plain fired a sentinel SessionStart hook, `--safe-mode`
  did not, and the run completed under OAuth. **Re-probed 2026-11-08 at
  v2.1.319 under `--init-only`** (runs Setup + SessionStart hooks, then
  exits; isolated `CLAUDE_CONFIG_DIR`; no API call): plain fired the
  project SessionStart sentinel, while `--safe-mode` and `--bare` did
  not. The re-probe used `--init-only`, not `-p`, and the docs'
  hook-safety advice names `--bare` / `disableAllHooks`, not
  `--safe-mode`. Residual permission exposure: see the flag-set bullet
  above. `[MEDIUM]`
  ([code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless),
  [`refresh-log.md`](../refresh-log.md) residual 2026-08-25,
  `scripts/cross-vendor-review.sh:128-146`, `--init-only` probe
  2026-11-08)

---

## 10. Gaps / Claude-Code-down notes

- **Subagent → subagent nesting:** supported, **default depth 3 and
  configurable** via `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` (see §3). No
  longer a Claude-side constraint on fan-out.
  **Cross-vendor head-to-head — UPDATED 2026-11-08.** The Claude half
  was re-verified at v2.1.319: depth 3 and 20 concurrent are unchanged
  (docs plus env-var names and at-limit messages in the binary strings),
  and there is no per-session total cap (changelog + docs). The Codex
  half comes from the codex-cli walk at 0.162.1: `agents.max_depth` and
  the concurrency key still exist, but their default **values are no
  longer stated** in Codex docs. Antigravity now documents a **maximum
  nesting depth of 10** (per the antigravity-cli walk). Both Claude and
  Codex are configurable, and **depth is still not the interesting
  axis**.
  **The load-bearing difference is delegation posture.** Codex spawns
  subagents on explicit request (proactively only at its top
  intelligence level), while Claude Code auto-routes by description
  match. That gives Claude the greater **automatic fan-out exposure
  under documented defaults**. This is a statement about fan-out, not an
  absolute cost ranking: actual cost also depends on model prices,
  workload, real routing behavior and local config, and no
  delegate-and-observe test was run.
  **CORRECTED 2026-11-08 — "neither vendor offers a global
  subagent-model default" was FALSE for both vendors.**
  - **Claude:** `CLAUDE_CODE_SUBAGENT_MODEL` is the default (below the
    per-invocation parameter and the frontmatter since v2.1.251), and
    `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` (v2.1.257) is the only hard
    enforcement; the frontmatter pin itself is overridable per
    invocation (§3).
  - **Codex:** `agents.default_subagent_model` is a binary-confirmed
    key; whether a spawn honors it is unverified.
  - **Asymmetry:** only Claude ships a hard-enforcement switch.
  Full table in [`codex-cli.md`](codex-cli.md) §3. `[MEDIUM]`
- **`AGENTS.md` native support — §10 trigger FIRED; mirror KEPT.** This
  bullet previously said "if Claude Code ships native support, the
  pre-commit duplicate-and-sync hook becomes redundant". Claude Code
  shipped it in v2.1.277 (§1), and issue #34235 closed as a duplicate
  on 2026-10-22. **Decision: trigger fired; supervisor kept the mirror
  2026-11-08 — native read is fallback-only when no CLAUDE.md exists,
  so the mirror remains load-bearing for this repo and for adopters on
  <2.1.277** (ruling R5). Supporting facts:
  - The default `claude-md-or-agents-md` mode ignores `AGENTS.md`
    whenever a `CLAUDE.md` exists.
  - Any `CLAUDE.local.md` suppresses `AGENTS.md`.
  - Native reading can be missing on the first session after upgrading
    from ≤2.1.276.
  - A repo cannot opt into `claude-md-and-agents-md` from project
    settings.
  - `.agents/` (including `.agents/skills/`) is never read, so the
    skills mirror stays necessary regardless.
  The `@AGENTS.md` import or symlink alternative remains documented
  (repo restructure deferred, supervisor decision 2026-06-10). `[MEDIUM]`
  ([code.claude.com/docs/en/memory#agents-md](https://code.claude.com/docs/en/memory),
  CHANGELOG 2.1.277)
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
  authoring path. The docs corroborate the leading-token finding, and
  since the 2026-11-08 walk they are stricter for `-p`: only the
  **first** skill loads, and the rest of the line becomes its
  arguments. The "plus up to five more stacked" behaviour is
  terminal-only (§9; **`low-confidence`** — docs only, not executed).
  `[MEDIUM]`
  (empirical test v2.1.170; docs/skills confirmation v2.1.210; docs
  re-read 2026-11-08)
- **MCP server passthrough:** `claude mcp serve` does not relay configured
  upstream MCP servers. Cross-tool fan-out via shell-invocation cross-vendor review, not MCP
  proxying. `[MEDIUM]`
- **Rate-limit anchor numbers are unofficial.** Anthropic publishes
  multipliers ("5×" for Max, "10× per week" for Ultra, "doubled"), not
  absolute message / token caps.
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
