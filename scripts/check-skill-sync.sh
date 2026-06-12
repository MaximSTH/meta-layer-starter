#!/bin/sh
# check-skill-sync.sh — invoked by pre-commit + manual smoke checks.
#
# Fails (exits non-zero) if any file under .agents/skills/<name>/ differs
# from its .claude/skills/<name>/ counterpart. .agents/ is canonical;
# .claude/ is mechanically duplicated via scripts/sync-skills.sh. The
# entire skill subdirectory is mirrored (SKILL.md + any helper / asset
# / prompt files).
#
# Usage: scripts/check-skill-sync.sh [--quiet] [--staged]
#   --quiet   Suppress success line (used by pre-commit to avoid noise
#             on commits that don't touch skills).
#   --staged  Read content from the git index (`git show :<path>`)
#             instead of the working tree. Used by pre-commit so partial
#             staging (stage bad, edit good unstaged) doesn't bypass the
#             gate. Same pattern as AGENTS.md → CLAUDE.md sync.
#
# Spec: markdowns/protocols/build-feature.md
#  + markdowns/meta-layer/cross-vendor-harness.md (sync mechanics)

set -e

QUIET=0
STAGED=0
while [ $# -gt 0 ]; do
  case "$1" in
    --quiet) QUIET=1; shift ;;
    --staged) STAGED=1; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
AGENTS_SKILLS="$REPO_ROOT/.agents/skills"
CLAUDE_SKILLS="$REPO_ROOT/.claude/skills"

# Decide whether there's anything to check. In --staged mode, look at the
# git index (a staged-new skill counts even if the working-tree dir is
# absent). Otherwise check the working tree.
if [ "$STAGED" = "1" ]; then
  HAS_AGENTS=0
  if git -C "$REPO_ROOT" ls-files --error-unmatch -- '.agents/skills/*' >/dev/null 2>&1; then
    HAS_AGENTS=1
  elif git -C "$REPO_ROOT" diff --cached --name-only --diff-filter=A -- '.agents/skills/*' 2>/dev/null | grep -q .; then
    HAS_AGENTS=1
  fi
  if [ "$HAS_AGENTS" = "0" ] && [ ! -d "$CLAUDE_SKILLS" ]; then
    [ "$QUIET" = "1" ] || echo "ℹ️  No skill files in index or working tree — skill sync check skipped."
    exit 0
  fi
else
  if [ ! -d "$AGENTS_SKILLS" ]; then
    [ "$QUIET" = "1" ] || echo "ℹ️  No .agents/skills/ directory — skill sync check skipped."
    exit 0
  fi
fi

# read_path PATH — print the content of PATH. In --staged mode, reads
# from the git index via `git show :PATH`. Otherwise reads the working
# tree via cat. PATH is relative to REPO_ROOT.
read_path() {
  REL="$1"
  if [ "$STAGED" = "1" ]; then
    git -C "$REPO_ROOT" show ":$REL" 2>/dev/null || return 1
  else
    [ -f "$REPO_ROOT/$REL" ] && cat "$REPO_ROOT/$REL"
  fi
}

# path_exists PATH — true if PATH exists (in stage when --staged, else
# in working tree).
path_exists() {
  REL="$1"
  if [ "$STAGED" = "1" ]; then
    git -C "$REPO_ROOT" ls-files --error-unmatch "$REL" >/dev/null 2>&1
  else
    [ -f "$REPO_ROOT/$REL" ]
  fi
}

# list_skill_files SUBDIR — list paths (relative to REPO_ROOT) of files
# inside SUBDIR. In --staged mode, lists from the git index. Otherwise
# lists from the working tree.
list_skill_files() {
  SUBDIR="$1"
  if [ "$STAGED" = "1" ]; then
    # `git ls-files <dir>` lists tracked files; also include staged-only
    # additions via `git diff --cached --name-only --diff-filter=A`.
    {
      git -C "$REPO_ROOT" ls-files "$SUBDIR" 2>/dev/null
      git -C "$REPO_ROOT" diff --cached --name-only --diff-filter=A -- "$SUBDIR" 2>/dev/null
    } | sort -u
  else
    find "$REPO_ROOT/$SUBDIR" -type f 2>/dev/null | sed "s|^$REPO_ROOT/||"
  fi
}

DIVERGED=""
MISSING=""
ORPHANED=""

# Enumerate skill names. In --staged mode, enumerate from the git index so
# a staged-new skill whose working-tree counterpart was removed before
# commit is still checked. Working-tree-only enumeration would miss it.
list_skill_names() {
  ROOT_REL="$1"  # ".agents/skills" or ".claude/skills"
  if [ "$STAGED" = "1" ]; then
    git -C "$REPO_ROOT" ls-files "$ROOT_REL/" 2>/dev/null \
      | awk -F/ -v root="$ROOT_REL" '$0 ~ root"/[^/]+/" {print $3}' \
      | sort -u
  else
    ROOT_ABS="$REPO_ROOT/$ROOT_REL"
    [ -d "$ROOT_ABS" ] || return 0
    for D in "$ROOT_ABS"/*/; do
      [ -d "$D" ] || continue
      basename "$D"
    done
  fi
}

AGENTS_NAMES=$(list_skill_names ".agents/skills")
CLAUDE_NAMES=$(list_skill_names ".claude/skills")

# files_equal SRC_REL DEST_REL — byte-identical comparison. Writes both
# contents to temp files (preserving trailing newlines) and cmp's them.
# Necessary because $(command-substitution) strips trailing newlines, so
# string comparison would equate files differing only in final newline.
files_equal() {
  SRC_REL="$1"; DEST_REL="$2"
  TMP_SRC=$(mktemp); TMP_DEST=$(mktemp)
  if [ "$STAGED" = "1" ]; then
    git -C "$REPO_ROOT" show ":$SRC_REL" > "$TMP_SRC" 2>/dev/null
    git -C "$REPO_ROOT" show ":$DEST_REL" > "$TMP_DEST" 2>/dev/null
  else
    [ -f "$REPO_ROOT/$SRC_REL" ] && cp "$REPO_ROOT/$SRC_REL" "$TMP_SRC"
    [ -f "$REPO_ROOT/$DEST_REL" ] && cp "$REPO_ROOT/$DEST_REL" "$TMP_DEST"
  fi
  RC=0
  cmp -s "$TMP_SRC" "$TMP_DEST" || RC=1
  rm -f "$TMP_SRC" "$TMP_DEST"
  return $RC
}

MISSING_SKILL_MD=""

# Forward pass: every .agents/skills/<name>/ file must have a matching
# .claude/skills/<name>/ counterpart with identical content. A skill
# subdirectory without SKILL.md is malformed — a helper-only subdir under
# .agents/skills/<name>/ that ships without a top-level SKILL.md is
# anomalous and gets flagged separately.
for SKILL_NAME in $AGENTS_NAMES; do
  AGENTS_SUBDIR=".agents/skills/$SKILL_NAME"
  CLAUDE_SUBDIR=".claude/skills/$SKILL_NAME"

  if ! path_exists "$AGENTS_SUBDIR/SKILL.md"; then
    SUBDIR_FILES=$(list_skill_files "$AGENTS_SUBDIR")
    if [ -n "$SUBDIR_FILES" ]; then
      MISSING_SKILL_MD="$MISSING_SKILL_MD
   $AGENTS_SUBDIR/ (has files but no SKILL.md — every skill subdir needs SKILL.md)"
    fi
    continue
  fi

  for SRC_REL in $(list_skill_files "$AGENTS_SUBDIR"); do
    DEST_REL=$(echo "$SRC_REL" | sed "s|^.agents/skills/|.claude/skills/|")

    if ! path_exists "$DEST_REL"; then
      MISSING="$MISSING
   $DEST_REL (source: $SRC_REL)"
      continue
    fi

    if ! files_equal "$SRC_REL" "$DEST_REL"; then
      DIVERGED="$DIVERGED
   $SRC_REL ↔ $DEST_REL"
    fi
  done
done

# Reverse pass: every .claude/skills/<name>/ subdirectory file must have
# an .agents/skills/<name>/ counterpart. Loose .md files at .claude/skills/
# root remain Claude-only by design (out of scope).
for SKILL_NAME in $CLAUDE_NAMES; do
  CLAUDE_SUBDIR=".claude/skills/$SKILL_NAME"
  AGENTS_SUBDIR=".agents/skills/$SKILL_NAME"

  for DEST_REL in $(list_skill_files "$CLAUDE_SUBDIR"); do
    SRC_REL=$(echo "$DEST_REL" | sed "s|^.claude/skills/|.agents/skills/|")
    if ! path_exists "$SRC_REL"; then
      ORPHANED="$ORPHANED
   $DEST_REL (no $SRC_REL counterpart)"
    fi
  done
done

if [ -n "$DIVERGED" ] || [ -n "$MISSING" ] || [ -n "$ORPHANED" ] || [ -n "$MISSING_SKILL_MD" ]; then
  echo ""
  echo "❌ Skill files out of sync between .agents/skills/ and .claude/skills/."
  if [ -n "$DIVERGED" ]; then
    echo "   Diverged:$DIVERGED"
  fi
  if [ -n "$MISSING" ]; then
    echo "   Missing on Claude side:$MISSING"
  fi
  if [ -n "$MISSING_SKILL_MD" ]; then
    echo "   Skill subdirs missing SKILL.md:$MISSING_SKILL_MD"
  fi
  if [ -n "$ORPHANED" ]; then
    echo "   Claude-side orphans (no .agents/ source):$ORPHANED"
    echo "   Subdirectory-shaped skills under .claude/skills/ must originate"
    echo "   from .agents/skills/. If this is a Claude-only skill, ship as a"
    echo "   flat .md at .claude/skills/<name>.md instead of a subdirectory."
    echo "   Orphans are removed by scripts/sync-skills.sh."
  fi
  echo ""
  echo "   .agents/skills/ is the authored source — never edit .claude/skills/<name>/ by hand."
  echo "   Regenerate via: scripts/sync-skills.sh (mirrors .agents/skills/ → .claude/skills/, removes orphans)."
  echo "   Then: git add .claude/skills/ && retry the commit."
  echo "   Spec: markdowns/protocols/build-feature.md + markdowns/meta-layer/cross-vendor-harness.md"
  exit 1
fi

[ "$QUIET" = "1" ] || echo "✅ Skill sync clean (.agents/skills/ ↔ .claude/skills/)."
