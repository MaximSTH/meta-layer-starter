#!/usr/bin/env bash
# setup.sh — one-time configuration after cloning the template.
#
# Asks which AI coding CLIs you actually use, then prunes vendor
# knowledge files, configs, and cross-vendor-review.sh cases for the
# vendors you don't. Leaves Claude Code as the always-active primary.
#
# Run once after `git clone`. Re-runnable if you add or drop a vendor
# later (re-prunes based on current selection).
#
# Compatible with macOS bash 3.2+ (no associative arrays or bash 4 features).
#
# See: markdowns/meta-layer/cross-vendor-harness.md

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$REPO_ROOT"

# Decide how to source VENDORS. Three valid paths:
#   (1) --vendors "<list>" passed explicitly → use it
#   (2) Interactive TTY → prompt the user
#   (3) Non-TTY without --vendors → REFUSE to prune. Exit non-zero with
#       guidance. This script makes destructive file deletions (vendor
#       knowledge files, .gemini/) and rewrites scripts/cross-vendor-review.sh;
#       defaulting to "claude" in CI silently nukes anyone running setup
#       in a Dockerfile or pipeline. Force an explicit decision.
VENDORS=""
if [ "${1:-}" = "--vendors" ] && [ -n "${2:-}" ]; then
  VENDORS="$2"
elif [ ! -t 0 ]; then
  cat >&2 <<'EOF'
Error: setup.sh is destructive (prunes vendor knowledge files, removes
.gemini/, rewrites cross-vendor-review.sh) and was invoked in a
non-interactive shell (stdin is not a TTY).

To prevent silent damage in CI / Docker / automation, this script
refuses to default. Re-run with an explicit vendor selection:

  scripts/setup.sh --vendors "claude"                       # solo
  scripts/setup.sh --vendors "claude codex"                 # cross-vendor
  scripts/setup.sh --vendors "claude codex antigravity"     # full multi-vendor

No files have been modified.
EOF
  exit 1
else
  cat <<'EOF'
Which AI coding CLIs do you use?

Options (space-separated):
  claude        Claude Code (Anthropic)        ← always kept; required as primary
  codex         Codex CLI (OpenAI)
  antigravity   Antigravity CLI (Google)

Solo mode (default if you press Enter): claude only.
Cross-vendor mode (recommended for stakes-bearing projects): claude codex
Full multi-vendor: claude codex antigravity

EOF
  read -r -p "> " VENDORS
fi
VENDORS=${VENDORS:-claude}

# Claude is always kept; the template's primary harness assumption.
case " $VENDORS " in
  *" claude "*) ;;
  *) VENDORS="claude $VENDORS" ;;
esac

# Validate vendor names and define a contains() helper.
for v in $VENDORS; do
  case "$v" in
    claude|codex|antigravity) ;;
    *)
      echo "Error: unknown vendor '$v'. Supported: claude codex antigravity." >&2
      exit 2;;
  esac
done

# contains <name> — returns 0 if $VENDORS contains <name> as a whole word.
contains() {
  case " $VENDORS " in
    *" $1 "*) return 0 ;;
    *) return 1 ;;
  esac
}

echo
echo "Configuring for: $VENDORS"
echo

# ── Prune vendor knowledge files ──────────────────────────────────────
PRUNED_VENDORS=""
for v in codex antigravity; do
  if ! contains "$v" && [ -f "markdowns/agents/vendor-knowledge/${v}-cli.md" ]; then
    rm -f "markdowns/agents/vendor-knowledge/${v}-cli.md"
    PRUNED_VENDORS="$PRUNED_VENDORS $v"
  fi
done
[ -n "$PRUNED_VENDORS" ] && echo "Removed vendor knowledge:$PRUNED_VENDORS"

# ── Prune Antigravity-side config dir ─────────────────────────────────
# .gemini/ holds Antigravity's project-level config (Antigravity reads
# its config root from ~/.gemini/). If Antigravity isn't selected, the
# directory has no purpose.
if ! contains "antigravity" && [ -d ".gemini" ]; then
  rm -rf .gemini
  echo "Removed .gemini/ (was Antigravity's project-level config dir)."
fi

# ── Update cross-vendor-review.sh default peer ────────────────────────
PEER=""
if contains "codex"; then
  PEER="codex"
elif contains "antigravity"; then
  PEER="antigravity"
fi

if [ -n "$PEER" ]; then
  sed -i.bak -E "s/^TO=\"[^\"]+\"/TO=\"$PEER\"/" scripts/cross-vendor-review.sh
  rm -f scripts/cross-vendor-review.sh.bak
  echo "Default cross-vendor peer set to: $PEER"
else
  # Solo mode — claude self-review only.
  sed -i.bak -E "s/^TO=\"[^\"]+\"/TO=\"claude\"/" scripts/cross-vendor-review.sh
  rm -f scripts/cross-vendor-review.sh.bak
  echo "Solo mode — cross-vendor-review.sh defaults to claude self-review."
  echo "  (Tier 1/2 PRs will use same-vendor self-review instead of cross-vendor.)"
fi

# ── Update refresh-vendor skill hardcoded vendor list ─────────────────
# Build a backtick-comma-space-separated list of active vendor names in
# their `<vendor>-cli` form (e.g. `claude-code`, `codex-cli`, ...).
ACTIVE_LIST=""
for v in claude codex antigravity; do
  if contains "$v"; then
    case "$v" in
      claude) ACTIVE_LIST="$ACTIVE_LIST\`claude-code\`, " ;;
      codex)  ACTIVE_LIST="$ACTIVE_LIST\`codex-cli\`, " ;;
      antigravity) ACTIVE_LIST="$ACTIVE_LIST\`antigravity-cli\`, " ;;
    esac
  fi
done
ACTIVE_LIST=${ACTIVE_LIST%, }

if [ -z "$ACTIVE_LIST" ]; then
  : # nothing to rewrite
elif ! command -v python3 >/dev/null 2>&1; then
  echo "⚠️  python3 not found on PATH — skipped rewriting the refresh-vendor"
  echo "    skill's hardcoded vendor list. Edit .agents/skills/refresh-vendor/SKILL.md"
  echo "    by hand to remove vendors you pruned: $VENDORS"
else
  python3 - "$ACTIVE_LIST" <<'PYEOF'
import re, sys
path = ".agents/skills/refresh-vendor/SKILL.md"
new_list = sys.argv[1]
try:
    with open(path) as f:
        content = f.read()
except FileNotFoundError:
    sys.exit(0)
# Match the parenthesized backtick-list in the "Pick the vendor" step.
new_content = re.sub(
    r"\(`[a-z-]+(?:`,\s*`[a-z-]+)*`\)",
    f"({new_list})",
    content,
    count=1
)
if new_content != content:
    with open(path, "w") as f:
        f.write(new_content)
PYEOF
fi

# ── Re-run pre-commit chain to propagate edits ────────────────────────
echo
echo "Re-running pre-commit chain to propagate edits..."
bash scripts/pre-commit 2>&1 | sed 's/^/  /'

echo
echo "✅ Setup complete. Active vendors: $VENDORS"
echo
echo "Next steps:"
echo "  1. scripts/install-hooks.sh    # install pre-commit gate"
echo "  2. Edit AGENTS.md              # fill in <PROJECT-NAME> etc."
echo "  3. Open Claude Code and run /refresh-vendor for each vendor"
echo "     to update the knowledge files to current vendor state."
