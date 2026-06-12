# `.gemini/` — Antigravity CLI's project-level config

This directory holds **Antigravity CLI's** project-level config. The
name is `.gemini/` because Antigravity reads its config root from
`~/.gemini/` — Google chose to keep the path for migration continuity.
The contents here are Antigravity's, not Gemini's. Gemini CLI is not
an active vendor in this template.

## What's here and why

- **`settings.json`** — sets `context.fileName: ["AGENTS.md"]`. Tells
  Antigravity's instruction-file lookup to read `AGENTS.md` instead
  of searching for a vendor-named instruction file. Without this
  override Antigravity would not find the canonical instructions.

## Why not rename to `.antigravity/`?

Antigravity CLI explicitly reads its config from `~/.gemini/` (per the
published `cli-using` docs). Renaming to `.antigravity/` would break
the path Antigravity actually uses.

## What to do if you don't use Antigravity

Delete the directory. `scripts/cross-vendor-review.sh` and the
canonical-source sync mechanism in `scripts/sync-agents-md.sh` do not
depend on `.gemini/`. Only Antigravity reads from here.
`scripts/setup.sh` does this prune automatically when you exclude
Antigravity from the vendor set.

## See also

- [`markdowns/meta-layer/cross-vendor-harness.md`](../markdowns/meta-layer/cross-vendor-harness.md)
  — full per-vendor consumption topology.
- [`markdowns/agents/vendor-knowledge/antigravity-cli.md`](../markdowns/agents/vendor-knowledge/antigravity-cli.md)
  — Antigravity CLI capability + installer details.
