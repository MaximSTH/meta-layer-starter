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

# Fill the rubric's authoring-time placeholders. Left unfilled, every
# review opens by flagging "<PR-URL> / <protocol-file> §<N> unresolved"
# (both 2026-08-25 reviews did) — noise that buries real findings.
RUBRIC_BODY=${RUBRIC_BODY//<PR-URL>/$TARGET}
RUBRIC_BODY=${RUBRIC_BODY//<protocol-file> §<N>/"the rubric below (and the brief, if provided)"}

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

# Portable timeout: macOS ships no `timeout` binary. perl's alarm() is on
# every supported platform. 900s covers the slowest observed review (a
# 553-line diff at medium effort) with ample headroom; without a guard, a
# hung vendor call blocks the pipeline forever (observed 2026-08-25: two
# codex runs at 11 minutes producing zero bytes).
REVIEW_TIMEOUT_SECS=900
with_timeout() { perl -e 'alarm shift; exec @ARGV' "$REVIEW_TIMEOUT_SECS" "$@"; }

RC=0
case "$TO" in
  claude)
    # --safe-mode: disables hooks, MCP servers, skills, plugins and other
    # customizations of the LAUNCH directory while keeping OAuth auth,
    # built-in tools and permissions intact. Closes the recorded exposure
    # (claude-code.md §9, 2026-08-25): a plain `-p` run executes the
    # launch directory's .claude/settings.json hooks and connects its
    # .mcp.json servers with no trust dialog. (--bare would close it too
    # but forces API-key auth, breaking subscription dispatch.)
    # BEHAVIORALLY PROBED 2026-08-25 (v2.1.220), both arms: a scratch
    # project with a sentinel SessionStart hook — plain `-p` created the
    # sentinel (exposure demonstrated); `--safe-mode` did not, and the
    # run completed under subscription OAuth. Not help-text-sourced.
    # --model sonnet: Tier 1/2 review is Sonnet-tier per
    # markdowns/agents/model-capabilities.md heuristics — do not inherit
    # the operator's session model. </dev/null: never leave a vendor CLI
    # waiting on stdin.
    OUT=$(with_timeout claude -p "$PROMPT" --safe-mode --model sonnet --allowedTools "Read,Grep,Glob" </dev/null 2>&1) || RC=$?
    ;;
  codex)
    TMP=$(mktemp)
    # Inline target transport (same pattern as the antigravity branch):
    # at medium effort the reviewer sometimes reads the rubric's "do not
    # execute" as banning file reads and refuses the review (observed
    # 2026-08-25). Embedding the target removes the file-access
    # dependence entirely for targets up to the same 100KB cap.
    CODEX_PROMPT="$PROMPT"
    if [ -f "$TARGET" ] && [ "$(wc -c < "$TARGET" | tr -d ' ')" -le 100000 ]; then
      CODEX_PROMPT="$PROMPT

The exact target content is embedded below; review it directly instead
of reading any path.

--- BEGIN EXACT REVIEW TARGET ---
$(cat "$TARGET")
--- END EXACT REVIEW TARGET ---"
    fi
    # </dev/null is load-bearing: `codex exec` appends stdin to the prompt
    # when stdin is not a TTY and blocks awaiting EOF ("Reading additional
    # input from stdin..."), so without it this branch hangs forever in
    # any non-interactive context (codex-cli.md §9, verified 2026-08-25).
    # The effort override is also load-bearing: exec inherits the
    # operator's global model_reasoning_effort (xhigh on the reference
    # machine), which pushed a 553-line review past 9 minutes.
    COMBINED=$(with_timeout codex exec --sandbox read-only -c 'model_reasoning_effort="medium"' --output-last-message "$TMP" "$CODEX_PROMPT" </dev/null 2>&1) || RC=$?
    OUT=$(cat "$TMP")
    [ -z "$OUT" ] && OUT="$COMBINED"
    rm -f "$TMP"
    ;;
  antigravity)
    # Antigravity CLI (agy) — Google's first-party coding CLI.
    #
    # Safety chain: v1.1.4 is the first release whose headless mode honors
    # persisted permissions, file-access, sandbox, auto-execution, and
    # artifact-review policies. Dispatch is allowed only when the binary
    # floor, project policy, and recorded headless write-refusal probe all
    # pass. There is deliberately no override for this security boundary.
    # See markdowns/agents/vendor-knowledge/antigravity-cli.md §9.
    # 1.1.18 floor: below it, a valueless `--print --sandbox 'task'`
    # invocation ran with the prompt "--sandbox" and the sandbox OFF
    # (antigravity-cli.md §9). 1.1.4 was the previous floor (first
    # release honoring persisted headless policy); 1.1.18 supersedes it.
    AGY_MIN_VERSION="1.1.18"
    AGY_VERSION=$(agy --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [ -z "${HOME:-}" ]; then
      echo "Error: Antigravity review dispatch is disabled: HOME is unset, so the persisted CLI policy cannot be verified." >&2
      exit 4
    fi
    AGY_USER_SETTINGS="${HOME}/.gemini/antigravity-cli/settings.json"
    AGY_PROJECT_SETTINGS=".gemini/settings.json"
    AGY_KNOWLEDGE="markdowns/agents/vendor-knowledge/antigravity-cli.md"

    if [ -z "$AGY_VERSION" ] || [ "$(printf '%s\n%s\n' "$AGY_MIN_VERSION" "$AGY_VERSION" | sort -V | head -1)" != "$AGY_MIN_VERSION" ]; then
      echo "Error: Antigravity review dispatch is disabled: agy '${AGY_VERSION:-unknown}' is below the headless-policy floor (v$AGY_MIN_VERSION)." >&2
      echo "Required chain: upgrade agy, configure strict persisted policy, pass the headless write-refusal probe, and record the probe result." >&2
      exit 4
    fi

    if [ ! -r "$AGY_USER_SETTINGS" ] ||
       ! grep -Eq '"toolPermission"[[:space:]]*:[[:space:]]*"strict"' "$AGY_USER_SETTINGS" ||
       ! grep -Eq '"enableTerminalSandbox"[[:space:]]*:[[:space:]]*true' "$AGY_USER_SETTINGS"; then
      echo "Error: Antigravity review dispatch is disabled: $AGY_USER_SETTINGS does not contain the required global CLI policy." >&2
      echo "Required: toolPermission=strict and enableTerminalSandbox=true." >&2
      exit 4
    fi

    if [ ! -r "$AGY_PROJECT_SETTINGS" ] ||
       ! grep -Eq '"allowNonWorkspaceAccess"[[:space:]]*:[[:space:]]*false' "$AGY_PROJECT_SETTINGS" ||
       ! grep -Eq '"artifactReviewPolicy"[[:space:]]*:[[:space:]]*"asks-for-review"' "$AGY_PROJECT_SETTINGS"; then
      echo "Error: Antigravity review dispatch is disabled: $AGY_PROJECT_SETTINGS does not contain the required project hardening policy." >&2
      echo "Required: allowNonWorkspaceAccess=false and artifactReviewPolicy=asks-for-review." >&2
      exit 4
    fi

    if [ ! -r "$AGY_KNOWLEDGE" ] ||
       ! grep -Eq '^headless-write-probe:[[:space:]]*passed$' "$AGY_KNOWLEDGE"; then
      echo "Error: Antigravity review dispatch is disabled: no passed headless write-refusal probe is recorded in $AGY_KNOWLEDGE." >&2
      echo "Run the scratch-repo probe on agy >= $AGY_MIN_VERSION and record headless-write-probe: passed before dispatch." >&2
      exit 4
    fi

    # The probe must have passed ON the installed binary, not merely once.
    # Print-mode permission-denial semantics changed across 1.1.18/1.1.20
    # (antigravity-cli.md §9): a probe result from an older binary can be
    # silently invalid while `passed` still reads true. Hard-earned on
    # 2026-08-25, when a 1.1.4-era probe sat stale against 1.1.19.
    AGY_PROBE_VERSION=$(grep -E '^headless-write-probe-verified-on:' "$AGY_KNOWLEDGE" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -z "$AGY_PROBE_VERSION" ] || [ "$AGY_PROBE_VERSION" != "$AGY_VERSION" ]; then
      echo "Error: Antigravity review dispatch is disabled: the write-refusal probe was verified on '${AGY_PROBE_VERSION:-unrecorded}' but the installed agy is '$AGY_VERSION'." >&2
      echo "Re-run the probe on the installed binary and update headless-write-probe-verified-on in $AGY_KNOWLEDGE." >&2
      exit 4
    fi
    # No --read-only flag: effective read-only review depends on the checked
    # restrictive policy plus the refusal probe, not on prompt text alone.
    # The exact target is also transported inline so strict mode needs no read
    # grant. Output is plain text (no --output-format json); parsing relies on
    # the rubric's anchored/no-anchor section headers.
    # See markdowns/agents/vendor-knowledge/antigravity-cli.md.
    [ -f "$TARGET" ] || {
      echo "Error: Antigravity strict-mode review requires --target to be a readable file." >&2
      exit 4
    }
    TARGET_BYTES=$(wc -c < "$TARGET" | tr -d ' ')
    [ "$TARGET_BYTES" -le 100000 ] || {
      echo "Error: Antigravity strict-mode inline target exceeds 100000 bytes: $TARGET_BYTES." >&2
      exit 4
    }
    AGY_TARGET_BODY=$(cat "$TARGET")
    AGY_PROMPT="$PROMPT

Antigravity strict-mode review contract: the exact target content is embedded
below. Do not call tools, list directories, search the workspace, execute
commands, or inspect any path. Review only the embedded artifact.

--- BEGIN EXACT REVIEW TARGET ---
$AGY_TARGET_BODY
--- END EXACT REVIEW TARGET ---"
    OUT=$(with_timeout agy --print "$AGY_PROMPT" --mode plan --sandbox --print-timeout 5m </dev/null 2>&1) || RC=$?
    ;;
esac

# Rate-limit detection: a non-zero RC with a rate-limit-shaped error
# message means "try a different vendor," not "the review failed."
if [ "$RC" -ne 0 ] && printf '%s' "$OUT" | grep -qiE 'rate.?limit|quota|429|too many requests|usage limit'; then
  echo "Rate limit hit on $TO. Re-run with --to <other-vendor>." >&2
  exit 3
fi

if [ "$TO" = "antigravity" ] &&
   printf '%s' "$OUT" | grep -qiE 'no output produced.*permission.*(denied|required)|tool required.*permission'; then
  echo "Error: Antigravity review dispatch failed closed because strict mode denied a tool request." >&2
  echo "The inline review contract requires a tool-free response; no review was accepted." >&2
  exit 4
fi

printf '%s\n' "$OUT"
exit "$RC"
