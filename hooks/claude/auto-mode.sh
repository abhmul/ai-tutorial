#!/bin/bash
# Claude Code PreToolUse hook: grant low-friction permissions when auto mode is enabled.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/auto-mode-state.sh"

HOOK_HOME="$HOME/.claude"
HOOK_DIR_NAME=".claude"

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

if ! hook_auto_mode_enabled "$HOOK_HOME"; then
  exit 0
fi

raw=$(cat 2>/dev/null)
cwd=$(echo "$raw" | jq -r '.cwd // empty' 2>/dev/null)
project_dir="${CLAUDE_PROJECT_DIR:-}"

if hook_auto_mode_opted_out "$cwd" "$project_dir" "$HOOK_DIR_NAME"; then
  exit 0
fi

jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",permissionDecisionReason:"auto-mode hook: permission granted"}}'
exit 0
