---
name: vendor-knowledge-antigravity-cli
description: Volatility-tagged knowledge of Antigravity CLI — Google's coding CLI (`agy`). Canonical instructions file, skills, subagents, hooks, auth, rate limits, cost, MCP, headless invocation. Drives cross-vendor scripts and /refresh-vendor.
status: reference
last-verified: 2026-06-20
---

# Antigravity CLI — vendor knowledge

Single file. One vendor. Every claim carries a `[STABLE]` / `[MEDIUM]` /
`[VOLATILE]` tag and a URL citation. Walked weekly by
[`refresh-vendor.md`](../../protocols/refresh-vendor.md);
change-marker semantics (no edit on no-op). Linked from the README at
[`markdowns/agents/README.md`](../README.md).

**Install:** `curl -fsSL https://antigravity.google/cli/install.sh | bash`
(places `agy` at `~/.local/bin/agy`).

## Installer gotchas (verified 2026-06-09 against installer v1.0.7)

- **The installer silently modifies `~/.zshrc` and `~/.zprofile`.** It
  appends `export PATH="...:$PATH"` to both files with no prompt and no
  opt-out flag. To prevent this, either run the installer in a clean
  shell and revert the PATH additions afterward, or download and edit
  the install script before running.
- **`--skip-aliases` and `--skip-path` flags do NOT exist.** Some
  earlier documentation mentioned them; the actual installer (v1.0.7)
  parses only `-d/--dir` and `-h/--help`. Verified via `bash install.sh -h`.
- **`-d /custom/path` does not isolate the install.** The installer
  places the binary at the custom path AND at `~/.local/bin/agy`
  (default). Belt-and-suspenders behavior; both copies will exist.
- **Claim-vintage map.** Claims citing `agy --help` 2026-05-28 were
  observed on the initial local install; flag claims dated 2026-06-09
  were verified against `agy --help` (v1.0.7). Both binary channels —
  the published docs site is an incomplete subset of the binary's
  actual flag set, and binary `--help` is the authoritative source per
  [`refresh-vendor.md`](../../protocols/refresh-vendor.md) reliability
  ordering. Claims added on the 2026-06-10 walk cite the official
  repo CHANGELOG instead — the binary was unavailable that walk
  (uninstalled locally; release-tarball execution not authorized) and
  the docs site was SPA-rendered, unreachable via WebFetch.

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
Source: [antigravity.google/docs/cli-overview](https://antigravity.google/docs/cli-overview).

---

## 1. Canonical instructions file

- **Settings file location:** `~/.gemini/antigravity-cli/settings.json`.
  The parent directory is `~/.gemini/` — Antigravity's chosen config
  root path. `[STABLE]`
  ([antigravity.google/docs/cli-using](https://antigravity.google/docs/cli-using),
  [antigravity.google/docs/cli-overview](https://antigravity.google/docs/cli-overview))
- **Project context file:** Antigravity CLI reads project-level config
  from [`.gemini/settings.json`](../../../.gemini/settings.json) with
  `context.fileName: ["AGENTS.md"]`. **TBD, low-confidence signal
  (2026-06-10):** community sources (Medium migration guide, search
  snippets) claim Antigravity now reads `AGENTS.md` at the project
  root natively and that `agy inspect` lists loaded config
  ([medium.com/google-cloud/migrating-to-antigravity-cli](https://medium.com/google-cloud/migrating-to-antigravity-cli-a841c6964f37),
  [dev.to/arindam_1729](https://dev.to/arindam_1729/antigravity-cli-a-hands-on-guide-to-googles-terminal-coding-agent-5bc7)) — NOT
  corroborated by CHANGELOG or README, binary check blocked this walk.
  The override stays load-bearing until verified. Re-trigger: next agy
  install or first Antigravity-as-reviewer run. `[MEDIUM]`
- **Hierarchical lookup:** partially resolved — the permission system
  merges **three config tiers**: project-level permissions, user
  settings shared with Antigravity, and the CLI `settings.json`
  (CHANGELOG v1.0.5). Full settings lookup chain (global / workspace /
  JIT) still TBD; docs site (`/docs/cli-settings`) is SPA-rendered and
  unreachable via WebFetch. `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.5)
- **Repo posture.** This template's `.gemini/settings.json` with
  `context.fileName: ["AGENTS.md"]` is what Antigravity reads at the
  project level. No new repo file required; AGENTS.md is the
  canonical instructions file (Antigravity reads it through this
  config; the pre-commit hook auto-mirrors it to CLAUDE.md for Claude
  Code's native lookup). `[MEDIUM]`

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
  from `~/.gemini/antigravity/skills/<skill-folder>/`. Antigravity
  **defaults to `.agents/skills`**, with backward compatibility for the
  older `.agent/skills` directory. The `/skills` slash command browses
  loaded local + global skills inside the TUI. `[STABLE]`
  ([antigravity.google/docs/skills](https://antigravity.google/docs/skills),
  [antigravity.google/docs/cli-reference](https://antigravity.google/docs/cli-reference))
- **Plugin-based skill/agent discovery:** the CLI scans installed
  plugin directories and exposes their skills and specialized agents
  for execution (CHANGELOG v1.0.1); plugins install to the shared
  config dir `~/.gemini/config/` (v1.0.2 path fix); plugins are
  installable from GitHub subpaths with branch resolution (v1.0.7).
  Skill-derived slash commands execute from autocomplete (v1.0.4 fix).
  `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.1/v1.0.2/v1.0.4/v1.0.7)
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
  [antigravity.google/docs/cli-reference](https://antigravity.google/docs/cli-reference).
  A dedicated `/docs/cli-subagents` page covers the architecture; not
  yet walked in this draft. `[MEDIUM]`
- **Default subagent interaction timeout: 60 s.** A v1.0.2 fix
  "restricted the default 60-second interaction timeout specifically
  to subagents" — i.e. the 60 s default no longer applies to the main
  agent (whether the main agent has another cap is not stated; §9's
  `--print-timeout` 5m0s governs headless runs). Subagent
  conversations are excluded from `/resume` (v1.0.6). `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.2/v1.0.6)
- **Parallel spawn / nesting cap / recursion guard:** TBD,
  low-confidence signal (2026-06-10) — community tutorials
  ([datacamp.com/tutorial/antigravity-cli](https://www.datacamp.com/tutorial/antigravity-cli))
  demonstrate subagents running concurrently, orchestrated dynamically
  with no static config files. Caps and nesting limits remain
  unconfirmed by official channels; binary check blocked this walk.
  Re-trigger: next agy install or first Antigravity-as-reviewer run.
  `[MEDIUM]`

---

## 4. Hooks

- **Hooks exist.** The `/hooks` slash command browses active
  pre-flight / post-format script hooks per
  [antigravity.google/docs/cli-reference](https://antigravity.google/docs/cli-reference).
  A dedicated `/docs/hooks` page documents the event surface; the page
  is SPA-rendered and was unreachable via WebFetch this walk. `[MEDIUM]`
- **Configuration shape:** TBD, low-confidence signal (2026-06-10) —
  a community migration guide
  ([medium.com/google-cloud/migrating-to-antigravity-cli](https://medium.com/google-cloud/migrating-to-antigravity-cli-a841c6964f37))
  claims hooks live in a workspace-local
  `.agents/hooks.json` and use a JSON stdin/stdout contract (hook
  receives event JSON on stdin, emits `{"decision":"allow"}` /
  `{"decision":"deny"}`), replacing the prior exit-code model. NOT
  corroborated by CHANGELOG or README; binary check blocked this
  walk. Re-trigger: next agy install or first
  Antigravity-as-reviewer run. `[MEDIUM]`
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
  ([antigravity.google/docs/cli-install](https://antigravity.google/docs/cli-install),
  observed during local install 2026-05-28)
- **Device-code flow for SSH / headless environments:** Antigravity
  CLI detects SSH sessions and prints an authorization URL plus a
  one-time code; user opens the URL on a local machine, pastes the
  code. `[STABLE]`
  ([github.com/google-antigravity/antigravity-cli README](https://github.com/google-antigravity/antigravity-cli))
- **Credential storage:** system keyring on supported platforms;
  fallback behavior on systems without a keyring is not surfaced in
  the snapshots captured. `[MEDIUM]`
- **`/logout` slash command:** disconnects the active profile and
  purges tokens from the keyring per
  [antigravity.google/docs/cli-reference](https://antigravity.google/docs/cli-reference).
  `[STABLE]`
- **API key alternate:** TBD on next walk. Whether Antigravity accepts
  an API key env-var path or Vertex service account credentials is
  not surfaced in the snapshots so far. `[MEDIUM]`
- **Cross-vendor parity:** Claude Code defaults to Anthropic OAuth;
  Codex defaults to ChatGPT OAuth; Antigravity defaults to Google
  OAuth. All three are subscription-only in this repo per
  .
  `[STABLE]`

---

## 6. Rate limits — `[VOLATILE]`

**Re-verify before relying.** Antigravity CLI is in active rollout;
the official `/docs/plans` page carries the current tier-by-tier
quotas. Snapshots captured during this draft did not reach the plans
page in depth.

- **Tier structure follows the Google AI consumer tiers**
  (Personal / AI Pro / AI Ultra / Enterprise) per Google's
  announcement at
  [developers.googleblog.com](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/).
  Absolute per-day / per-minute quotas TBD on next walk. `[VOLATILE]`
- **Real-time quota introspection:** `/usage` and `/quota` slash
  commands force a live reload of model configuration and remaining
  quotas, showing real-time consumption (v1.0.1). Mechanism for
  checking limits is in-product; published absolute numbers still
  absent. `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.1)
- **G1 credits overflow:** when standard quota runs out, G1 credits
  can be spent instead — `UseG1Credits` setting enables automatic
  credit usage; remaining credits display in the status bar; the
  `/credits` panel links to credit purchase (v1.0.3). `[VOLATILE]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.3)
- **Recovery posture:** on rate-limit hit, abort and re-run via
  `cross-vendor-review.sh --to <other-vendor>`. No automatic API-key
  fallback. `[STABLE]`

---

## 7. Cost

- **Pricing tiers** follow the Google AI consumer subscription
  family per Google's announcement
  ([developers.googleblog.com](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/)).
  Specific tier prices TBD on next walk. `[MEDIUM]`
- **Per-call cost in print mode:** print mode emits plain-text output;
  no JSON-shaped usage statistics block is documented in the snapshots
  captured. `[MEDIUM]`
- **Credit top-ups:** G1 credits are purchasable in-product via the
  `/credits` panel and auto-spend on quota exhaustion when
  `UseG1Credits` is enabled (see §6). `[VOLATILE]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.3)

---

## 8. MCP (client + server)

- **As client:** stable. Two transports — **stdio** (local executable)
  and **Streamable HTTP** (remote URL with optional OAuth + custom
  headers). Config location per CHANGELOG is
  `~/.gemini/antigravity-cli/config/mcp_config.json` (migrated from a
  legacy top-level `mcp_config.json` path, v1.0.3 fix); servers are
  also installable via the `/mcp` slash command's "Install" flow.
  Direct `url` keys configure HTTP servers (v1.0.5); server-launch
  timeout is configurable, `-1` disables it (v1.0.7); server init is
  parallelized so one slow server doesn't block the rest (v1.0.4).
  NOTE: the docs site describes an `mcpServers` object in
  `settings.json` — the CHANGELOG's `config/mcp_config.json` outranks
  it per channel ordering; reconcile against the binary on next
  install. `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.3/v1.0.4/v1.0.5/v1.0.7,
  [antigravity.google/docs/mcp](https://antigravity.google/docs/mcp))
- **OAuth 2.0 supported** for HTTP servers via the
  `oauthClientCredentials` object on the server config. `[STABLE]`
  ([antigravity.google/docs/mcp](https://antigravity.google/docs/mcp))
- **As server: NOT first-party.** No `agy mcp serve` command exists;
  the docs at
  [antigravity.google/docs/mcp](https://antigravity.google/docs/mcp)
  scope MCP exclusively to client-side connection. (Codex CLI closed
  its equivalent gap — `codex mcp-server` verified 2026-06-10; see
  [`codex-cli.md`](codex-cli.md) §8. Antigravity now stands alone
  among our peer vendors here.) `[STABLE]`
- **Cross-vendor posture:** MCP cross-vendor servers still deferred —
  shell invocation via
  [`cross-vendor-review.sh`](../../../scripts/cross-vendor-review.sh)
  remains today's answer. NOTE: the documented revisit trigger ("any
  peer vendor ships first-party MCP server") **fired 2026-06-10** via
  the Codex walk; the posture re-evaluation was deferred by the
  supervisor to its own session. `[STABLE]`

---

## 9. Headless invocation

- **Entry point:** `agy --print "<prompt>"` (short alias `agy -p`;
  alias `agy --prompt`). Runs a single prompt non-interactively and
  prints the response. `[STABLE]`
  ([antigravity.google/docs/cli-reference](https://antigravity.google/docs/cli-reference),
  `agy --help` output 2026-05-28)
- **Timeout:** `--print-timeout` (default `5m0s`). `[STABLE]`
- **Model selection:** `--model` flag sets the model at launch; the
  `models` subcommand lists available models (both added v1.0.5).
  `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.5)
- **Sandbox flag:** `--sandbox` activates terminal-command sandboxing
  via native OS containment (nsjail on Linux, sandbox-exec on macOS,
  AppContainer on Windows). Restricts SHELL execution by the agent;
  **does NOT block file-write tool calls.** `[STABLE]`
  ([antigravity.google/docs/cli-sandbox](https://antigravity.google/docs/cli-sandbox))
- **⚠ Sandbox version floor for headless mode:** `--sandbox` did NOT
  propagate in headless print mode (`-p` / `--print`) before v1.0.6 —
  fixed in v1.0.6 ("ensuring sandbox isolation is correctly enforced
  during non-interactive execution"). Treat `agy -p ... --sandbox` as
  sandboxed ONLY on **agy ≥ 1.0.6**. `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.6)
- **Permission auto-approve:** `--dangerously-skip-permissions`
  bypasses all tool-permission prompts (DANGER — opposite of
  read-only review). Avoid in cross-vendor review use. `[STABLE]`
- **Permission presets via slash command:** `/permissions` (added
  v1.0.5) switches between `request-review` (default, TUI prompts
  before each tool call), `always-proceed` (auto-approve), and
  `strict` (refuse without explicit allowlist), and can add/edit/
  remove permission rules across the three config tiers (project /
  shared user settings / CLI settings.json — merged, v1.0.5). A
  fourth mode, `proceed-in-sandbox` (v1.0.1), auto-approves commands
  that run inside the sandbox and prompts only when a command
  attempts to bypass it. These are **TUI slash commands** — not CLI
  flags — so they don't directly apply to `--print` mode. `[STABLE]`
  ([antigravity.google/docs/cli-reference](https://antigravity.google/docs/cli-reference),
  [CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.1/v1.0.5)
- **Output format:** plain text only. NO `--output-format json` or
  Codex-style `--json` flag is documented or visible via `agy --help`.
  The `--print` output is the agent's free-form response. `[MEDIUM]`
  (`agy --help` output 2026-05-28)
- **Exit codes:** TBD on next walk. Not surfaced in the snapshots
  captured. `[MEDIUM]`
- **Misc operational facts (CHANGELOG-anchored):**
  `AGY_CLI_HIDE_ACCOUNT_INFO` env var hides email + plan tier from the
  header (v1.0.2); `AGY_CLI_DISABLE_LATEX` disables LaTeX terminal
  rendering (v1.0.4); conversations persist as SQLite `.db` files and
  headless `-p` metadata caches under
  `~/.gemini/antigravity-cli/cache/` (v1.0.4/v1.0.5). `[MEDIUM]`
  ([CHANGELOG.md](https://github.com/google-antigravity/antigravity-cli/blob/main/CHANGELOG.md) v1.0.2/v1.0.4/v1.0.5)
- **Cross-vendor review flag set** (consumed by `scripts/cross-vendor-review.sh` per [`cross-vendor-review.md`](../../protocols/cross-vendor-review.md)):

  ```
  agy -p "<prompt>" --sandbox
  ```

  Four caveats:
  (a) `--sandbox` enforces shell-command containment, NOT file-write
  read-only — Antigravity has no documented one-shot CLI read-only
  contract.
  (b) Output is plain text, not JSON — parsing relies on
  string-matching the rubric's `### Anchored observations` /
  `### No-anchor observations` headers verbatim. Less robust than
  JSON.
  (c) `--print` mode behavior with permission prompts in non-interactive
  context is the live smoke-test question — does it block on prompts
  (hang) or auto-reject (safe but useless)?
  (d) **Version floor: agy ≥ 1.0.6** — `--sandbox` silently failed to
  propagate in `-p` mode before v1.0.6 (CHANGELOG). The script's
  antigravity case should gate on `agy --version` before trusting the
  sandbox (follow-up queued, not yet implemented).

  Smoke test pending — see §10 for the open question. `[MEDIUM]`

---

## 10. Gaps / Antigravity-CLI-down notes

- **No direct read-only contract for one-shot CLI invocation.**
  Antigravity offers `/permissions strict` inside the TUI and
  `enableTerminalSandbox` via settings.json, but NO `--read-only` flag
  for `agy --print`. Cross-vendor review use requires settings.json
  configuration + verification that `--print` mode honors the
  persistent permission preset. `[STABLE]`
- **No JSON output format documented.** All output is plain text from
  `--print` mode. Parsing the rubric's `### Anchored observations` /
  `### No-anchor observations` shape relies on the agent emitting it
  verbatim — a known fragility class when peer vendors don't expose a
  structured output mode. Mitigation: aggressive prompt-shaping in the
  rubric (see [`plan-review.md`](../../protocols/plan-review.md) for
  one example). `[MEDIUM]`
- **Settings.json applicability.** The settings file lives at
  `~/.gemini/antigravity-cli/settings.json`. Whether this repo's
  project-level `.gemini/settings.json` (with
  `context.fileName: ["AGENTS.md"]`) automatically applies to
  Antigravity needs verification at smoke-test time. `[MEDIUM]`
- **No agy CLI versioning of the docs.** The Antigravity docs at
  `antigravity.google/docs/*` don't surface CLI-version-tagged
  history. Behavior may shift between releases without notice. Treat
  any documented behavior as `[VOLATILE]` until pinned by smoke test
  on the local install. `[VOLATILE]`
- **Antigravity-CLI-down posture:** every meta-layer artifact in
  [`markdowns/`](../../) is acceptable in degraded mode. Substance
  (markdown, AGENTS.md, protocols, scripts) is portable; the loss is
  the Google-side cross-vendor reviewer surface — Claude + Codex would
  have to carry the load. `[STABLE]`
- **Live smoke-test pending.** The cross-vendor review integration
  question — whether `agy --print --sandbox` produces parseable,
  effectively-read-only output for a rubric-shaped review — needs
  empirical verification in your project before relying on
  Antigravity as the peer reviewer. Run a single small-rubric pass
  against a throwaway target and inspect for unexpected disk writes.
  Must be run on **agy ≥ 1.0.6** (see §9 sandbox version floor). The
  smoke test doubles as the re-trigger for the remaining
  low-confidence TBDs in §1 / §3 / §4 ("next agy install or first
  Antigravity-as-reviewer run"). §2 (skills) was confirmed against
  official docs on the 2026-06-20 walk and is no longer pending.

## See also

- [`markdowns/agents/README.md`](../README.md) — index for the vendor
  knowledge files.
- [`markdowns/protocols/cross-vendor-review.md`](../../protocols/cross-vendor-review.md) —
  downstream consumer (cross-vendor review rubric, the cross-vendor review script).
- [`markdowns/meta-layer/cross-vendor-harness.md`](../../meta-layer/cross-vendor-harness.md) —
  cross-vendor topology + sync mechanics (Antigravity reads
  `AGENTS.md` via the project-level `.gemini/settings.json`
  `context.fileName` override).
