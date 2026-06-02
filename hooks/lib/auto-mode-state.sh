#!/bin/bash
# Shared helpers for deciding whether hook-based auto mode is enabled.

hook_resolve_git_root() {
  local cwd="$1"

  if [ -z "$cwd" ] || ! command -v git >/dev/null 2>&1; then
    return 1
  fi

  git -C "$cwd" rev-parse --show-toplevel 2>/dev/null
}

hook_auto_mode_enabled() {
  local hook_home="$1"
  [ -f "$hook_home/.auto-mode" ]
}

hook_auto_mode_opted_out() {
  local cwd="$1"
  local project_dir="$2"
  local hook_dir_name="$3"
  local repo_root=""

  if [ -n "$project_dir" ] && [ -f "$project_dir/$hook_dir_name/no-auto-mode" ]; then
    return 0
  fi

  if [ -n "$cwd" ] && [ -f "$cwd/$hook_dir_name/no-auto-mode" ]; then
    return 0
  fi

  repo_root=$(hook_resolve_git_root "$cwd" || true)
  if [ -n "$repo_root" ] && [ -f "$repo_root/$hook_dir_name/no-auto-mode" ]; then
    return 0
  fi

  return 1
}
