#!/bin/bash
# Codex PermissionRequest hook: auto-allow Bash requests when auto mode is enabled.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/auto-mode-state.sh"

HOOK_HOME="$HOME/.codex"
HOOK_DIR_NAME=".codex"

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

if ! hook_auto_mode_enabled "$HOOK_HOME"; then
  exit 0
fi

raw=$(cat 2>/dev/null)
cwd=$(echo "$raw" | jq -r '.cwd // empty' 2>/dev/null)

if hook_auto_mode_opted_out "$cwd" "" "$HOOK_DIR_NAME"; then
  exit 0
fi

jq -n '{hookSpecificOutput:{hookEventName:"PermissionRequest",decision:{behavior:"allow"}}}'
exit 0
