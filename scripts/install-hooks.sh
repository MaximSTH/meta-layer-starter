#!/bin/sh

# Install the repo's pre-commit hook into .git/hooks/.
# Run once after cloning, and re-run whenever scripts/pre-commit changes.

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
HOOK_SRC="$SCRIPT_DIR/pre-commit"
HOOK_DEST="$REPO_ROOT/.git/hooks/pre-commit"

if [ ! -f "$HOOK_SRC" ]; then
  echo "❌ $HOOK_SRC not found." >&2
  exit 1
fi

if [ ! -d "$REPO_ROOT/.git/hooks" ]; then
  echo "❌ $REPO_ROOT/.git/hooks not found — are you in a git clone?" >&2
  exit 1
fi

# If a pre-commit hook already exists, back it up before overwriting. The
# user may have husky / lefthook / pre-commit-go installed, or a
# hand-authored hook from a previous project — silently clobbering it
# would lose work.
if [ -f "$HOOK_DEST" ]; then
  if cmp -s "$HOOK_SRC" "$HOOK_DEST"; then
    echo "ℹ️  Pre-commit hook already installed and identical — no change."
    exit 0
  fi
  BACKUP="$HOOK_DEST.backup.$(date +%Y%m%d-%H%M%S)"
  mv "$HOOK_DEST" "$BACKUP"
  echo "⚠️  Existing pre-commit hook backed up to: $BACKUP"
  echo "    Review and merge by hand if it had custom rules you need."
fi

cp "$HOOK_SRC" "$HOOK_DEST"
chmod +x "$HOOK_DEST"

echo "✅ Pre-commit hook installed at .git/hooks/pre-commit"
