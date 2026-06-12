#!/usr/bin/env bash
# cross-vendor-review.sh — peer-vendor review dispatcher.
#
# Spec: markdowns/protocols/cross-vendor-review.md
# Topology: markdowns/meta-layer/cross-vendor-harness.md
#
# Extracts a rubric prompt block from --rubric (default: cross-vendor-review.md)
# and invokes a peer vendor CLI to review the target. The rubric file must
# delimit its prompt block with HTML comments:
#
#     <!-- RUBRIC START -->
#     ```
#     ...prompt body...
#     ```
#     <!-- RUBRIC END -->
#
# The script extracts the code fence's contents between those markers.
# Heading-text and section-number matching were tried earlier and proved
# brittle when sections were reordered or renamed.

set -uo pipefail

# DEFAULT_TO is the peer reviewer. Codex CLI is verified for cross-vendor
# review on the headless surface; Antigravity CLI is supported as a
# fallback. Claude Code is supported for self-review with rubric in fresh
# context (per stake-matrix Tier 3 same-vendor rule).
FROM="claude"
TO="codex"
TARGET=""
BRIEF=""
RUBRIC="markdowns/protocols/cross-vendor-review.md"

while [ $# -gt 0 ]; do
  case "$1" in
    --from) FROM="$2"; shift 2;;
    --to) TO="$2"; shift 2;;
    --rubric) RUBRIC="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --brief) BRIEF="$2"; shift 2;;
    -h|--help)
      cat <<EOF >&2
Usage: $0 --target <path> [--from claude] [--to claude|codex|antigravity] [--rubric <path>] [--brief <path>]

Options:
  --target  Path or diff to review. Required.
  --from    Vendor running the worker side. Default: claude.
  --to      Peer vendor running the review. Default: codex.
  --rubric  Path to a markdown file containing a <!-- RUBRIC START --> ... <!-- RUBRIC END --> delimited prompt block. Default: $RUBRIC.
  --brief   Optional path to a session brief; included as an anchor source for scope claims.
EOF
      exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

[ -n "$TARGET" ] || { echo "Error: --target is required. Run with -h for usage." >&2; exit 2; }
[ -r "$RUBRIC" ] || { echo "Error: rubric file not readable: $RUBRIC" >&2; exit 2; }
[ -z "$BRIEF" ] || [ -r "$BRIEF" ] || { echo "Error: brief not readable: $BRIEF" >&2; exit 2; }

# Extract the rubric prompt block delimited by HTML comments.
# The block is expected to contain a single code fence; we strip the fence
# markers and return the body.
RUBRIC_BODY=$(awk '
  /<!-- RUBRIC START -->/ { inside=1; next }
  /<!-- RUBRIC END -->/   { inside=0; next }
  inside && /^```/        { fence=!fence; next }
  inside && fence         { print }
' "$RUBRIC")

if [ -z "$RUBRIC_BODY" ]; then
  echo "Error: could not extract rubric body from $RUBRIC." >&2
  echo "Expected delimiters: <!-- RUBRIC START --> ... <!-- RUBRIC END --> around a fenced code block." >&2
  exit 2
fi

# Preflight: verify the chosen peer-vendor binary is on PATH. The starter
# can't usefully invoke a CLI that isn't installed; surface this with a
# clear install pointer rather than a generic shell error.
case "$TO" in
  claude)      BINARY="claude";      INSTALL_URL="https://code.claude.com";;
  codex)       BINARY="codex";       INSTALL_URL="npm install -g @openai/codex  (docs: https://developers.openai.com/codex/cli)";;
  antigravity) BINARY="agy";         INSTALL_URL="https://antigravity.google";;
  *)
    echo "Error: unknown peer vendor: $TO" >&2
    echo "Supported: claude | codex | antigravity" >&2
    exit 2;;
esac

if ! command -v "$BINARY" >/dev/null 2>&1; then
  echo "Error: $BINARY (required for --to $TO) not found on PATH." >&2
  echo "Install: $INSTALL_URL" >&2
  echo "Or re-run with a different peer vendor: --to <claude|codex|antigravity>" >&2
  exit 4
fi

BRIEF_SECTION=""
if [ -n "$BRIEF" ]; then
  BRIEF_BODY=$(cat "$BRIEF")
  BRIEF_SECTION="THE BRIEF for this PR (anchor source for scope claims; cite as brief:line):

$BRIEF_BODY

---

"
fi

PROMPT="From: $FROM. Reviewing: $TARGET.

${BRIEF_SECTION}$RUBRIC_BODY

Review the diff/path: $TARGET. Read it, then return the report."

RC=0
case "$TO" in
  claude)
    OUT=$(claude -p "$PROMPT" --allowedTools "Read,Grep,Glob" 2>&1) || RC=$?
    ;;
  codex)
    TMP=$(mktemp)
    COMBINED=$(codex exec --sandbox read-only --output-last-message "$TMP" "$PROMPT" 2>&1) || RC=$?
    OUT=$(cat "$TMP")
    [ -z "$OUT" ] && OUT="$COMBINED"
    rm -f "$TMP"
    ;;
  antigravity)
    # Antigravity CLI (agy) — Google's first-party coding CLI.
    #
    # Sandbox version floor: agy --sandbox silently failed to propagate
    # in -p mode before v1.0.6 (CHANGELOG fix). Pre-1.0.6 review runs
    # against an arbitrary install would execute without shell-command
    # containment despite the flag. Refuse if version cannot be
    # verified as ≥ 1.0.6 (extraction failure, agy missing, or version
    # < 1.0.6). Override with SKIP_AGY_VERSION_CHECK=1 if the caller
    # explicitly accepts the risk.
    # See markdowns/agents/vendor-knowledge/antigravity-cli.md §9.
    if [ "${SKIP_AGY_VERSION_CHECK:-0}" != "1" ]; then
      AGY_VERSION=$(agy --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
      if [ -z "$AGY_VERSION" ] || [ "$(printf '%s\n%s\n' "1.0.6" "$AGY_VERSION" | sort -V | head -1)" != "1.0.6" ]; then
        echo "Error: agy version '${AGY_VERSION:-unknown}' is below the sandbox-propagation floor (v1.0.6)." >&2
        echo "Pre-1.0.6 --sandbox silently does not enforce shell-command containment in -p mode." >&2
        echo "Upgrade agy, or override with SKIP_AGY_VERSION_CHECK=1 if you accept the risk." >&2
        exit 4
      fi
    fi
    # No --read-only flag; --sandbox restricts shell-exec only (NOT file
    # writes). Read-only enforcement relies on the rubric's prompt
    # instruction ("Do NOT execute, write, or modify files. Read only.")
    # plus ~/.gemini/antigravity-cli/settings.json with enableTerminalSandbox=true.
    # Output is plain text (no --output-format json); parsing relies on
    # the rubric's anchored/no-anchor section headers.
    # See markdowns/agents/vendor-knowledge/antigravity-cli.md.
    OUT=$(agy --print "$PROMPT" --sandbox --print-timeout 5m 2>&1) || RC=$?
    ;;
esac

# Rate-limit detection: a non-zero RC with a rate-limit-shaped error
# message means "try a different vendor," not "the review failed."
if [ "$RC" -ne 0 ] && printf '%s' "$OUT" | grep -qiE 'rate.?limit|quota|429|too many requests|usage limit'; then
  echo "Rate limit hit on $TO. Re-run with --to <other-vendor>." >&2
  exit 3
fi

printf '%s\n' "$OUT"
exit "$RC"
