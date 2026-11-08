---
name: vendor-knowledge-antigravity-cli
description: Volatility-tagged knowledge of Antigravity CLI — Google's coding CLI (`agy`). Canonical instructions file, skills, subagents, hooks, auth, rate limits, cost, MCP, headless invocation. Drives cross-vendor scripts and /refresh-vendor.
status: reference
last-verified: 2026-11-08
# Probe RE-RUN 2026-08-25 on binary 1.1.20 (three arms, scratch git repo,
# global strict+sandbox + project hardening in force): (1) write_file tool
# request auto-denied, sentinel absent; (2) shell-write attempt also
# auto-denied, sentinel absent; (3) benign control produced normal output
# without tripping the dispatcher's denial grep. HISTORY (true on 1.1.20,
# NOT a current-state claim): the 1.1.20 denial phrasing ("no output
# produced — a tool required the \"write_file\" permission … auto-denied")
# matched cross-vendor-review.sh's fail-closed regex.
# NOTE: denial exits 0 on 1.1.20 (changelog claim confirmed by probe) —
# text-grep is the ONLY working detection; exit codes are useless for this.
# The dispatcher's version gate requires headless-write-probe-verified-on
# to EQUAL the installed binary — re-run this probe on every agy bump.
# 2026-11-08: installed agy is 1.5.3 (auto-updated from 1.4.12 during the
# refresh walk). The version gate REFUSES dispatch as designed (1.1.20 !=
# 1.5.3). Do NOT re-probe until the denial-regex gap in §9 (1.1.27+ notice
# not matched) is fixed in the dispatcher — re-probe must follow that fix.
headless-write-probe: passed
headless-write-probe-verified-on: 1.1.20
headless-write-probe-history: 1.1.4 (2026-07-18), 1.1.20 (2026-08-25)
# (The legacy `probe-version` / `probe-date` keys from the 2026-07-18 walk
# are retired — superseded by the headless-write-probe-* keys above; their
# information lives in the history line. Flagged by the Antigravity peer
# review 2026-08-25 as schema ambiguity.)
---

# Antigravity CLI — vendor knowledge

Single file. One vendor. Every claim carries a `[STABLE]` / `[MEDIUM]` /
`[VOLATILE]` tag and a URL citation. Walked weekly by
[`refresh-vendor.md`](../../protocols/refresh-vendor.md);
change-marker semantics (no edit on no-op). Linked from the README at
[`markdowns/agents/README.md`](../README.md).

**Install:** `curl -fsSL https://antigravity.google/cli/install.sh | bash`
(places `agy` at `~/.local/bin/agy`).

**Auto-update (observed 2026-11-08).** Any `agy` invocation — including
non-agent subcommands such as `agy models` — can spawn the background
auto-updater. During the 2026-11-08 refresh walk the binary moved
1.4.12 → 1.5.3 mid-walk (`cli.log`: `auto_updater.go:334 Spawned
background update process`; prior binary kept as
`~/.local/bin/agy.<id>.old`). Consequence: a probe taken on version X can
be invalidated by an unattended update before dispatch — the dispatcher's
verified-on == installed gate catches this and fails closed. An
`AGY_CLI_DISABLE_AUTO_UPDATE` string exists in the 1.5.3 binary;
`low-confidence` — strings-only, untested, undocumented. `[VOLATILE]`
(`agy` cli.log + `updater/update_status.json` 2026-11-08; `strings` on
binary 1.5.3)

## Installer behavior (verified 2026-07-18 against agy v1.1.4; re-checked 2026-11-08)

- **The bootstrap and native setup command have different flag sets.**
  The fetched `install.sh` bootstrap parses only `-d/--dir` and
  `-h/--help`, then delegates shell configuration to `agy install`.
  `agy install --help` v1.1.4 additionally exposes `--skip-aliases`
  and `--skip-path`. Do not pass those flags to the curl-piped bootstrap;
  invoke the installed binary's setup subcommand when they are needed.
- **Default setup can still modify shell profiles.** The bootstrap invokes
  `agy install` without either skip flag. The current script was inspected,
  not executed as a fresh install, so the exact profile edits remain a
  source-level claim rather than a second destructive empirical test.
- **`-d /custom/path` now isolates the binary target.** The current
  bootstrap replaces the default target with the custom directory and writes
  one binary there; the former duplicate-at-`~/.local/bin/agy` behavior is no
  longer present in the script.
- **Claim-vintage map.** Executable flag claims and the safety probe below
  were verified against local `agy` v1.1.4 on 2026-07-18. Release behavior
  between v1.0.8 and v1.1.4 is anchored to the official repo CHANGELOG and
  v1.1.4 release notes. Antigravity's docs pages remained SPA-rendered and
  empty through WebFetch, and the in-app browser was unavailable; claims that
  depend only on those pages remain explicitly unverified.
- **2026-11-08 re-check.** The fetched `install.sh` (read as text, not
  executed) still parses only `-d/--dir` and `-h/--help` and hands off to
  `"$BINARY_PATH" install` (or `install --dir "$CUSTOM_DIR"`) with no skip
  flags. `agy install --help` 1.5.3 lists `--dir`, `--skip-aliases`,
  `--skip-path`. **Docs channel change:** antigravity.google docs pages are
  no longer SPA-blocked — `/docs/cli/reference`, `/docs/cli/headless`,
  `/docs/cli/using`, `/docs/hooks`, `/docs/mcp`, `/docs/subagents`,
  `/docs/rules`, `/docs/plans`, `/docs/install` and `/pricing` all fetched
  as server-rendered text (via a summarizer; quotes are as relayed). The
  docs URL scheme moved from `/docs/cli-*` to `/docs/cli/*` (`/docs/cli-using`
  redirects to `/docs/cli/using`); citations below are re-pointed.
  `[MEDIUM]`

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
10. Gaps / Antigravity-CLI-down notes

## Volatility legend

Each claim's tag describes how often the underlying content tends to
change:

- **`[STABLE]`** — major version bumps only (rare).
- **`[MEDIUM]`** — minor version bumps or quarterly cadence.
- **`[VOLATILE]`** — monthly or faster.

A weekly calendar reminder triggers the cadence — when it fires, open
Claude Code in the repo and type `/refresh-vendor antigravity-cli`.
That supervised session walks every claim regardless of tier.

The `last-verified` frontmatter date is the date of the **last applied
change**, not the date of the last walk. Walk dates live in
[`markdowns/agents/refresh-log.md`](../refresh-log.md).

**Adoption context.** Antigravity CLI is Google's coding CLI for the
Google AI Pro / Ultra / free tier. Its config root inherits from
`~/.gemini/` for filesystem-path continuity with the prior tooling
generation — operational fact, not a vendor we track.
Source: [antigravity.google/docs/features?tab=cli](https://antigravity.google/docs/features?tab=cli)
(formerly cited as `/docs/cli-overview`).

---

## 1. Canonical instructions file

- **Settings file location:** `~/.gemini/antigravity-cli/settings.json`.
  The parent directory is `~/.gemini/` — Antigravity's chosen config
  root path. Local v1.1.4's bundled `antigravity_guide` identifies this as
  the authoritative CLI settings file and enumerates
  `toolPermission`, `enableTerminalSandbox`,
  `allowNonWorkspaceAccess`, and `artifactReviewPolicy`. All four keys are
  still present as strings in the 1.5.3 binary; the dispatcher-checked
  values (`toolPermission: "strict"`, `enableTerminalSandbox: true`) are
  present in the local global file (read-only check 2026-11-08). The
  execution-mode setting key is `agentMode` (same values as `--mode`).
  `[STABLE]`
  ([antigravity.google/docs/cli/using](https://antigravity.google/docs/cli/using),
  [antigravity.google/docs/cli/reference](https://antigravity.google/docs/cli/reference))
- **Session-only settings flag:** `--settings` — "Settings for this session
  only, never saved: a JSON object of settings.json keys, inline or as a
  file path" (`agy --help` 1.4.12 and 1.5.3). Not in the docs or changelog;
  semantics untested. `low-confidence` `[MEDIUM]`
- **Native `AGENTS.md` lookup — DOCUMENTED first-party, was TBD.**
  Antigravity treats `AGENTS.md` and `GEMINI.md` as always-on rule files:
  "`AGENTS.md` and `GEMINI.md` do not use frontmatter … Antigravity treats
  its entire content as plain Markdown and keeps it continuously active
  (`always_on`)", scoped to "your workspace, including parent folders up to
  the repository root" (it "doesn't load rules from subfolders below the
  workspace folder"). The bundled first-party `agy-customizations` skill
  says the same: the system "walks up from the current working directory to
  the repository root and loads these files". Changelog 1.4.4 fixed the
  system-prompt wording "so `GEMINI.md` and `AGENTS.md` rules explicitly
  override earlier built-in instructions"; 1.2.15 covers global
  `~/.gemini/AGENTS.md` / `~/.gemini/config/AGENTS.md`. Per-file cap 24 KB;
  always-on + global rules share a 20,000-token budget (bundled `rules.md`).
  Docs-confirmed, **not verified by execution**. Upstream open issue
  [#1002](https://github.com/google-antigravity/antigravity-cli/issues/1002)
  reports the harness dropping `AGENTS.md` rules across turns. The earlier
  community source's `agy inspect` claim stays refuted (no `inspect`
  subcommand in `agy --help` 1.5.3). `[MEDIUM]`
  ([antigravity.google/docs/rules](https://antigravity.google/docs/rules),
  bundled `~/.gemini/antigravity-cli/builtin/skills/agy-customizations/docs/rules.md`,
  `agy changelog` 1.2.15/1.4.4)
- **Project `context.fileName` override — unverified, possibly inert.**
  [`.gemini/settings.json`](../../../.gemini/settings.json) carries
  `context.fileName: ["AGENTS.md"]`, a Gemini-CLI-era key. It appears on no
  agy docs page fetched 2026-11-08, and the only `fileName` string in the
  1.5.3 binary belongs to an unrelated struct. Per
  [`evidence-discipline.md`](../../protocols/evidence-discipline.md) §4 that
  is absence of evidence, not proof the key is ignored — **not removed.**
  The file must stay regardless: it also carries the project hardening keys
  (`allowNonWorkspaceAccess`, `artifactReviewPolicy`) that
  `cross-vendor-review.sh` checks before dispatch. `low-confidence`
  `[MEDIUM]`
- **Hierarchical lookup:** partially resolved — the permission system
  merges **three config tiers**: project-level permissions, user
  settings shared with Antigravity, and the CLI `settings.json`
  (CHANGELOG v1.0.5). Project-specific configurations under
  `~/.gemini/config/projects/` take precedence over global CLI settings
  (v1.0.12). The repo-local `.gemini/settings.json` remains the context-file
  adapter and defense-in-depth policy declaration; the 2026-07-18 headless
  probe established that the global CLI settings file is the load-bearing
  policy channel when no active workspace is resolved. `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.5/v1.0.12)
- **Repo posture.** AGENTS.md is the canonical instructions file.
  Antigravity reads it natively as an always-on rule (docs-confirmed,
  above); the `.gemini/settings.json` `context.fileName` entry is kept as
  an unverified belt-and-braces adapter, and the file itself is required
  for the dispatcher's hardening checks. The pre-commit hook auto-mirrors
  AGENTS.md to CLAUDE.md for Claude Code's native lookup. No new repo file
  required. `[MEDIUM]`

---

## 2. Skills / protocols

- **First-party skills primitive — open Agent Skills standard.**
  Skills are self-contained directories anchored on a `SKILL.md`
  file; `SKILL.md` is the only required file, with optional `scripts/`,
  examples, and resource templates alongside it. Antigravity "strictly
  follows the open Agent Skills standard" and Google ships an official
  Codelab on authoring them. `[STABLE]`
  ([antigravity.google/docs/skills](https://antigravity.google/docs/skills),
  [codelabs.developers.google.com/getting-started-with-antigravity-skills](https://codelabs.developers.google.com/getting-started-with-antigravity-skills))
- **Discovery locations — CONFIRMED 2026-06-20.** Workspace skills load
  from `<workspace-root>/.agents/skills/<skill-folder>/`; global skills
  from `~/.gemini/config/skills/<skill-folder>/` according to the current
  Google Codelab. Antigravity
  **defaults to `.agents/skills`**, with backward compatibility for the
  older `.agent/skills` directory. The `/skills` slash command browses
  loaded local + global skills inside the TUI. **Re-confirmed 2026-11-08:**
  the global path `~/.gemini/config/skills/` is a string literal in the
  1.5.3 binary, and the bundled first-party `agy-customizations` skill
  lists workspace customization roots `.agents/` (or `.agent/`,
  `_agents/`, `_agent/`), discovered walking from the working directory up
  to the repository root. (The 2026-06-20 refresh-log line's
  `~/.gemini/antigravity/skills/` is wrong; this file's path is right.)
  `[STABLE]`
  ([antigravity.google/docs/skills](https://antigravity.google/docs/skills),
  [antigravity.google/docs/cli/reference](https://antigravity.google/docs/cli/reference),
  bundled `agy-customizations/SKILL.md`, `strings` on binary 1.5.3)
- **Skill manifests + limits (1.2.x–1.5.x).** `skills.json` / `plugins.json`
  in a customization root register extra paths; each entry directory is
  scanned **one level deep** (1.2.10 — previously recursive; nested items
  need `include_only`), manifests are honored in every `.agents/` between
  the working directory and the project root (1.2.16), and since 1.5.2
  workspace manifest entries load only from inside the workspace/repo root
  (absolute, `../`, or symlinked entries pointing elsewhere are skipped).
  `/skills reload` reloads without a restart (1.2.4). `SKILL.md` body limit
  24 KB (1.4.1, `agy plugin validate`). `[MEDIUM]`
  (`agy changelog` 1.2.4/1.2.10/1.2.16/1.4.1/1.5.2, bundled
  `agy-customizations/docs/json_configs.md`)
- **Plugins are now first-party distribution.** `agy plugin` /
  `agy plugins` subcommand (`list [--json]`, `import [source]` from gemini
  or claude, `install <target>` with `plugin[@marketplace]`, `uninstall`,
  `enable`, `disable`, `validate [path] [--strict] [--json]`, `link`) and
  the `/plugin` marketplace manager (1.3.2). Plugins bundle skills, MCP
  servers, subagents, rules and hooks. 1.5.2 hardened plugin name/path
  handling so an imported plugin can no longer overwrite other config files
  such as `mcp_config.json`. `[MEDIUM]` (`agy plugin --help` 1.5.3,
  `agy changelog` 1.3.2/1.5.2)
- **Plugin-based skill/agent discovery:** the CLI scans installed
  plugin directories and exposes their skills and specialized agents
  for execution (CHANGELOG v1.0.1); plugins install to the shared
  config dir `~/.gemini/config/` (v1.0.2 path fix); plugins are
  installable from GitHub subpaths with branch resolution (v1.0.7).
  Skill-derived slash commands execute from autocomplete (v1.0.4 fix).
  `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.1/v1.0.2/v1.0.4/v1.0.7)
- **Bundled guide + dynamic reload.** v1.0.10 added the built-in
  `antigravity_guide` skill. v1.0.8 fixed dynamic reloading of custom skills
  and system slash commands after conversation switches and `/add-dir`, so
  newly discovered skills no longer require a full CLI restart. `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.8/v1.0.10)
- **Cross-vendor `.agents/skills/` compatibility — CONFIRMED, was TBD.**
  The 2026-06-10 walk flagged this as a low-confidence community signal
  not corroborated by official channels. Now corroborated by the
  official Antigravity skills docs + Google Codelab: workspace skills
  load from `.agents/skills/` per the open Agent Skills standard. This
  template's root [`.agents/skills/`](../../../.agents/skills/) is read
  by Antigravity natively — no Antigravity-side mirror needed. `[STABLE]`
  ([antigravity.google/docs/skills](https://antigravity.google/docs/skills))

---

## 3. Subagents (parallel?)

- **Subagents exist.** The `/agents` slash command opens the Agent
  Manager Panel to monitor background subagents per
  [antigravity.google/docs/cli/reference](https://antigravity.google/docs/cli/reference).
  The dedicated [antigravity.google/docs/subagents](https://antigravity.google/docs/subagents)
  page was walked 2026-11-08 (claims below). "Each subagent starts with a
  clean context and runs in its own conversation, in parallel with your
  main conversation"
  ([docs/features?tab=cli](https://antigravity.google/docs/features?tab=cli)).
  1.2.9 added `@<subagent> <message>` to message a subagent directly.
  `[MEDIUM]`
- **Default subagent interaction timeout: 60 s.** A v1.0.2 fix
  "restricted the default 60-second interaction timeout specifically
  to subagents" — i.e. the 60 s default no longer applies to the main
  agent (whether the main agent has another cap is not stated; §9's
  `--print-timeout` — default `0s`, unlimited, since 1.2.6 — governs
  headless runs). Subagent
  conversations are excluded from `/resume` (v1.0.6). `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.2/v1.0.6)
- **Custom agents and nested subagents are first-party.** v1.1.1 added the
  `--agent` launch flag plus `agent` / `agents` subcommands and recursively
  relays nested-subagent state and confirmations to the root conversation.
  Dynamic subagent definitions use Markdown rather than JSON as of v1.0.16.
  Local `agy --help` and `agy agent --help` v1.1.4 confirm the launch flag and
  listing subcommands. `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.16/v1.1.1)
- **Subagent execution posture changed.** v1.0.14 enabled always-proceed
  artifact handling for subagents to prevent hangs while the parent is
  blocked; v1.1.1 added recursive confirmation routing for nested depths.
  Treat this as orchestration behavior, not evidence of an unrestricted
  filesystem policy. `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.14/v1.1.1)
- **Per-agent model — DOCUMENTED as a TIER field (was changelog-indicated).**
  `[MEDIUM]` The subagents docs list `model` with default `inherit`:
  "Model tier used when invoked (`inherit`, `flash`, or `pro`)." So a
  definition pins a **tier**, not an arbitrary model ID. The 1.1.16
  changelog fix ("a subagent whose definition leaves `model` at `inherit`
  failing to start when the parent agent has no model of its own, which
  now falls back to the default fast tier") is consistent with that.
  1.5.0 names the built-in `pro` and `flash` subagents; 1.5.3 shows "each
  subagent's model next to its name" in the subagent rows and `/agents`,
  with "the full model and effort in a subagent's detail view, and a
  `model` field on each `subagents` entry in the status line JSON" — an
  observation surface that makes a behavioral test cheap. **Still
  `low-confidence`:** the runtime behavior of `inherit` — the changelog
  defines it as the parent's model (1.1.5: "defaulting to `inherit` (the
  parent's model)") with a fast-tier fallback when the parent has none
  (1.1.16), but neither is observed — and whether a pin is honored — no delegate-and-observe test has been run.
  Model facts themselves live in
  [`model-capabilities.md`](../model-capabilities.md) (SSOT).
  ([antigravity.google/docs/subagents](https://antigravity.google/docs/subagents),
  `agy changelog` 1.1.16/1.5.0/1.5.3)
- **Agent-definition location + frontmatter.** Markdown with YAML
  frontmatter. Docs-listed fields: `name` and `description` (required),
  `tools`, `mainAgent` (default true), `subagent` (default true), `model`
  (default `inherit`), `commandExecutionPolicy` (default `sandbox`),
  `mcpServers`, `skills` / `plugins`. Changelog adds `agents:` (declared
  subagent dependencies, 1.1.27), `excludeDefaultComponents: true`
  (1.2.1), `rules:` (1.1.15), relative `skills:`/`plugins:`/`rules:`/
  `agents:`/`hooks:` paths resolving against the agent file (1.3.1), and
  `inherit_user` (1.1.14). **Inheritance default changed:** 1.1.25 "Changed
  custom agents defined in Markdown to inherit ambient skills, rules, and
  subagents by default" — supersedes the 1.1.14 `inheritCustomizations`
  framing as the default. **Location:** project custom agents live in
  `.agents/agents/` (1.2.11 fixed them not being found under `--agent`,
  in headless `-p` runs, and in `/agents`); plugins may ship `agents/`
  Markdown files and a root `agents.json` (1.3.3). Custom agents listing
  `invoke_subagent` receive the subagent roster in their system prompt
  (1.2.5). `agy agents` 1.5.3 printed nothing in this repo (no custom
  agents defined). `[MEDIUM]`
  ([antigravity.google/docs/subagents](https://antigravity.google/docs/subagents),
  `agy changelog` 1.1.14–1.3.3, `agy agents` 1.5.3)
- **Subagent tool surface:** `define_subagent`, `invoke_subagent`,
  `manage_subagents`, `send_message`, `manage_task`. ⚠️ Security note:
  1.1.13 fixed `define_subagent` using a model-supplied agent name
  directly as a directory name, so a name containing `..` could write
  its `agent.md` **outside** the conversation's artifact directory.
  Anything pinned below 1.1.13 carries that path-traversal bug.
  `[MEDIUM]` (`agy changelog` 1.1.13)
- **Nesting cap — DOCUMENTED (was absence-of-evidence).** The subagents
  docs state "A maximum nesting depth of 10 levels", "strictly enforced to
  prevent runaway recursion or resource exhaustion." Docs-only — not
  verified by execution; no config knob to change it was found. The prior
  "Antigravity exposes no documented fan-out ceiling" framing is retired
  for **depth**. `[MEDIUM]`
  ([antigravity.google/docs/subagents](https://antigravity.google/docs/subagents))
- **Parallel-spawn / concurrency cap:** still **TBD**. The docs say only
  that a parent can invoke multiple subagents concurrently; no
  max-concurrent / `max_threads` equivalent was found in the docs, the
  1.1.21–1.5.3 changelog, or the bundled customization skill. Per
  [`evidence-discipline.md`](../../protocols/evidence-discipline.md) §4
  this is absence of evidence (channels: docs/subagents,
  docs/features, `agy changelog` 1.1.21–1.5.3, bundled skills), not
  evidence of absence. `low-confidence` `[MEDIUM]`

---

## 4. Hooks

- **Hooks exist.** The `/hooks` slash command browses active
  pre-flight / post-format script hooks per
  [antigravity.google/docs/cli/reference](https://antigravity.google/docs/cli/reference).
  The dedicated [antigravity.google/docs/hooks](https://antigravity.google/docs/hooks)
  page was fetchable 2026-11-08 (no longer SPA-blocked). `[MEDIUM]`
- **Event set — DOCUMENTED (6 events).** `SessionStart`, `PreToolUse`,
  `PostToolUse`, `PreInvocation`, `PostInvocation`, `Stop`. Tool events
  (`PreToolUse`/`PostToolUse`) use a grouped `matcher` (regex on tool name,
  e.g. `run_command`) + `hooks` wrapper; the others take a flat handler
  list. `hooks.json` is keyed by **named hook** (each name maps to its
  events, with optional `"enabled": false`) — a Claude-Code-style
  top-level `"hooks"` key loads as a single hook *named* `hooks` (1.4.3
  `agy plugin validate` warning). `[MEDIUM]`
  ([antigravity.google/docs/hooks](https://antigravity.google/docs/hooks),
  bundled `agy-customizations/docs/hooks.md`, `agy changelog` 1.4.3)
- **Configuration contract — DOCUMENTED, was TBD/community-only.** "Hooks
  receive input through stdin as JSON and return output through stdout as
  JSON. Field names use camelCase." Common stdin fields: `conversationId`,
  `workspacePaths`, `transcriptPath`, `artifactDirectoryPath`, `modelName`,
  `lastUserInput` (1.4.7). `PreToolUse` stdout requires `decision` —
  docs list `allow`, `auto_approve`, `deny`, `ask`, `force_ask`,
  `deny_unless_prior_grant` (the bundled 1.4.12-era skill lists only
  `allow`/`deny`/`ask`/`force_ask`) — plus optional `reason`, `overwrite`
  (shallow merge into tool args), `permissionOverrides`. `PreInvocation` /
  `PostInvocation` may return `injectSteps` and `terminationBehavior`
  (`terminate`; `force_continue` on Post); an injected `errorMessage`
  "makes a `-p` run exit with a non-zero code" (1.4.11). `Stop` returns
  `decision: "continue"` to keep the loop running. Only `type: "command"`
  handlers (`sh -c` on Unix; cwd = the `hooks.json` directory); default
  timeout 30 s; hooks run synchronously. Hook exit-code semantics are NOT
  documented. Docs-confirmed, **not verified by execution** — no local hook
  probe run. Upstream open issue
  [#1053](https://github.com/google-antigravity/antigravity-cli/issues/1053):
  "`PreToolUse` hook returning `decision: "allow"` does not allow the
  call." `low-confidence` on runtime behavior. `[MEDIUM]`
  ([antigravity.google/docs/hooks](https://antigravity.google/docs/hooks),
  bundled `agy-customizations/docs/hooks.md`, `agy changelog` 1.4.7/1.4.11)
- **Configuration paths.** Workspace hooks use `.agents/hooks.json`
  (v1.1.1 fixed reload after a folder was trusted); global hooks use
  `~/.gemini/config/hooks.json` (v1.0.8 path fix); plugins may ship a
  `hooks.json` (CLI only; a plugin's `hooks/hooks.json` is not read —
  1.4.3). Hooks placed in `~/.gemini/antigravity-cli/settings.json` are not
  loaded (docs). Both paths are string literals in the 1.5.3 binary.
  Plugin hooks get `PLUGIN_ROOT` / `PLUGIN_DATA` env vars (1.5.3). `/btw`
  side questions no longer run user/workspace hooks (1.3.3). `[MEDIUM]`
  ([antigravity.google/docs/hooks](https://antigravity.google/docs/hooks),
  [CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.8/v1.1.1,
  `agy changelog` 1.3.3/1.4.3/1.5.3, `strings` on binary 1.5.3)
- **Repo posture:** hooks stay Claude-only by default. Antigravity
  hooks portabilized only when the hook prevents a destructive
  non-code action (rare). `[STABLE]`

---

## 5. Auth

- **Default mode:** "Sign in with Google" — OAuth flow via the
  Antigravity OAuth callback endpoint
  (`https://antigravity.google/oauth-callback`). First run opens a
  browser; on completion, tokens are stored in the system keyring.
  `[STABLE]`
  ([antigravity.google/docs/install](https://antigravity.google/docs/install),
  observed during local install 2026-05-28)
- **Device-code flow for SSH / headless environments:** Antigravity
  CLI detects SSH sessions and prints an authorization URL plus a
  one-time code; user opens the URL on a local machine, pastes the
  code. `[STABLE]`
  ([github.com/google-antigravity/antigravity-cli README](https://github.com/google-antigravity/antigravity-cli))
- **Credential storage:** system keyring on supported platforms — "the
  CLI attempts to access your operating system's native secure keyring"
  (docs/install). **Fallbacks now changelog-anchored:** the keyring is
  bypassed when no D-Bus session bus is present (headless hosts,
  containers — 1.1.3); `/logout` short-circuits to file storage "when
  keyring storage is bypassed or unreachable" (1.1.26); plugin/MCP and
  enterprise tokens too large for the macOS/Windows keychain are stored
  "in the CLI's private secrets file" (1.4.6/1.4.7). `[MEDIUM]`
  ([antigravity.google/docs/install](https://antigravity.google/docs/install),
  `agy changelog` 1.1.3/1.1.26/1.4.6/1.4.7)
- **`/logout` slash command:** disconnects the active profile and
  purges tokens from the keyring per
  [antigravity.google/docs/cli/reference](https://antigravity.google/docs/cli/reference).
  `[STABLE]`
- **Alternate auth routes — RESOLVED, was TBD.** `[MEDIUM]`
  - **Gemini API key:** "Export your key as GEMINI_API_KEY" — and "Only
    setting a GEMINI_API_KEY environment variable on its own has no
    effect"; settings must also set `modelProvider: "gemini"` (1.1.13;
    `GOOGLE_GEMINI_BASE_URL` overrides the endpoint).
  - **Application Default Credentials:** "Enable ADC in the CLI by
    setting AGY_ADC_AUTH=true" (added 1.1.10; quota project auto-resolved
    1.1.12). Remote Control does not support ADC (1.3.3).
  - **Workload Identity Federation** OAuth tokens are refreshed
    proactively (1.1.23); **enterprise model gateways** and **Vertex AI**
    are supported backends (1.5.3 fixes).
  - **Billing choice:** "Added a billing model choice after you sign in
    with Google Cloud, so you can pick either a Gemini subscription or Pay
    As You Go." (1.4.11)
  ([antigravity.google/docs/install](https://antigravity.google/docs/install),
  [antigravity.google/docs/cli/reference](https://antigravity.google/docs/cli/reference),
  `agy changelog` 1.1.10/1.1.12/1.1.13/1.1.23/1.3.3/1.4.11/1.5.3)
- **Cross-vendor parity:** Antigravity defaults to Google OAuth.
  Per-vendor subscription posture lives in each vendor's knowledge file.
  (Corrected 2026-11-08: the prior sentence ended in a dangling citation —
  "subscription-only in this repo per ." — present since the initial
  commit with no recoverable target; aligned with the sibling files'
  wording.) `[STABLE]`

---

## 6. Rate limits — `[VOLATILE]`

**Re-verify before relying.** The official
[`/docs/plans`](https://antigravity.google/docs/plans) page was fetchable
2026-11-08; it describes quota *shape* per tier but publishes **no
absolute numbers**.

- **Tier structure (docs/plans, 2026-11-08):** Ultra — "The highest, most
  generous quota, refreshed every five hours" and "The highest weekly
  rate limits"; Pro — "A high, generous quota, refreshed every five hours
  until the weekly limit is reached" and "A higher weekly rate limit";
  free — "A meaningful quota, refreshed weekly" and "A weekly rate limit".
  "The baseline rate limits are primarily determined by available
  capacity and exist to prevent abuse." Enterprise per-seat quota not
  documented on these pages. Absolute per-window quotas: **not
  published** (docs/plans, /pricing). `[VOLATILE]`
  ([antigravity.google/docs/plans](https://antigravity.google/docs/plans),
  [developers.googleblog.com](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/))
- **Real-time quota introspection:** `/usage` and `/quota` slash
  commands force a live reload of model configuration and remaining
  quotas, showing real-time consumption (v1.0.1). Since 1.1.11 the
  read-only slash commands answer non-interactively in print mode
  (`-p "/usage"`, `/quota`, `/credits`, `/model`, `/effort`, `/skills`)
  with tab-separated or structured output; 1.2.15 prints local-time reset
  times to a terminal, UTC when piped / `--json`. Not exercised this walk
  (no `-p` runs). `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.1,
  `agy changelog` 1.1.11/1.2.15)
- **Rate-limit handling in the CLI:** waits the server-requested retry
  delay and "stops right away instead of retrying when the delay is
  longer than 30 seconds or the quota is a daily or billing cap" (1.2.13);
  reaching an individual quota is reported immediately (1.3.3); `429` /
  `5xx` honor `Retry-After` (1.5.0). `[MEDIUM]` (`agy changelog`
  1.2.13/1.3.3/1.5.0)
- **Credits overflow — renamed "AI credits" in UI/docs.** Originally "G1
  credits" (v1.0.3: `UseG1Credits` setting, status-bar balance,
  `/credits` purchase panel). Docs now say only "AI credits": "Users on
  Google AI Pro or Ultra plans can use purchased AI credits", "consumed at
  standard Gemini Enterprise consumption pricing", controlled by an "AI
  Credit Overages" setting (Never / Always). The `UseG1Credits` /
  `useG1Credits` key name is still present in the 1.5.3 binary (strings).
  `[VOLATILE]`
  ([antigravity.google/docs/plans](https://antigravity.google/docs/plans),
  [CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.3,
  `agy changelog` 1.2.15, `strings` on binary 1.5.3)
- **Recovery posture:** on rate-limit hit, abort and re-run via
  `cross-vendor-review.sh --to <other-vendor>`. No automatic API-key
  fallback. `[STABLE]`

---

## 7. Cost

- **Pricing tiers** follow the Google AI consumer subscription
  family per Google's announcement
  ([developers.googleblog.com](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/)).
  From the primary pricing page (2026-11-08): **Free — $0** ("Experience
  Antigravity without a subscription plan", basic weekly rate limits);
  **Business via Google Cloud — "Standard/Plus plans start at $30 USD per
  seat per month"**, plus a pay-as-you-go plan with no seat fee and
  consumption pricing. The CLI is a baseline feature on all plans ("Access
  to all product features, such as scheduled tasks and the CLI" —
  docs/plans). **Pro / Ultra prices are not published on any primary page
  reached** — still TBD (secondary-source figures deliberately not
  recorded). `[VOLATILE]`
  ([antigravity.google/pricing](https://antigravity.google/pricing),
  [antigravity.google/docs/plans](https://antigravity.google/docs/plans))
- **Per-call cost in print mode:** ⚠️ **CORRECTED 2026-11-08** — the old
  claim ("no JSON-shaped usage statistics block is documented") is
  superseded. `--output-format json` returns an envelope with a `usage`
  object (`input_tokens`, `output_tokens`, `thinking_tokens`,
  `cache_read_tokens`, `total_tokens`) plus `duration_seconds` /
  `num_turns`; the status line also exposes an estimated session `cost`
  field (1.1.21). Token counts, not currency, in the JSON envelope.
  Docs-only; not exercised (no `-p` runs). `[MEDIUM]`
  ([antigravity.google/docs/cli/headless](https://antigravity.google/docs/cli/headless),
  `agy changelog` 1.1.21)
- **Credit top-ups:** AI credits (formerly "G1 credits") are purchasable
  in-product via the `/credits` panel and spend on quota exhaustion per
  the AI Credit Overages setting (see §6). `[VOLATILE]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.3,
  [antigravity.google/docs/plans](https://antigravity.google/docs/plans))

---

## 8. MCP (client + server)

- **As client:** stable. Two transports — **stdio** (local executable)
  and **Streamable HTTP** (remote URL with optional OAuth + custom
  headers). ⚠️ **Config location CORRECTED 2026-11-08** — was
  `~/.gemini/antigravity-cli/config/mcp_config.json`. Actual: **global
  `~/.gemini/config/mcp_config.json`** plus **workspace
  `<workspace>/.agents/mcp_config.json`** ("Antigravity CLI loads MCP
  server definitions from two configuration files"), and
  `plugins/<plugin>/mcp_config.json` for plugin-bundled servers. The
  schema is a top-level `mcpServers` object inside `mcp_config.json`
  (this resolves the old "docs say `mcpServers` in `settings.json`" NOTE:
  the key is right, the file is `mcp_config.json`). Corroborated by three
  channels: the docs page, the bundled first-party
  `agy-customizations/docs/mcp_servers.md`, a `~/.gemini/config/mcp_config.json`
  string literal in the 1.5.3 binary, and the local filesystem (the file
  exists there; no `~/.gemini/antigravity-cli/config/` directory exists).
  Stdio: `command`, `args`, `env`. Streamable HTTP: `url` (legacy
  `serverUrl` accepted). **The legacy HTTP+SSE transport is not
  supported** — bridge SSE-only servers via a stdio proxy. Plugin MCP
  servers are namespaced `<plugin>_<server>` (1.2.2); `mcp_config.json`
  tolerates comments / trailing commas (1.1.24); servers may mark a tool
  always-loaded via `_meta: {"antigravity/alwaysLoad": true}` (1.3.3);
  `tools/call` carries `_meta["antigravity.google/root_conversation_id"]`
  (1.4.4). Historical: v1.0.3 migrated a legacy top-level path; launch
  timeout configurable with `-1` to disable (v1.0.7); default connection
  timeout 60 s (v1.0.15); parallel init (v1.0.4). Not exercised by `agy
  mcp add` this walk (mutating). `[MEDIUM]`
  ([antigravity.google/docs/mcp](https://antigravity.google/docs/mcp),
  bundled `agy-customizations/docs/mcp_servers.md`, `strings` on binary
  1.5.3, local filesystem 2026-11-08,
  [CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.3–v1.0.15,
  `agy changelog` 1.1.24/1.2.2/1.3.3/1.4.4)
- **`agy mcp` subcommands (verified by execution, 1.5.3):** `add`,
  `remove`, `list`, `enable`, `disable`. `agy mcp add [flags] <name>
  <commandOrUrl> [args...]` with `-t/--type` (`stdio` default | `http`;
  http/https URLs auto-detected), `-H/--header` and `-e/--env`
  (repeatable); flags must precede `<name>`; `--` passes args beginning
  with `-`. `agy mcp list` → "No MCP servers configured." on this machine.
  `[MEDIUM]` (`agy mcp --help`, `agy mcp add --help`, `agy mcp list` 1.5.3)
- **OAuth 2.0 supported** for HTTP servers via the
  `oauthClientCredentials` object on the server config. `[STABLE]`
  Not re-verified 2026-11-08 — the field is absent from the bundled
  1.4.12-era MCP doc and was not quoted from the docs page this walk;
  OAuth sign-in for MCP servers is changelog-evident (1.2.15, 1.5.2).
  `low-confidence` on the exact field name.
  ([antigravity.google/docs/mcp](https://antigravity.google/docs/mcp))
- **As MCP server: NOT first-party.** No `agy mcp serve` command exists;
  the docs at
  [antigravity.google/docs/mcp](https://antigravity.google/docs/mcp)
  describe Antigravity only as an MCP client, and `agy --help` /
  `agy help` 1.5.3 expose no MCP server subcommand. **Comparison flipped
  2026-11-08:** `codex mcp-server` was removed in Codex 0.154.0 (see
  [`codex-cli.md`](codex-cli.md) §8), so **neither Codex nor Antigravity
  ships an MCP server mode** (Claude Code does: `claude mcp serve`) —
  Antigravity no longer "stands alone" among the review peers.
  **Different protocol, server mode exists:** `agy acp` (1.5.0) "runs the
  CLI as an Agent Client Protocol (ACP) server over stdio, so editors can
  use it as their agent" — ACP, not MCP. `agy help acp` 1.5.3 lists its
  flags (`--agent`, `--add-dir`, `--sandbox`,
  `--dangerously-skip-permissions`, `--login`, `--process-per-session`,
  `--stdio` default transport, among others). Verified as a subcommand by
  execution; ACP behavior not exercised. `[STABLE]` for "no MCP server";
  `[MEDIUM]` for `agy acp`.
  (`agy --help` / `agy help acp` 1.5.3, `agy changelog` 1.5.0)
- **Cross-vendor posture:** MCP cross-vendor servers still deferred —
  shell invocation via
  [`cross-vendor-review.sh`](../../../scripts/cross-vendor-review.sh)
  remains today's answer. NOTE: the documented revisit trigger ("any
  peer vendor ships first-party MCP server") **fired 2026-06-10** via
  the Codex walk; the posture re-evaluation was deferred by the
  supervisor to its own session. As of 2026-11-08 no peer ships an MCP
  server mode (Codex removed it in 0.154.0); whether an ACP server mode
  (`agy acp`) counts toward the trigger is an open supervisor question,
  not decided here. `[STABLE]`

---

## 9. Headless invocation

- **Entry point:** `agy --print "<prompt>"` (short alias `agy -p`;
  alias `agy --prompt`). Runs a single prompt non-interactively and
  prints the response. Prompts are read only from `-p/--print`,
  `-i/--prompt-interactive`, or stdin; a stray positional argument is a
  hard error ("Error: unexpected argument …", exit **2**, executed on
  1.5.3). `[STABLE]`
  ([antigravity.google/docs/cli/reference](https://antigravity.google/docs/cli/reference),
  [antigravity.google/docs/cli/headless](https://antigravity.google/docs/cli/headless),
  `agy --help` 1.5.3)
- **Timeout:** ⚠️ **CHANGED** — `--print-timeout` default is now **`0s`**
  ("Optional time limit for print mode; 0 waits until the turn
  completes"); was `5m0s`. 1.2.6: "Changed the default timeout for
  headless (`-p` / `--prompt`) runs from 5 minutes to unlimited". The
  dispatcher passes `--print-timeout 5m` explicitly, so it is unaffected by
  the default. Expiry semantics: see the 2026-11-08 warnings below.
  `[MEDIUM]` (was `[STABLE]`) (`agy --help` 1.4.12/1.5.3, `agy changelog`
  1.2.6, [docs/cli/headless](https://antigravity.google/docs/cli/headless))
- **Model selection:** `--model` flag sets the model at launch; the
  `models` subcommand lists available models (both added v1.0.5).
  `--effort` (low|medium|high|xhigh|max) selects reasoning effort
  separately (1.1.5; 1.2.11 per-model support); since 1.3.4 `--model`
  accepts a base model name without `--effort` and picks the model's
  default thinking level. **The `agy models` catalog is server-side and
  account-dependent** ("Fetching available models..."): on this account it
  listed 6 entries at both 1.4.12 and 1.5.3, while the binary carries
  strings for models not offered to this account; 1.3.6: "Claude models
  now appear in `/model` only if your Google Cloud project can use them."
  Model inventory and rates live in
  [`model-capabilities.md`](../model-capabilities.md) (SSOT) — not
  restated here. `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.5,
  `agy --help` / `agy models` 1.4.12 + 1.5.3, `agy changelog`
  1.1.5/1.2.11/1.3.4/1.3.6)
- **Sandbox flag:** `--sandbox` activates terminal-command sandboxing
  via native OS containment (nsjail on Linux, sandbox-exec on macOS,
  AppContainer on Windows). Restricts SHELL execution by the agent;
  **does NOT block file-write tool calls.** `[STABLE]`
  ([antigravity.google/docs/cli-sandbox](https://antigravity.google/docs/cli-sandbox) —
  legacy path, new-scheme equivalent not fetched 2026-11-08;
  `agy --help` 1.5.3: "Run in a sandbox with terminal restrictions enabled")
- **⚠️ Sandbox hardening and a fixed escape (1.3.3–1.5.3).** 1.5.3 "Fixed
  a security issue where a command run in the terminal sandbox could
  change environment state later loaded by persistent terminal commands
  run outside the sandbox, and hardened persistent terminal IDs against
  path traversal" — anything below 1.5.3 carries that bug. 1.4.6:
  sandboxed commands can no longer read or modify `~/.docker`, `~/.kube`,
  or `~/_netrc` unless granted. 1.3.3: the macOS sandbox blocks reading
  `~/Library/Application Support` by default. 1.5.1: plugin OAuth tokens
  are substituted only in a request's `Authorization` header inside the
  sandbox. 1.4.2: on Windows versions that cannot run the sandbox, a
  sandboxed permission mode now **turns the sandbox off and falls back to
  asking** before commands. Changelog-only, not exercised. `[MEDIUM]`
  (`agy changelog` 1.3.3/1.4.2/1.4.6/1.5.1/1.5.3)
- **Two headless safety floors:** `--sandbox` did NOT
  propagate in headless print mode (`-p` / `--print`) before v1.0.6 —
  fixed in v1.0.6 ("ensuring sandbox isolation is correctly enforced
  during non-interactive execution"). Separately, v1.1.4 fixed headless mode
  honoring persisted permissions, file-access, sandbox, auto-execution, and
  artifact-review policies. Shell containment begins at v1.0.6; safe
  cross-vendor dispatch requires **agy ≥ 1.1.4** because it also depends on
  persisted file-write refusal. `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.6,
  [release v1.1.4](https://github.com/google-antigravity/antigravity-cli/releases/tag/1.1.4))
- **Permission auto-approve:** `--dangerously-skip-permissions`
  bypasses all tool-permission prompts (DANGER — opposite of
  read-only review). Avoid in cross-vendor review use. Semantics have
  moved: since 1.3.2 it no longer auto-approves implementation plans
  ("the flag now only skips tool permission prompts"); since 1.5.2
  "commands on the system command denylist are blocked instead of approved
  automatically", and headless runs deny out-of-workspace access that a
  Gemini Enterprise admin requires to be reviewed. `[STABLE]` for the
  danger posture; details `[MEDIUM]` (`agy changelog` 1.3.2/1.5.2)
- **Other permission behavior changes (changelog-only).** URL fetches
  changed "from always allowed to asking first" (1.1.28); `always-proceed`
  now also auto-approves MCP tool calls and page reads (1.1.21); a
  non-approved permission request is respected — the agent "no longer
  tries to work around it with other commands, scripts, or tools"
  (1.2.15); approving a Google site no longer approves sensitive Google
  apps such as `mail.google.com` / `drive.google.com` (1.4.9); 1.2.2
  warns on deprecated `unsandboxed` permission rules. Headless allow-rules
  live under `permissions.allow` in `settings.json` (docs/cli/headless).
  `[MEDIUM]` (`agy changelog` 1.1.21/1.1.28/1.2.2/1.2.15/1.4.9)
- **Permission presets via slash command:** `/permissions` (added
  v1.0.5) switches between `request-review` (default, TUI prompts
  before each tool call), `always-proceed` (auto-approve), and
  `strict` (refuse without explicit allowlist), and can add/edit/
  remove permission rules across the three config tiers (project /
  shared user settings / CLI settings.json — merged, v1.0.5). A
  fourth mode, `proceed-in-sandbox` (v1.0.1), auto-approves commands
  that run inside the sandbox and prompts only when a command
  attempts to bypass it. These are persisted settings, not one-shot flags;
  v1.1.4 is the first release confirmed to honor them in `--print` mode.
  Because this behavior changed materially across minor releases, this claim
  is `[MEDIUM]`, not stable. All four preset names are still present as
  strings in the 1.5.3 binary.
  ([antigravity.google/docs/cli/reference](https://antigravity.google/docs/cli/reference),
  [CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.1/v1.0.5)
- **Execution mode:** `--mode` accepts `accept-edits`, `auto`, `plan`
  (default empty = normal agent mode; settings key `agentMode`). **Auto
  mode** (1.3.5) "approves file edits and safe commands without asking and
  still prompts before irreversible actions; commands that would leave the
  terminal sandbox are first reviewed by a separate agent"; docs: "`auto`
  needs the terminal sandbox and isn't available for business or
  enterprise accounts". `--mode plan` was introduced as a v1.1.4 launch flag
  intended to keep the reviewer in research/plan behavior. ⚠️ **It is no
  longer a headless gate** — see the 2026-11-08 warning below (1.1.28
  auto-proceeds through plan review in `-p`). The dispatcher still passes
  it; treat it as **no** defense in depth in headless mode until the
  deferred Tier 1 PR decides otherwise. `[MEDIUM]` (`agy --help` 1.5.3,
  [docs/cli/reference](https://antigravity.google/docs/cli/reference),
  `agy changelog` 1.1.28/1.3.5)
- **Output format:** ⚠️ **CORRECTED 2026-08-25 — was verified-false.**
  `agy --help` at 1.1.19 lists `--output-format (text, json, stream-json)`
  and `--json-schema`. The superseded claim read: plain text only, NO `--output-format json` or
  Codex-style `--json` flag is documented or visible via `agy --help`.
  The `--print` output is the agent's free-form response. `[MEDIUM]`
  (`agy --help` output 2026-07-18)
  **2026-11-08 additions:** `--output-format` (text default, json,
  stream-json) and `--json-schema` still present in `agy --help` 1.5.3.
  The JSON envelope (docs/cli/headless) carries `conversation_id`,
  `status` (`SUCCESS`/`ERROR`/`CANCELED`/`INTERRUPTED`/`INVALID`/
  `WAITING`/`RUNNING`), `response`, `error`, `duration_seconds`,
  `num_turns`, `usage{…}`, and `structured_output` / `json_schema` with
  `--json-schema`. Changelog-only (not on the docs page): **`denied_actions`**
  (1.1.27 — refused actions in headless runs) and **`finished_reason`**
  (1.4.11 — "`print_timeout` when `--print-timeout` expired and the
  response is partial, `interrupted` … or `error` for any other failure …
  the field is omitted when the turn finishes normally"). `--json-schema`
  rejects plain text, bare type names, missing files, and non-object roots
  at startup with exit 1 (1.2.14). `--input-format stream-json` now
  requires `--output-format stream-json` (help 1.5.3). Not exercised (no
  `-p` runs). `[MEDIUM]`
  ([docs/cli/headless](https://antigravity.google/docs/cli/headless),
  `agy --help` 1.5.3, `agy changelog` 1.1.27/1.2.14/1.4.11)
- **⚠️ PRINT-MODE ERROR SEMANTICS CHANGED — the dispatcher's fail-closed
  check may no longer fire (1.1.18 / 1.1.20).** `[VOLATILE]`
  **Verified by execution 2026-08-25** — 1.1.20 is now the installed
  binary and the probe confirmed the denial-exit behavior directly (a
  permission-denied run exited 0). The prior `low-confidence` tag
  (placed when 1.1.19 was installed) is retired for THIS claim.
  **1.1.20** fixed print mode "treating benign tool execution errors and
  **permission denials** as fatal run failures with non-zero exit
  codes", so headless exit codes now "reflect only cascade-level
  failures". **1.1.18** separately fixed `-p` exiting *successfully*
  with an empty response when the agent state stream dropped mid-run.
  **Why this matters here:**
  [`cross-vendor-review.sh`](../../../scripts/cross-vendor-review.sh)
  detects a denied tool request by **grepping the output text** for
  permission-denial phrasing and refusing the review.
  **History — resolved ON 1.1.20 (2026-08-25 probe):** on 1.1.20 the
  write refusal held (tool and shell arms both auto-denied, sentinel
  absent), the 1.1.20 denial phrasing matched the dispatcher's regex, and
  a benign control did not false-positive it. **That match is NOT a
  current-state claim** — see the 2026-11-08 warning below. The
  exit-code half of the concern is CONFIRMED REAL: the denial exited
  **0**, so exit-status detection would never fire — the text grep is
  the only working mechanism and must be re-verified on every version
  bump (the dispatcher's probe-version gate enforces exactly that). No
  changelog entry 1.1.21–1.5.3 reverses the denials-are-non-fatal
  behavior. Probe record in this file's frontmatter. (three-arm probe
  2026-08-25, binary 1.1.20; `agy changelog` 1.1.21–1.5.3)
- **⚠️ OPEN 2026-11-08 — denial-regex gap: the dispatcher's fail-closed
  grep does NOT match the 1.1.27+ headless denial notice.** `[VOLATILE]`
  **NOT FIXED — deferred to a separate Tier 1 PR (supervisor ruling R4,
  2026-11-08).** 1.1.27: "Fixed headless runs with `-p` silently skipping
  tool actions they were not permitted to take, which now end with a
  notice naming the refused actions and report them as `denied_actions`
  in the JSON output." Two headless denial templates are present in both
  the 1.4.12 and 1.5.3 binaries (`strings`):
  - (A) `%s required the %s %s that headless mode cannot prompt for, so %s
    auto-denied. Add an allow-rule under permissions.allow in
    settings.json (e.g. %s)` — the 1.1.20-era shape; matches the regex
    when rendered as "a tool required the "x" permission …".
  - (B) `the %s tool(s) required approval that headless mode cannot
    prompt for, so they were auto-denied. Settings allow-rules do not
    apply; re-run with --dangerously-skip-permissions to auto-approve all
    tools.` — the 1.1.27+ notice for runs that **did** produce output.

  The dispatcher regex
  (`no output produced.*permission.*(denied|required)|tool required.*permission`)
  was executed 2026-11-08 against filled-in instances of (B): **NOMATCH**
  ("tool(s) required" ≠ "tool required"; the only "permission" is inside
  `--dangerously-skip-permissions`, with no "denied" after it). A possible
  plural rendering of (A) ("2 tools required …" without "no output
  produced" on the same line) would also be NOMATCH — **hypothetical**,
  the rendered plural form is unobserved. **Impact (latent):** dispatch is
  currently refused before `agy` runs, by the probe-version gate
  (verified-on 1.1.20 ≠ installed 1.5.3). If dispatch were re-enabled
  without fixing detection, a review that reached for a tool, was
  denied, and still produced output would be **accepted** instead of
  refused — fail-open for *review integrity*. It
  is not a write-safety failure: strict `toolPermission` still refuses
  the write. Before 1.1.27 such denials were silent, so the 1.1.20 probe
  could not have exercised this. **Better detection path (for the Tier 1
  PR):** `--output-format json`, refusing on non-empty `denied_actions`
  or any present `finished_reason`, instead of (or in addition to) a
  widened text regex. Confidence: changelog + binary strings;
  regex result verified-by-execution; actual emitted output **not
  observed** (requires the probe). (`agy changelog` 1.1.27, `strings` on
  binaries 1.4.12/1.5.3, regex run 2026-11-08)
- **⚠️ OPEN 2026-11-08 — `--mode plan` is no longer a headless gate.**
  `[MEDIUM]` **NOT FIXED — deferred (R4).** 1.1.28: "Fixed headless
  (`-p`) runs stalling forever on implementation-plan approval that no one
  could give; non-interactive runs now proceed through plan review
  automatically." In `-p` mode neither `--mode plan` nor the project's
  `artifactReviewPolicy: "asks-for-review"` holds execution at the plan;
  strict `toolPermission` is the only remaining write barrier.
  `low-confidence` on the exact interaction (not executed).
  (`agy changelog` 1.1.28)
- **⚠️ OPEN 2026-11-08 — timeout-expiry semantics and an exit-3
  collision.** `[VOLATILE]` **NOT FIXED — deferred (R4).** 1.1.28 → 1.4.12:
  on `--print-timeout` expiry the CLI "returns the partial output it has
  and exits successfully with a warning on stderr" — on those versions the
  dispatcher would have accepted a truncated review with exit 0. 1.5.0+
  (installed): "when `--print-timeout` cuts a turn short, the run now exits
  with code `3`, prints an `AGY_ERROR` line naming the tasks it
  terminated, and writes a `[agy] print timeout after ...` line to
  stderr." Since 1.2.6, agent/model API failures also exit **3** (with a
  structured `AGY_ERROR: {...}` stderr line); since 1.2.10 a partial
  response that ends on an error exits 3. `cross-vendor-review.sh` passes
  agy's status straight through (`exit "$RC"`), which **collides with the
  dispatcher's own exit 3 = "rate limit, try another vendor"**.
  Changelog-only; not executed. (`agy changelog` 1.1.28/1.2.6/1.2.10/1.5.0)
- **Headless exit codes (consolidated, 2026-11-08).** `0` success
  (denials included — non-fatal since 1.1.20); `3` agent/model API
  failure, partial-then-error, and (1.5.0+) print-timeout expiry; `1`
  unknown `--agent` (1.3.4, lists available agents), unknown `--model`,
  invalid `--json-schema` (1.2.14), malformed stream-json; `2` print-mode
  usage errors (1.3.4), stray positional argument (executed on 1.5.3),
  stream-input control events/slash commands; a hook-injected
  `errorMessage` makes `-p` exit non-zero (1.4.11). Fatal errors carry a
  stable `error:` stderr marker (1.1.28). `[MEDIUM]`
  ([docs/cli/headless](https://antigravity.google/docs/cli/headless),
  `agy changelog`, stray-positional run 1.5.3)
- **⚠️ Valueless-flag prompt bug (fixed 1.1.18) — sandbox could be
  silently OFF.** Before 1.1.18, `agy --print --sandbox 'do the task'`
  ran with the prompt `--sandbox` and **the sandbox disabled**; a stray
  trailing argument behaved similarly. Both are now hard errors. Our
  dispatcher passes the prompt as `--print "$AGY_PROMPT"` so it is not
  in the vulnerable shape. The floor was raised: `cross-vendor-review.sh`
  now sets `AGY_MIN_VERSION="1.1.18"` (fix/cross-vendor-review-dispatcher,
  2026-08-25). Hard-error behavior re-confirmed by execution on 1.5.3
  (stray positional → exit 2). `[MEDIUM]` (`agy changelog` 1.1.18,
  `scripts/cross-vendor-review.sh`, executed 2026-11-08)
- **Workspace read auto-granted under default review mode (1.1.20).**
  `low-confidence` — still **untested** at 1.5.3 (2026-11-08): the only
  probe ran strict mode, not default review mode. Changelog-sourced until a default-mode probe runs. Read/list within the workspace root no
  longer prompts; modification and external access still confirm. If it
  holds, it partially supersedes the "strict mode did not honor read
  grants" finding from the 1.1.4 walk. `[MEDIUM]`
  (`agy changelog` 1.1.20)
- **Added since 1.1.4:** `--input-format stream-json` (1.1.15, one turn
  per NDJSON line); `mcp` subcommands `add`/`remove`/`list`/`enable`/
  `disable` (1.1.16); `GEMINI_API_KEY` + `modelProvider: "gemini"` +
  `GOOGLE_GEMINI_BASE_URL` direct-API route (1.1.13); `AGY_CLI_HIDE_LOGO`
  and `AGY_CLI_DISABLE_ESCAPE_SEQUENCE_OPTIMIZATIONS` (1.1.19).
  ⚠️ Note `--output-format json`/`stream-json` ARE referenced by the
  1.1.20 print-mode fix, which contradicts this file's older "plain text
  only. NO `--output-format json`" claim — that claim is now
  **verified-false** and is corrected above. `[MEDIUM]` (`agy changelog`)
- **Flags/subcommands present at 1.5.3 not previously recorded in this
  file** (`agy --help` 1.4.12 + 1.5.3; not all are new since 1.1.20 —
  `--effort` dates to 1.1.5 and `--agent` to 1.1.1, see §9/§3):
  `--effort`, `--settings` (session-only, never saved — see §1),
  `--disable-slash-commands` (print mode expands leading `/skill` prompts
  since 1.1.9; this disables it), `--log-file`, `-i/--prompt-interactive`,
  `--add-dir`, `-c/--continue`, `--conversation`, `--project`,
  `--new-project`, `--remote-control`, `--agent`; **1.5.3 adds
  `--remote-agent`** (runs conversations on remote agents). Subcommands:
  `acp` (1.5.0, see §8), `plugin`/`plugins` (§2), `remote-control`
  (`start`/`status`/`stop`), `update`, `mic-serve`, `help`. Headless
  quality-of-life: `-p` no longer generates unseen conversation titles
  (1.1.28/1.5.2), uses less CPU (1.4.7), and skips subagent questions so
  subagents continue (1.3.6). `[MEDIUM]` (`agy --help` / `agy help`
  1.4.12 + 1.5.3, `agy changelog`)
- **Headless failure and exit behavior:** v1.1.1 changed server-side print-mode
  failures from empty successful output to stderr plus non-zero exit, and
  stopped `agy -p` from hanging in scripts when the prompt is supplied by a
  flag. v1.1.2 added controlling-terminal OAuth-code input for piped prompts
  and fail-fast behavior for truly headless authentication. `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.1.1/v1.1.2)
- **Misc operational facts (CHANGELOG-anchored):**
  `AGY_CLI_HIDE_ACCOUNT_INFO` env var hides email + plan tier from the
  header (v1.0.2); `AGY_CLI_DISABLE_LATEX` disables LaTeX terminal
  rendering (v1.0.4); conversations persist as SQLite `.db` files and
  headless `-p` metadata caches under
  `~/.gemini/antigravity-cli/cache/` (v1.0.4/v1.0.5). `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.2/v1.0.4/v1.0.5)
- **Cross-vendor review flag set** (consumed by `scripts/cross-vendor-review.sh` per [`cross-vendor-review.md`](../../protocols/cross-vendor-review.md)):

  ```
  agy --print "<prompt>" --mode plan --sandbox --print-timeout 5m </dev/null
  ```

  Five controls / caveats:
  (a) `--sandbox` enforces shell-command containment, NOT file-write
  read-only. File-write refusal comes from the global CLI
  `toolPermission: "strict"` setting, verified by the probe below.
  (b) The dispatcher takes plain text and parses it by string-matching
  the rubric's `### Anchored observations` / `### No-anchor
  observations` headers verbatim. ⚠️ **Corrected 2026-08-25:** this is a
  *dispatcher* choice, not a CLI limitation — `agy --help` at 1.1.19
  lists `--output-format (text, json, stream-json)` and `--json-schema`.
  Structured output is available and the dispatcher does not use it.
  The 2026-11-08 JSON fields `denied_actions` / `finished_reason` make
  structured output the better detection path (open, deferred — R4).
  (c) v1.1.4 headless mode auto-denies a write tool that requires interactive
  confirmation under `strict`; it does not hang. ⚠️ `--mode plan` no longer
  holds a headless run at the plan (1.1.28 — see the open warning above).
  (d) **Dispatch floor: agy ≥ 1.1.18** (raised from 1.1.4 on 2026-08-25),
  **and** `headless-write-probe-verified-on` must EQUAL the installed
  version. The dispatcher also verifies the global strict+sandbox policy,
  project hardening policy, and this file's passed probe marker before
  invoking Antigravity. There is no safety override. **State 2026-11-08:**
  installed 1.5.3 ≠ verified-on 1.1.20, so the gate refuses dispatch (exit
  4) as designed — gate logic re-run by hand, dispatcher not executed.
  (e) The dispatcher embeds review targets up to 100,000 bytes directly in the
  prompt and forbids tool use. This avoids granting headless `read_file` access.
  A permission-denial response fails closed with exit 4 **only when the
  denial text matches the regex** — ⚠️ the 1.1.27+ notice does not (open
  warning above), so "fails closed on any permission denial" is not true
  on ≥1.1.27 until the deferred fix lands.

  **Probe result (2026-07-18, agy v1.1.4): PASSED after one falsifying first
  attempt.** With only scratch-repo `.gemini/settings.json`, Antigravity did
  not resolve an active workspace and created the sentinel in its default user
  scratch directory; that exact sentinel was removed and dispatch remained
  disabled. After persisting `toolPermission=strict` and
  `enableTerminalSandbox=true` in the global CLI settings, the same headless
  write request returned an explicit auto-denial and created no sentinel in
  either location. `[MEDIUM]`

---

## 10. Gaps / Antigravity-CLI-down notes

- **No direct read-only contract for one-shot CLI invocation.**
  Antigravity offers `/permissions strict` inside the TUI and
  `enableTerminalSandbox` via settings.json, but NO `--read-only` flag
  for `agy --print`. Cross-vendor review use requires settings.json
  configuration + verification that `--print` mode honors the
  persistent permission preset. The 2026-07-18 v1.1.4 probe verified that
  composition, but because it depends on mutable settings and minor-version
  behavior the claim is `[MEDIUM]`.
- **~~No JSON output format documented.~~ VERIFIED-FALSE, corrected
  2026-08-25.** `agy --help` at 1.1.19 lists `--output-format (text,
  json, stream-json)` and `--json-schema`. The dispatcher still parses
  plain text by string-matching the rubric's `### Anchored observations`
  / `### No-anchor observations` headers, so the fragility is real — but
  it is now a **dispatcher gap, not a vendor limitation**, and is
  fixable by adopting `--output-format json`. Tracked as a residual.
  2026-11-08: the JSON envelope now also exposes `denied_actions` and
  `finished_reason` (§9). Those fields describe the **execution
  outcome**, so they can replace the denial text-grep (refuse on
  non-empty `denied_actions` / present `finished_reason`, once their
  semantics are probed). They do **not** replace the rubric-header
  parsing: that needs a review-observation schema via `--json-schema`
  plus matching dispatcher changes. Both folded into the deferred
  Tier 1 PR (R4).
  `[MEDIUM]` (`agy --help` 1.1.19 / 1.5.3, `agy changelog` 1.1.27/1.4.11)
- **Settings.json applicability.** The load-bearing headless policy file is
  `~/.gemini/antigravity-cli/settings.json`. A scratch-repo-only
  `.gemini/settings.json` did not apply when Antigravity failed to resolve an
  active workspace, so the dispatcher checks the global file directly and
  treats repo-local policy as defense in depth. Native `AGENTS.md` lookup
  is now docs-confirmed (§1); whether the project `.gemini/settings.json`
  is loaded at all on 1.5.3 (and whether its `context.fileName` key is
  honored) remains unverified. 1.1.20 stopped the CLI from overwriting an
  unparseable `settings.json` on startup. `[MEDIUM]`
- **No agy CLI versioning of the docs.** The Antigravity docs at
  `antigravity.google/docs/*` don't surface CLI-version-tagged
  history (pages are fetchable as of 2026-11-08, but unversioned). Behavior may shift between releases without notice. Treat
  any documented behavior as `[VOLATILE]` until pinned by smoke test
  on the local install. `[VOLATILE]`
- **Antigravity-CLI-down posture:** every meta-layer artifact in
  [`markdowns/`](../../) is acceptable in degraded mode. Substance
  (markdown, AGENTS.md, protocols, scripts) is portable; the loss is
  the Google-side cross-vendor reviewer surface — Claude + Codex would
  have to carry the load. `[STABLE]`
- **Write-refusal smoke test and first live review completed.** The destructive
  edge was tested directly on v1.1.4 and refused under the persisted strict
  policy. During the 2026-07-18 Tier 1 review, headless strict mode loaded both
  wildcard and exact-path `read_file` allow rules but still denied `ReadFile`.
  The temporary grants were removed, and the dispatcher now embeds the exact
  target so the reviewer needs no filesystem tools. The live rubric pass then
  returned the required anchored / external-claim / no-anchor sections without
  invoking tools. Plain-text parsing remains observationally weaker than
  Codex's structured output. Re-probe whenever the minimum version, permission
  schema, or inline transport changes. **2026-11-08:** a re-probe on the
  installed 1.5.3 is required before dispatch, but must **follow** the
  deferred denial-regex / structured-output fix (§9 open warnings) and
  should add an arm in which the model reaches for a tool and still
  answers, so the 1.1.27+ notice is exercised. Pin the version (or disable
  auto-update — see the header) between probe and dispatch. `[MEDIUM]`

## See also

- [`markdowns/agents/README.md`](../README.md) — index for the vendor
  knowledge files.
- [`markdowns/protocols/cross-vendor-review.md`](../../protocols/cross-vendor-review.md) —
  downstream consumer (cross-vendor review rubric, the cross-vendor review script).
- [`markdowns/meta-layer/cross-vendor-harness.md`](../../meta-layer/cross-vendor-harness.md) —
  cross-vendor topology + sync mechanics (Antigravity reads
  `AGENTS.md` natively per its rules docs; the `.gemini/settings.json`
  `context.fileName` override is retained, effect unverified — §1).
