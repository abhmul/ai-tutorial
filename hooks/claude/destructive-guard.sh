#!/bin/bash
# Claude Code PreToolUse hook: block or confirm destructive Bash operations.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/destructive-policy.sh"

block() {
  echo "$1" >&2
  exit 2
}

if ! command -v jq >/dev/null 2>&1; then
  block "BLOCKED: destructive-guard dependency missing (jq not found). Install jq to restore Bash access."
fi

raw=$(cat 2>/dev/null)
cmd=$(echo "$raw" | jq -r '.tool_input.command // ""' 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$cmd" ]; then
  block "BLOCKED: destructive-guard could not parse hook input — failing safe."
fi

HOOK_HOME="$HOME/.claude"
HOOK_PLATFORM_LABEL="Claude Code"
HOOK_PROTECTED_FILES_REGEX='settings\.json|\.auto-mode'
hook_policy_evaluate_command "$cmd"

if [ "$HOOK_POLICY_DECISION" = "block" ]; then
  block "$HOOK_POLICY_REASON"
fi

jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",permissionDecisionReason:"destructive-guard: no destructive patterns detected"}}'
exit 0
