#!/bin/sh
# check-skill-frontmatter.sh — invoked by pre-commit + manual smoke checks.
#
# Fails (exits non-zero) if any .agents/skills/<name>/SKILL.md frontmatter
# contains fields outside the portable cross-vendor subset.
#
# Allowed fields (the portable subset):
#   - name
#   - description
#
# Banned fields (vendor-specific or non-portable):
#   - tools          (Claude Code specific)
#   - user_invocable (vendor-prefixed convention)
#   - model          (vendor-specific)
#   - allowed-tools  (Claude Code specific)
#   - argument-hint  (vendor-specific)
#   - status         (skills don't use markdown-lifecycle status — that's
#                    for markdowns/ files only)
#   - any field starting with claude:, codex:, vendor:
#
# Rationale: .agents/skills/ is the cross-vendor source. Vendor-specific
# fields break portability when synced to .claude/ — and any vendor's
# fields would break peer vendors' parsers. The two-field minimum
# (name + description) is the SSOT.
#
# Usage: scripts/check-skill-frontmatter.sh [--quiet]
#
# Spec: markdowns/protocols/build-feature.md
#  + markdowns/protocols/README.md (rule R5 — skill descriptions are
#    narrow trigger specs around 80 tokens).

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

# Decide whether there's anything to check. In --staged mode, the git
# index is authoritative — a staged-new skill counts even if the working-
# tree dir is absent. Otherwise check the working tree.
if [ "$STAGED" = "1" ]; then
  HAS_STAGED=0
  if git -C "$REPO_ROOT" ls-files --error-unmatch -- '.agents/skills/*/SKILL.md' >/dev/null 2>&1; then
    HAS_STAGED=1
  elif git -C "$REPO_ROOT" diff --cached --name-only --diff-filter=A -- '.agents/skills/*/SKILL.md' 2>/dev/null | grep -q .; then
    HAS_STAGED=1
  fi
  if [ "$HAS_STAGED" = "0" ]; then
    [ "$QUIET" = "1" ] || echo "ℹ️  No .agents/skills/*/SKILL.md in index — frontmatter check skipped."
    exit 0
  fi
else
  if [ ! -d "$AGENTS_SKILLS" ]; then
    [ "$QUIET" = "1" ] || echo "ℹ️  No .agents/skills/ directory — frontmatter check skipped."
    exit 0
  fi
fi

# When --staged is set, read SKILL.md content from the git index instead
# of the working tree. Mirrors the AGENTS.md → CLAUDE.md sync pattern so
# partial staging (stage bad, edit good unstaged) doesn't bypass the gate.
read_skill_content() {
  REL_PATH="$1"
  if [ "$STAGED" = "1" ]; then
    git -C "$REPO_ROOT" show ":$REL_PATH" 2>/dev/null
  else
    cat "$REPO_ROOT/$REL_PATH" 2>/dev/null
  fi
}

ALLOWED='^(name|description):'
# Exact-name banned fields: vendor-specific or non-portable conventions.
BANNED_EXACT='^(tools|user_invocable|model|allowed-tools|argument-hint|status):'
# Prefix-matched banned: any field starting with these vendor names.
BANNED_PREFIX='^(claude|codex|vendor)[-_a-z0-9]*:'

VIOLATIONS=""
NO_FRONTMATTER=""
MISSING_REQUIRED=""

# Enumerate skill names. In --staged mode, use the git index so a staged-
# new skill whose working-tree copy was removed before commit is still
# checked. Working-tree-only enumeration would miss it.
list_skill_names() {
  if [ "$STAGED" = "1" ]; then
    {
      git -C "$REPO_ROOT" ls-files '.agents/skills/*/SKILL.md' 2>/dev/null
      git -C "$REPO_ROOT" diff --cached --name-only --diff-filter=A -- '.agents/skills/*/SKILL.md' 2>/dev/null
    } \
      | awk -F/ '{print $3}' \
      | sort -u
  else
    [ -d "$AGENTS_SKILLS" ] || return 0
    for D in "$AGENTS_SKILLS"/*/; do
      [ -d "$D" ] || continue
      basename "$D"
    done
  fi
}

for SKILL_NAME in $(list_skill_names); do
  REL_PATH=".agents/skills/$SKILL_NAME/SKILL.md"

  CONTENT=$(read_skill_content "$REL_PATH")
  if [ -z "$CONTENT" ]; then
    # Empty SKILL.md fails both required-field and frontmatter checks. Use
    # NO_FRONTMATTER so the existing error path fires (no opening ---).
    NO_FRONTMATTER="$NO_FRONTMATTER
   $REL_PATH (empty file — needs --- frontmatter with name + description)"
    continue
  fi

  FIRST_LINE=$(echo "$CONTENT" | head -n 1)
  if [ "$FIRST_LINE" != "---" ]; then
    NO_FRONTMATTER="$NO_FRONTMATTER
   $REL_PATH"
    continue
  fi

  # Require the frontmatter block to terminate with a second --- line.
  # Without this guard, an unterminated block silently treats body lines as
  # frontmatter and the unknown-field branch flags them — a confusing
  # error message for what's really a malformed file.
  CLOSE_COUNT=$(echo "$CONTENT" | grep -c '^---$' || true)
  if [ "$CLOSE_COUNT" -lt 2 ]; then
    NO_FRONTMATTER="$NO_FRONTMATTER
   $REL_PATH (unterminated frontmatter — missing closing ---)"
    continue
  fi

  FRONTMATTER=$(echo "$CONTENT" | awk '/^---$/{n++; if (n==2) exit; if (n==1) next} n==1{print}')
  HAS_NAME=0
  HAS_DESCRIPTION=0
  while IFS= read -r LINE; do
    [ -z "$LINE" ] && continue
    case "$LINE" in
      \#*) continue ;;
    esac
    if echo "$LINE" | grep -qE '^name:'; then
      HAS_NAME=1
    fi
    if echo "$LINE" | grep -qE '^description:'; then
      HAS_DESCRIPTION=1
    fi
    if echo "$LINE" | grep -qE "$BANNED_EXACT" || echo "$LINE" | grep -qE "$BANNED_PREFIX"; then
      FIELD=$(echo "$LINE" | sed 's/:.*//')
      VIOLATIONS="$VIOLATIONS
   $REL_PATH — banned field: $FIELD"
      continue
    fi
    if echo "$LINE" | grep -qE '^[a-zA-Z][-_a-zA-Z0-9]*:'; then
      if ! echo "$LINE" | grep -qE "$ALLOWED"; then
        FIELD=$(echo "$LINE" | sed 's/:.*//')
        VIOLATIONS="$VIOLATIONS
   $REL_PATH — unknown field: $FIELD (allowed: name, description)"
      fi
    fi
  done <<EOF
$FRONTMATTER
EOF

  MISSING_LIST=""
  if [ "$HAS_NAME" = "0" ]; then
    MISSING_LIST="$MISSING_LIST name"
  fi
  if [ "$HAS_DESCRIPTION" = "0" ]; then
    MISSING_LIST="$MISSING_LIST description"
  fi
  if [ -n "$MISSING_LIST" ]; then
    MISSING_REQUIRED="$MISSING_REQUIRED
   $REL_PATH — missing required field(s):$MISSING_LIST"
  fi
done

if [ -n "$NO_FRONTMATTER" ]; then
  echo ""
  echo "❌ .agents/skills/ files missing YAML frontmatter (opening --- on line 1):$NO_FRONTMATTER"
  echo "   Required: opening --- block with name + description fields."
  echo "   Spec: markdowns/protocols/build-feature.md + markdowns/meta-layer/cross-vendor-harness.md"
  exit 1
fi

if [ -n "$VIOLATIONS" ]; then
  echo ""
  echo "❌ .agents/skills/ frontmatter contains disallowed fields:$VIOLATIONS"
  echo ""
  echo "   Allowed: name, description (portable cross-vendor subset)."
  echo "   Banned:  tools, user_invocable, model, allowed-tools, argument-hint, status,"
  echo "            anything starting with claude/codex/vendor."
  echo "   Rationale: .agents/skills/ is the vendor-agnostic source; vendor-specific"
  echo "   fields break portability when synced to .claude/. Two-field minimum is SSOT."
  echo "   Spec: markdowns/protocols/build-feature.md + markdowns/meta-layer/cross-vendor-harness.md"
  exit 1
fi

if [ -n "$MISSING_REQUIRED" ]; then
  echo ""
  echo "❌ .agents/skills/ frontmatter missing required fields:$MISSING_REQUIRED"
  echo "   The portable subset is two-field minimum: both name and description"
  echo "   must be present. A skill without a description cannot auto-trigger."
  echo "   Spec: markdowns/protocols/build-feature.md + markdowns/meta-layer/cross-vendor-harness.md"
  exit 1
fi

[ "$QUIET" = "1" ] || echo "✅ Skill frontmatter portable subset clean (.agents/skills/)."
