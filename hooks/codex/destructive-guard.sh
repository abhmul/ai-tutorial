#!/bin/bash
# Codex PreToolUse hook: deny destructive Bash operations before approval.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/destructive-policy.sh"

deny() {
  local message="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg message "$message" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$message}}'
    exit 0
  fi

  echo "$message" >&2
  exit 2
}

if ! command -v jq >/dev/null 2>&1; then
  deny "BLOCKED: destructive-guard dependency missing (jq not found)."
fi

raw=$(cat 2>/dev/null)
cmd=$(echo "$raw" | jq -r '.tool_input.command // ""' 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$cmd" ]; then
  deny "BLOCKED: destructive-guard could not parse hook input."
fi

HOOK_HOME="$HOME/.codex"
HOOK_PLATFORM_LABEL="Codex"
HOOK_PROTECTED_FILES_REGEX='config\.toml|hooks\.json|\.auto-mode'
hook_policy_evaluate_command "$cmd"

if [ "$HOOK_POLICY_DECISION" = "block" ]; then
  deny "$HOOK_POLICY_REASON"
fi

exit 0
