#!/usr/bin/env bash
# Secrets read-guard — PreToolUse hook on Read.
#
# Defense-in-depth backstop for the 9 deny rules in .claude/settings.json.
# Two layers:
#   1. Pattern extras the deny list does not cover (TLS keystores, cloud
#      credentials, additional SSH key types).
#   2. Content sniff via gitleaks against the target file when available —
#      catches files whose name doesn't shout "secret" but whose contents do.
#
# Per Claude Code hooks spec:
#   - Reads JSON on stdin with tool_name + tool_input.
#   - Exit 0 + no JSON → tool proceeds.
#   - Exit 0 + permissionDecision: "deny" → blocks, reason shown to Claude.
#   - Exit 2 → blocks, stderr shown to Claude.

set -uo pipefail

INPUT=$(cat)

FILE_PATH=$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read() or "{}")
    print(d.get("tool_input", {}).get("file_path", ""))
except Exception:
    print("")
')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

emit_deny() {
  # Pass the reason via the environment, NOT string-interpolated into the
  # Python source. A file path containing quotes or backslashes (e.g.
  # "/tmp/evil'''.p12") would otherwise break the Python parse, the hook
  # would exit 0 with no JSON, and the guarded Read would proceed —
  # a security guard failing OPEN on malformed input. os.environ keeps the
  # reason as data, never as code.
  DENY_REASON="$1" python3 -c "
import json, os
print(json.dumps({
  'hookSpecificOutput': {
    'hookEventName': 'PreToolUse',
    'permissionDecision': 'deny',
    'permissionDecisionReason': os.environ['DENY_REASON']
  }
}))
"
  exit 0
}

# --- Layer 1: pattern extras beyond the deny list ---
case "$FILE_PATH" in
  *.p12|*.pfx|*.cer|*.crt|*.jks|*.keystore)
    emit_deny "secrets-guard: TLS/keystore file pattern denied ($FILE_PATH). Add an explicit allow if this is a public cert." ;;
  */.aws/credentials|*/.aws/config|*/.gcp/*|*/.gcloud/*|*/.kube/config|*serviceAccountKey*.json|*firebase-adminsdk-*.json|*google-services.json)
    emit_deny "secrets-guard: cloud credentials pattern denied ($FILE_PATH)." ;;
  *id_dsa*|*id_ecdsa*)
    emit_deny "secrets-guard: SSH key pattern denied ($FILE_PATH)." ;;
  *.mcp.json|*claude-config*|*authinfo*)
    emit_deny "secrets-guard: tool-config secret-bearing pattern denied ($FILE_PATH)." ;;
esac

# --- Layer 2: content sniff via gitleaks on the target file ---
# Soft-skip when gitleaks is missing or the file isn't readable locally.
if [ -f "$FILE_PATH" ] && command -v gitleaks >/dev/null 2>&1; then
  if ! gitleaks detect \
        --no-banner --redact --no-git \
        --source "$FILE_PATH" \
        --log-level error >/dev/null 2>&1; then
    emit_deny "secrets-guard: gitleaks detected secret content in $FILE_PATH. If false positive, add an entry to .gitleaks.toml allowlist."
  fi
fi

exit 0
