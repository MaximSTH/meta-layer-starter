#!/usr/bin/env bash
# Secrets write-guard — PreToolUse hook on Write|Edit|MultiEdit.
#
# Closes the "Claude pastes a secret it just read" path: if the content being
# written matches any gitleaks rule, the call is denied. Pairs with the
# read-guard hook (which blocks the Read on the way in).
#
# Per Claude Code hooks spec:
#   - Reads JSON on stdin with tool_name + tool_input.
#   - Exit 0 + permissionDecision: "deny" → blocks, reason shown to Claude.
#
# Soft-skip when gitleaks isn't installed locally — the pre-commit step
# and CI gitleaks job remain backstops.

set -uo pipefail

if ! command -v gitleaks >/dev/null 2>&1; then
  exit 0
fi

INPUT=$(cat)

# Extract content per tool. Write uses `content`; Edit/MultiEdit use `new_string`
# (or `edits[].new_string` for MultiEdit — concatenate them).
CONTENT=$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read() or "{}")
    name = d.get("tool_name", "")
    ti = d.get("tool_input", {})
    if name == "Write":
        print(ti.get("content", ""))
    elif name == "Edit":
        print(ti.get("new_string", ""))
    elif name == "MultiEdit":
        print("\n".join(e.get("new_string", "") for e in ti.get("edits", [])))
    else:
        pass
except Exception:
    pass
')

if [ -z "$CONTENT" ]; then
  exit 0
fi

TMPFILE=$(mktemp -t secrets-guard.XXXXXX)
trap 'rm -f "$TMPFILE"' EXIT
printf '%s' "$CONTENT" > "$TMPFILE"

if ! gitleaks detect \
      --no-banner --redact --no-git \
      --source "$TMPFILE" \
      --log-level error >/dev/null 2>&1; then
  python3 -c '
import json
print(json.dumps({
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "secrets-guard: gitleaks detected secret-pattern content in the staged tool input. Refusing to write/edit a secret. If false positive, add an allowlist entry to .gitleaks.toml."
  }
}))
'
  exit 0
fi

exit 0
