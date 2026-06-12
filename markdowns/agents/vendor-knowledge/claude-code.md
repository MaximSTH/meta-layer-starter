---
name: vendor-knowledge-claude-code
description: Volatility-tagged knowledge of Claude Code (CLI) — canonical file, skills, subagents, hooks, auth, rate limits, cost, MCP, headless. Drives cross-vendor scripts and /refresh-vendor.
status: reference
last-verified: 2026-06-10
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
  `/init` reads an existing `AGENTS.md` when generating `CLAUDE.md`.
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
  or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`. `[MEDIUM]`
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
- **Frontmatter — fully-supported fields:** `name`, `description`,
  `disable-model-invocation`, `user-invocable`, `allowed-tools`,
  `disallowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`,
  `paths`, `arguments`, `argument-hint`, `when_to_use`, `shell`. Only
  `description` is recommended; all others optional. `[MEDIUM]`
  ([code.claude.com/docs/en/skills#frontmatter-reference](https://code.claude.com/docs/en/skills))
- **Cross-vendor portable subset:** `name` + `description` only.
  Other fields are Claude-Code-specific and omitted from skills authored at
  `.agents/skills/` for cross-vendor portability. `[STABLE]`
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
  (v2.1.145+), plus more. Disable via the `disableBundledSkills`
  setting; per-skill visibility via `skillOverrides`. Listed in
  [code.claude.com/docs/en/commands](https://code.claude.com/docs/en/commands). `[MEDIUM]`
- **`claude ultrareview` subcommand** (also reachable as `/code-review
  ultra`): cloud-hosted multi-agent review of the current branch or a
  PR number, prints findings. `[MEDIUM]` (`claude --help`, v2.1.170)
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
- **Subagents canNOT spawn subagents.** Documented explicitly to "prevent
  infinite nesting." Use built-in `Plan` / `Explore` agents which handle
  research without nesting. `[STABLE]`
  ([code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents))
- **`agent teams` is a separate primitive.** For multi-agent communication
  across separate sessions; not used in this repo's foundation. `[MEDIUM]`
- **Frontmatter — supported fields:** `description`, `prompt`, `tools`,
  `disallowedTools`, `model`, `permissionMode`, `mcpServers`, `hooks`,
  `maxTurns`, `skills`, `initialPrompt`, `memory`, `effort`, `background`,
  `isolation`, `color`. Plugin subagents ignore `hooks`, `mcpServers`,
  `permissionMode` for security. `[MEDIUM]`
- **Built-in subagents:** `Explore`, `Plan`, `general-purpose`, plus skill-
  forked agents via `context: fork`. `[STABLE]`

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
  `CwdChanged`, `PreCompact`, `PostCompact`, `Notification`,
  `MessageDisplay`, `WorktreeCreate`, `WorktreeRemove`, `Elicitation`,
  `ElicitationResult`. `[MEDIUM]`
  ([code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks))
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
Effective 2026-06-15, `claude -p` / Agent SDK usage moves to a separate
monthly credit (see below) — interactive limits no longer apply to it.**

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
- **Agent SDK credit (effective 2026-06-15):** `claude -p` / Agent SDK
  usage on subscription plans stops drawing from interactive usage
  limits and draws from a separate monthly credit instead — Pro $20,
  Max 5x $100, Max 20x $200, Team $20 (standard) / $100 (premium
  seats). When depleted, usage flows to API-rate usage credits if
  enabled; otherwise SDK requests stop until the credit refreshes.
  Interactive sessions are unchanged. `[VOLATILE]`
  ([code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless),
  [support.claude.com/en/articles/15036540](https://support.claude.com/en/articles/15036540-use-the-claude-agent-sdk-with-your-claude-plan))
- **Rate-limit error surface in headless mode:** stream-json events include
  `error: "rate_limit"` in the `system/api_retry` event. Use this to detect
  exhaustion programmatically. `[STABLE]`
  ([code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless))
- **Recovery posture:** on rate-limit hit, abort and re-run via
  `cross-vendor-review.sh --to <other-vendor>`. No automatic API-key
  fallback. Note: from 2026-06-15, scripted `claude -p` exhaustion is
  Agent-SDK-credit exhaustion (monthly refresh, not a 5-hour window) —
  vendor-switch remains the only same-day recovery.

---

## 7. Cost

- **Free:** $0/mo. Does NOT include Claude Code. `[VOLATILE]`
  ([claude.com/pricing](https://claude.com/pricing))
- **Pro:** $17/mo annual ($200/yr) or $20/mo monthly. Includes Claude Code.
  `[VOLATILE]` ([claude.com/pricing](https://claude.com/pricing))
- **Max 5x:** "From $100/mo" — 5× Pro usage. Includes Claude Code. `[VOLATILE]`
- **Max 20x:** "From $200/mo" (price varies by tier) — 20× Pro usage. Includes
  Claude Code. `[VOLATILE]` **low-confidence as of 2026-06-10:** the
  [claude.com/pricing](https://claude.com/pricing) WebFetch returned
  "From $100" for both Max tiers (suspected extraction artifact); claim
  kept, re-verify in a browser next walk.
- **API alt:** Pay-per-token via Claude API at standard model rates (Opus,
  Sonnet, Haiku). Subscriptions reach API-rate purchase once limits hit.
  `[STABLE]` ([anthropic.com/api](https://www.anthropic.com/api))
- **Headless / Agent SDK cost is credit-based from 2026-06-15:** see the
  Agent SDK credit bullet in §6 — scripted `claude -p` runs no longer
  share the interactive subscription window. `[VOLATILE]`
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
  to a subagent / skill via the `mcpServers` frontmatter field. Note:
  the binary's `add-json` help text still says "stdio or SSE" — docs
  and binary conflict on the transport list, and the websocket
  sub-claim is verified against docs only (binary-level check —
  behavioral `add-json` test — pending next walk). Re-tagged
  `[STABLE]` → `[MEDIUM]` until that conflict is resolved at the
  binary channel. `[MEDIUM]`
  ([code.claude.com/docs/en/mcp](https://code.claude.com/docs/en/mcp),
  `claude mcp --help` v2.1.170)
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
  `/skill-name` in the prompt string and Claude Code expands it before
  the run. Only built-in commands that open an interactive dialog
  (`/config`, `/login`) are unavailable. Auto-invocation by description
  match also works. Re-tagged `[STABLE]` → `[MEDIUM]` because the
  behavior flipped within a year. `[MEDIUM]`
  ([code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless);
  `claude --help` v2.1.170: `--bare` "Skills still resolve via
  /skill-name")
- **Bare mode (`--bare`):** skips hooks, LSP, plugin sync, attribution,
  auto-memory, background prefetches, keychain reads, and `CLAUDE.md`
  auto-discovery (per the binary; docs also list skills/MCP
  auto-discovery — binary wins on detail: skills still resolve via
  `/skill-name`). Auth is strictly `ANTHROPIC_API_KEY` or
  `apiKeyHelper`. Recommended for CI / scripted calls; will become the
  default for `-p` in a future release. `[MEDIUM]`
  (`claude --help` v2.1.170,
  [code.claude.com/docs/en/headless](https://code.claude.com/docs/en/headless))
- **Tool approval flags:** `--allowedTools "Read,Edit,Bash"`,
  `--permission-mode default | acceptEdits | auto | dontAsk |
  bypassPermissions | plan` (`auto` added since last walk: background
  classifier reviews commands), `--permission-prompt-tool <mcp-tool>`.
  `[STABLE]` (`claude --help` v2.1.170)
- **Output formats:** `text` (default), `json` (with `total_cost_usd`,
  `session_id`, `result`), `stream-json` (NDJSON, includes `system/init`,
  `system/api_retry`, `stream_event`). `--json-schema` enforces a schema;
  the validated payload lands in the `structured_output` field. `[STABLE]`
  ([code.claude.com/docs/en/headless#get-structured-output](https://code.claude.com/docs/en/headless))
- **Cost / budget caps:** `--max-budget-usd <amount>`, `--max-turns <n>`,
  `--fallback-model <name[,name...]>` (comma-separated fallback chain).
  `[STABLE]` (`claude --help` v2.1.170)
- **Headless mechanics (added since last walk):** piped stdin capped at
  10MB (v2.1.128+, hard error above); background Bash tasks terminated
  ~5s after the final result (v2.1.163+); new flags `--tools` (restrict
  built-in tool set), `--safe-mode` (all customizations disabled),
  `--disable-slash-commands`, `--effort <low|medium|high|xhigh|max>`.
  `[MEDIUM]` (`claude --help` v2.1.170,
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

---

## 10. Gaps / Claude-Code-down notes

- **Subagent → subagent nesting:** unsupported. Compounds with Codex's
  `max_depth=1` default. Fan-out wider than 1-level requires shell-driven
  orchestration. `[STABLE]`
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
  authoring path. `[MEDIUM]` (empirical test, v2.1.170)
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
