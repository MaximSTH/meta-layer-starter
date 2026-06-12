# `.claude/hooks/` — Claude Code hooks (vendor-specific)

These hooks are **Claude-Code-specific by design**. Claude Code exposes
~28 hook events (`PreToolUse`, `PostToolUse`, `SessionStart`, etc.);
Codex CLI has ~6 with different names and semantics; Antigravity's
hook surface is documented but distinct. **There is no portable
abstraction across vendors.** Hooks that need to run cross-vendor must
be re-authored per-vendor in each vendor's hook surface.

## What's here

| Hook | Event | Purpose |
|---|---|---|
| `pretool_read_secrets.sh` | `PreToolUse` on `Read` | Denies Claude's read of common secret-file paths (`.env`, `id_rsa`, etc.). |
| `pretool_write_secrets.sh` | `PreToolUse` on `Write` / `Edit` / `MultiEdit` | Denies Claude's write/edit of common secret-file paths and refuses to embed secret-looking values in committed files. |

Both are referenced from `.claude/settings.json`.

## Why this is Claude-only

The Read/Write/Edit tools the hooks intercept are Claude Code's
native tool surface. Codex / Antigravity have their own tool surfaces
and their own pre-tool hook mechanisms; the deny rules would need
re-translation per-vendor and the file paths would change. Rather than
pretend a portable wrapper exists, we document the asymmetry and let
each vendor have its own hook surface.

## Adapt for your project

- Add per-event hooks here for Claude-Code-side safety nets.
- If you need a cross-vendor safety net for the same concern
  (e.g., secret-file deny on Codex's read tool too), author a parallel
  hook in Codex's hook surface (`~/.codex/hooks.json`) — it won't
  share code with the Claude side, but both can call into a shared
  utility script if useful.

## See also

- [`markdowns/meta-layer/cross-vendor-harness.md`](../../markdowns/meta-layer/cross-vendor-harness.md)
  — the "asymmetry that's NOT going away" section explains the
  hook-portability problem.
- [`markdowns/agents/vendor-knowledge/claude-code.md`](../../markdowns/agents/vendor-knowledge/claude-code.md)
  §4 — Claude Code hook system reference.
