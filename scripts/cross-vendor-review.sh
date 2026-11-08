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
TIER="workhorse"
RUBRIC="markdowns/protocols/cross-vendor-review.md"

while [ $# -gt 0 ]; do
  case "$1" in
    --from) FROM="$2"; shift 2;;
    --to) TO="$2"; shift 2;;
    --rubric) RUBRIC="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --brief) BRIEF="$2"; shift 2;;
    --tier) TIER="$2"; shift 2;;
    -h|--help)
      cat <<EOF >&2
Usage: $0 --target <path> [--from claude] [--to claude|codex|antigravity] [--tier workhorse|frontier|light] [--rubric <path>] [--brief <path>]

Options:
  --target  Path or diff to review. Required.
  --from    Vendor running the worker side. Default: claude.
  --to      Peer vendor running the review. Default: codex.
  --rubric  Path to a markdown file containing a <!-- RUBRIC START --> ... <!-- RUBRIC END --> delimited prompt block. Default: $RUBRIC.
  --brief   Optional path to a session brief; included as an anchor source for scope claims.
  --tier    Reviewer model tier. Default: workhorse (Tier 1/2 review per
            markdowns/agents/model-capabilities.md). The worker may escalate
            (frontier, e.g. a security-heavy Tier 1 diff) or step down
            (light); record the choice and reason in the chat checkpoint.
EOF
      exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

[ -n "$TARGET" ] || { echo "Error: --target is required. Run with -h for usage." >&2; exit 2; }
[ -r "$RUBRIC" ] || { echo "Error: rubric file not readable: $RUBRIC" >&2; exit 2; }
[ -z "$BRIEF" ] || [ -r "$BRIEF" ] || { echo "Error: brief not readable: $BRIEF" >&2; exit 2; }

# quotes: markdowns/agents/model-capabilities.md#per-vendor-tier-mapping
# Tier -> per-vendor reviewer model. Declared quote of that mapping (SSOT,
# 2026-11-08); the mapping table points back here, so a model-drift
# consistency sweep (refresh-vendor.md) finds and updates both. The reviewer model is pinned
# here so a review never inherits the operator's personal model (a
# frontier model on the reference machine for codex — 2026-11-08 walk).
case "$TIER" in
  workhorse|frontier|light) ;;
  *) echo "Error: unknown --tier: $TIER (workhorse|frontier|light)" >&2; exit 2;;
esac
case "$TO:$TIER" in
  claude:frontier)        REVIEW_MODEL="opus";;
  claude:workhorse)       REVIEW_MODEL="sonnet";;
  claude:light)           REVIEW_MODEL="haiku";;
  codex:frontier)         REVIEW_MODEL="gpt-6-astra";;
  codex:workhorse)        REVIEW_MODEL="gpt-6.1-sol";;
  codex:light)            REVIEW_MODEL="gpt-6-luna";;
  # agy's catalog is account-dependent and exposes no frontier Gemini on
  # the reference account; frontier review routes to another vendor.
  antigravity:workhorse)  REVIEW_MODEL="gemini-3.8-flash-high";;
  antigravity:light)      REVIEW_MODEL="gemini-3.8-flash-low";;
  antigravity:frontier)
    echo "Error: no frontier-tier model is mapped for antigravity (see model-capabilities.md). Use --to codex or --to claude for a frontier review." >&2
    exit 2;;
  *)
    echo "Error: no reviewer model mapped for --to $TO --tier $TIER." >&2
    echo "Supported vendors: claude | codex | antigravity (add a vendor's tier rows here when adding it)." >&2
    exit 2;;
esac

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
  codex)       BINARY="codex";       INSTALL_URL="npm install -g @openai/codex  (docs: https://learn.chatgpt.com/docs/codex/cli)";;
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

# Audit line for the chat checkpoint: which reviewer model ran, and at
# which tier (stderr, so it never mixes into the review body).
echo "Reviewer: $TO / $REVIEW_MODEL (tier: $TIER)" >&2

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
    # --tools "Read,Grep,Glob" is the actual read-only restriction:
    # --safe-mode keeps the operator's user-level permissions.allow rules
    # in force, and --allowedTools only AUTO-APPROVES the listed tools —
    # it removes nothing. BEHAVIORALLY PROBED 2026-11-08 (v2.1.319), three
    # arms in a scratch repo, stream-json init + tool_use events:
    # (A) current flags without --tools: 26 tools at init; the reviewer
    # ran `gh api /zen` via a user `Bash(gh api:*)` allow rule (exposure
    # demonstrated); (B) with --tools: init tools exactly Glob/Grep/Read,
    # reply "NO_BASH"; (C) with --tools: Read of a nonce file succeeded,
    # so review reads still work.
    # --model "$REVIEW_MODEL": tier-resolved (default workhorse = sonnet);
    # never the operator's session model. </dev/null: never leave a vendor
    # CLI waiting on stdin.
    OUT=$(with_timeout claude -p "$PROMPT" --safe-mode --model "$REVIEW_MODEL" --tools "Read,Grep,Glob" --allowedTools "Read,Grep,Glob" </dev/null 2>&1) || RC=$?
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
    # exec inherits the operator's ~/.codex/config.toml, so every
    # operator-level setting that matters is overridden explicitly:
    # -m: tier-resolved model (default workhorse = gpt-6.1-sol). Without
    #   it the review ran on the operator's model — gpt-6-astra (frontier,
    #   ~5x the credits) on the reference machine (2026-11-08 walk).
    # model_reasoning_effort: the operator's global effort (xhigh on the
    #   reference machine) pushed a 553-line review past 9 minutes.
    # notify=[]: the operator's turn-ended notify hook fired on every
    #   scripted exec — on the reference machine a Computer Use client that
    #   raised a macOS Automation prompt mid-review (2026-11-08).
    #   PROBED 2026-11-08 (codex 0.162.1, real turns): -c notify=["touch",
    #   <sentinel>] created the sentinel, so a -c value REPLACES the config
    #   hook; -c notify=[] then runs none.
    COMBINED=$(with_timeout codex exec -m "$REVIEW_MODEL" --sandbox read-only -c 'model_reasoning_effort="medium"' -c 'notify=[]' --output-last-message "$TMP" "$CODEX_PROMPT" </dev/null 2>&1) || RC=$?
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
    # grant. See markdowns/agents/vendor-knowledge/antigravity-cli.md §9.
    #
    # Output is --output-format json and denial detection reads the
    # envelope, not prose: agy exits 0 on a permission denial, and since
    # 1.1.27 a second denial notice exists that the old text regex missed.
    # The review is REFUSED (exit 4) unless the envelope parses, status is
    # SUCCESS, denied_actions is empty, finished_reason is absent (present
    # only on print_timeout / interrupted / error), and response is
    # non-empty. A widened text grep stays as belt-and-braces.
    #
    # No --mode plan: since 1.1.28 headless runs auto-proceed through plan
    # review, so it gates nothing — and in the 2026-11-08 probe on 1.5.3 it
    # made a benign "Reply with exactly: OK" prompt reach for a shell
    # command (denied => empty review) in 2 of 3 plan-mode runs, vs 0 of 4
    # without it. Strict toolPermission is the write barrier.
    # AGY_CLI_DISABLE_AUTO_UPDATE=1: any agy invocation can spawn the
    # vendor auto-updater (observed 2026-11-08). The env var is present in
    # the binary but its effect is untested; the probe-version gate above
    # is what actually catches a mid-stream update (on the next run).
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
    AGY_ERR=$(mktemp)
    AGY_JSON=$(AGY_CLI_DISABLE_AUTO_UPDATE=1 with_timeout agy --print "$AGY_PROMPT" --sandbox --print-timeout 5m --model "$REVIEW_MODEL" --output-format json </dev/null 2>"$AGY_ERR") || RC=$?
    AGY_STDERR=$(cat "$AGY_ERR"); rm -f "$AGY_ERR"
    # Parse the envelope: prints "OK" then the response on success, or
    # "REFUSE <reason>" when any fail-closed condition holds.
    agy_parse() {
      if command -v python3 >/dev/null 2>&1; then
        python3 -I -c '
import json, sys
raw = sys.stdin.read()
i = raw.find("{")
try:
    d = json.loads(raw[i:]) if i >= 0 else None
except ValueError:
    d = None
if not isinstance(d, dict):
    print("REFUSE unparseable JSON envelope"); sys.exit()
if d.get("status") != "SUCCESS":
    print("REFUSE status=%s" % d.get("status")); sys.exit()
if d.get("denied_actions") not in (None, []):
    print("REFUSE denied_actions=%s" % json.dumps(d["denied_actions"])); sys.exit()
# Presence, not truthiness: a normal turn omits the key entirely (observed
# 1.5.3), so any finished_reason -- even "" or null -- means not-normal.
if "finished_reason" in d:
    print("REFUSE finished_reason=%s" % json.dumps(d["finished_reason"])); sys.exit()
r = d.get("response")
if not isinstance(r, str) or not r.strip():
    print("REFUSE empty response"); sys.exit()
print("OK"); sys.stdout.write(r)
'
      elif command -v jq >/dev/null 2>&1; then
        # -s slurps the whole input first, so trailing junk is a parse
        # error before anything is printed, and exactly ONE envelope is
        # required (a stream of envelopes could otherwise print OK for the
        # first and accept a denied second). No "{" at all leaves jq with
        # no output; the final fallback turns that into a refusal.
        { sed -n '/{/,$p' | jq -rs '
          if length != 1 then "REFUSE expected exactly one JSON envelope"
          else .[0] |
          if type != "object" then "REFUSE unparseable JSON envelope"
          elif .status != "SUCCESS" then "REFUSE status=\(.status)"
          elif (.denied_actions // []) != [] then "REFUSE denied_actions=\(.denied_actions | tojson)"
          elif has("finished_reason") then "REFUSE finished_reason=\(.finished_reason | tojson)"
          elif ((.response | type) != "string") or ((.response | test("\\S")) | not) then "REFUSE empty response"
          else "OK\n" + .response end end' 2>/dev/null || echo "REFUSE unparseable JSON envelope"; } |
          { IFS= read -r first || { echo "REFUSE unparseable JSON envelope"; exit 0; }; printf '%s\n' "$first"; cat; }
      else
        echo "REFUSE neither python3 nor jq is available to verify the agy JSON envelope"
      fi
    }
    if [ "$RC" -eq 0 ]; then
      AGY_PARSED=$(printf '%s' "$AGY_JSON" | agy_parse)
      case "$AGY_PARSED" in
        OK*) OUT=$(printf '%s' "$AGY_PARSED" | sed '1d');;
        *)
          echo "Error: Antigravity review dispatch failed closed: ${AGY_PARSED#REFUSE }." >&2
          echo "The inline review contract requires a tool-free, complete response; no review was accepted." >&2
          exit 4;;
      esac
    else
      # agy failed (1.5.x exits 3 on a print timeout or partial-then-error,
      # and the envelope may carry a PARTIAL response). Never surface the
      # envelope or any response text: OUT is agy's stderr only, which is
      # where its AGY_ERROR / rate-limit messages go. The rate-limit check
      # and exit-code remap below then run on that.
      OUT="$AGY_STDERR"
      echo "Error: Antigravity exited $RC; no review was accepted." >&2
    fi
    ;;
esac

# Rate-limit detection: a non-zero RC with a rate-limit-shaped error
# message means "try a different vendor," not "the review failed."
# (Here-strings, not `printf | grep -q`: under pipefail a large input can
# SIGPIPE the printf when grep exits on first match, making the match read
# as a failure.)
if [ "$RC" -ne 0 ] && grep -qiE 'rate.?limit|quota|429|too many requests|usage limit' <<<"$OUT"; then
  echo "Rate limit hit on $TO. Re-run with --to <other-vendor>." >&2
  exit 3
fi

# Belt-and-braces text check for Antigravity (the JSON envelope check in
# the branch above is primary). Matches both denial notices: the
# 1.1.20-era "no output produced — a tool required the ... permission"
# and the 1.1.27+ "the X tool(s) required approval that headless mode
# cannot prompt for, so they were auto-denied". Scans agy's STDERR only —
# the notice goes there (verified 2026-11-08, 1.5.3) while stdout carries
# the JSON envelope; scanning the review body would false-refuse any review
# of a diff that merely mentions these phrases.
if [ "$TO" = "antigravity" ] &&
   grep -qiE 'no output produced.*permission|headless mode cannot prompt for|auto-denied|tool(\(s\))? required.*(permission|approval)' <<<"${AGY_STDERR:-}"; then
  echo "Error: Antigravity review dispatch failed closed because strict mode denied a tool request." >&2
  echo "The inline review contract requires a tool-free response; no review was accepted." >&2
  exit 4
fi

# The dispatcher reserves exit 2 (usage), 3 (rate limit: try another
# vendor) and 4 (refused / fail-closed). A peer CLI's own exit code must
# not masquerade as one of those — agy exits 3 on a print timeout (1.5.0)
# and on any agent/model API failure (1.2.6), which would otherwise read
# as "rate limited, re-run elsewhere". Remap colliding codes to 1.
if [ "$RC" -eq 2 ] || [ "$RC" -eq 3 ] || [ "$RC" -eq 4 ]; then
  echo "Error: peer vendor $TO exited $RC (remapped to 1; 2/3/4 are reserved by this dispatcher)." >&2
  RC=1
fi

printf '%s\n' "$OUT"
exit "$RC"
