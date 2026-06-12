#!/bin/sh
# sync-skills.sh — regenerate .claude/skills/<name>/SKILL.md from .agents/skills/<name>/SKILL.md
#
# Mirrors the scripts/sync-agents-md.sh pattern. .agents/skills/ is the
# canonical, vendor-agnostic source. .claude/skills/ subdirectories are
# mechanically duplicated copies — Claude Code reads from there.
#
# Loose .md files at .claude/skills/ root (e.g., user-authored
# Claude-only skills) are out of scope; this script only touches
# subdirectory-shaped skills.
#
# Run after editing any .agents/skills/<name>/SKILL.md; the pre-commit
# gate fails if the two sides diverge.
#
# === Overlay convention (FUTURE — not active today) ===
# When a skill needs Claude-Code-specific frontmatter (effort, hooks,
# allowed-tools, model, etc.) that isn't portable across vendors, the
# Claude-side overlay lives at:
#
#     .agents/skills/<name>/.claude.frontmatter.yml
#
# This script will be extended to merge that overlay into the synced
# .claude/skills/<name>/SKILL.md frontmatter on emit. Codex / Antigravity
# never see the overlay; they read the portable .agents/ subset.
#
# As of this revision, none of the shipped skills carry Claude-specific
# frontmatter, so the overlay code path is unused. The convention is
# documented here so future skill authors know where it goes.
#
# See: markdowns/meta-layer/cross-vendor-harness.md

set -e

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
AGENTS_SKILLS="$REPO_ROOT/.agents/skills"
CLAUDE_SKILLS="$REPO_ROOT/.claude/skills"

# Soft-skip when no source exists. A fresh clone of the template without
# any authored skills should commit cleanly; this script only acts when
# there is canonical content to sync.
if [ ! -d "$AGENTS_SKILLS" ]; then
  echo "ℹ️  $AGENTS_SKILLS does not exist — nothing to sync. (Create it when you author your first skill.)"
  exit 0
fi

# Create the mirror directory if it doesn't exist yet. A first-run user
# who authors skills in .agents/ shouldn't have to manually create the
# .claude/ counterpart.
mkdir -p "$CLAUDE_SKILLS"

# Stage the regenerated mirror in the same commit as the source edit.
# See the equivalent block in sync-agents-md.sh for the rationale.
STAGE_MIRRORS=0
if [ -d "$REPO_ROOT/.git" ] && [ -n "${GIT_INDEX_FILE:-}" -o -n "${PRE_COMMIT:-}" -o "${1:-}" = "--stage" ]; then
  STAGE_MIRRORS=1
fi

SYNCED=0
for AGENTS_SKILL_DIR in "$AGENTS_SKILLS"/*/; do
  [ -d "$AGENTS_SKILL_DIR" ] || continue
  SKILL_NAME=$(basename "$AGENTS_SKILL_DIR")
  SRC="$AGENTS_SKILL_DIR/SKILL.md"
  DEST_DIR="$CLAUDE_SKILLS/$SKILL_NAME"

  if [ ! -f "$SRC" ]; then
    echo "⚠️  $SRC not found — skipping $SKILL_NAME" >&2
    continue
  fi

  # Mirror the entire skill subdirectory, not just SKILL.md. Skills can
  # ship helper / asset / prompt files alongside SKILL.md; they all need
  # to round-trip identically. rsync would be cleaner but we stay POSIX
  # with cp -R for cross-vendor portability.
  rm -rf "$DEST_DIR"
  cp -R "$AGENTS_SKILL_DIR" "$DEST_DIR"
  [ "$STAGE_MIRRORS" -eq 1 ] && git add "$DEST_DIR" 2>/dev/null || true
  SYNCED=$((SYNCED + 1))
done

# Remove orphans on the Claude side — subdirectory-shaped skills with no
# matching .agents/skills/ source. Loose .md files at .claude/skills/ root
# are out of scope (Claude-only by design) and are NOT removed. Without
# this pass, the orphan check in check-skill-sync.sh would tell users
# "run sync-skills.sh" but the run wouldn't clear the failure.
REMOVED=0
if [ -d "$CLAUDE_SKILLS" ]; then
  for CLAUDE_SKILL_DIR in "$CLAUDE_SKILLS"/*/; do
    [ -d "$CLAUDE_SKILL_DIR" ] || continue
    SKILL_NAME=$(basename "$CLAUDE_SKILL_DIR")
    if [ ! -f "$AGENTS_SKILLS/$SKILL_NAME/SKILL.md" ]; then
      rm -rf "$CLAUDE_SKILL_DIR"
      REMOVED=$((REMOVED + 1))
    fi
  done
fi

echo "✅ Synced $SYNCED skill(s) from .agents/skills/ to .claude/skills/."
if [ "$REMOVED" -gt 0 ]; then
  echo "✅ Removed $REMOVED orphan(s) from .claude/skills/ (no .agents/ source)."
fi
