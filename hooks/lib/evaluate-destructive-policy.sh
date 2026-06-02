#!/bin/bash
# CLI wrapper around destructive-policy.sh for non-shell hook runtimes.
# Prints "allow" or "block" on the first line. For blocks, the remaining
# output is the human-readable reason.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/destructive-policy.sh"

if [ "$#" -ne 1 ]; then
  echo "block"
  echo "BLOCKED: destructive-policy evaluator expected exactly one command argument."
  exit 0
fi

hook_policy_evaluate_command "$1" "$SCRIPT_DIR/obsidian-guard.py"

if [ "${HOOK_POLICY_DECISION:-allow}" = "block" ]; then
  echo "block"
  echo "${HOOK_POLICY_REASON:-BLOCKED: destructive-policy evaluator blocked the command.}"
else
  echo "allow"
fi
