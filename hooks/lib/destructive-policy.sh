#!/bin/bash
# Shared destructive-command policy for local agent hooks.

hook_policy_escape_regex_literal() {
  printf '%s' "$1" | sed 's/[][(){}.^$*+?|/]/\\&/g'
}

hook_policy_set_allow() {
  HOOK_POLICY_DECISION="allow"
  HOOK_POLICY_REASON=""
}

hook_policy_set_block() {
  HOOK_POLICY_DECISION="block"
  HOOK_POLICY_REASON="$1"
}

hook_policy_init() {
  : "${HOOK_HOME:?HOOK_HOME is required}"
  : "${HOOK_PLATFORM_LABEL:?HOOK_PLATFORM_LABEL is required}"
  : "${HOOK_PROTECTED_FILES_REGEX:?HOOK_PROTECTED_FILES_REGEX is required}"
}

hook_policy_evaluate_command() {
  local cmd="$1"
  local obsidian_guard="$2"
  local flag=""
  local confirmed_at=""
  local now=""
  local hook_dir_name=""
  local protected_home_regex=""

  hook_policy_init
  hook_policy_set_allow

  hook_dir_name=$(basename "$HOOK_HOME")
  protected_home_regex="${HOOK_PROTECTED_HOME_REGEX:-$(hook_policy_escape_regex_literal "$hook_dir_name")}"

  if echo "$cmd" | grep -qE '^obsidian\b'; then
    if ! echo "$cmd" | python3 "$obsidian_guard" 2>/dev/null; then
      flag="$HOOK_HOME/obsidian-delete-confirmed"
      if [ -f "$flag" ]; then
        confirmed_at=$(cat "$flag" 2>/dev/null)
        now=$(date +%s)
        rm -f "$flag"
        if [[ "$confirmed_at" =~ ^[0-9]+$ ]] && [ "$((now - confirmed_at))" -le 30 ]; then
          return 0
        fi

        hook_policy_set_block "BLOCKED: Obsidian deletion confirmation expired (>30s). Run: echo \$(date +%s) > $HOOK_HOME/obsidian-delete-confirmed and retry immediately."
        return 0
      fi

      hook_policy_set_block "BLOCKED: Obsidian deletion requires explicit confirmation. Run: echo \$(date +%s) > $HOOK_HOME/obsidian-delete-confirmed and retry within 30 seconds."
      return 0
    fi
  fi

  if echo "$cmd" | grep -qiE "(^|[^a-zA-Z])(rm|mv|cp|install|ln|truncate|shred|chmod|tee)[[:space:]].*(~|\\\$HOME|/home/[^/]+)/$protected_home_regex/(hooks/|$HOOK_PROTECTED_FILES_REGEX)"; then
    hook_policy_set_block "BLOCKED: command would modify $HOOK_PLATFORM_LABEL guard or config files."
    return 0
  fi

  if echo "$cmd" | grep -qiE '(^|[^a-zA-Z])rm[[:space:]]'; then
    local has_r=0
    local has_f=0
    echo "$cmd" | grep -qiE -- '([[:space:]]|^)-[[:alnum:]]*r[[:alnum:]]*([[:space:]]|$)|--recursive\b' && has_r=1
    echo "$cmd" | grep -qiE -- '([[:space:]]|^)-[[:alnum:]]*f[[:alnum:]]*([[:space:]]|$)|--force\b' && has_f=1
    if [ "$has_r" = "1" ]; then
      if [ "$has_f" = "1" ]; then
        hook_policy_set_block "BLOCKED: recursive force remove detected."
      else
        hook_policy_set_block "BLOCKED: recursive remove detected."
      fi
      return 0
    fi
  fi

  if echo "$cmd" | grep -qiE '(^|[^a-zA-Z])find\b.*(-delete\b|-exec[[:space:]]+rm\b|-execdir[[:space:]]+rm\b)'; then
    hook_policy_set_block "BLOCKED: find delete or exec rm detected."
    return 0
  fi

  if echo "$cmd" | grep -qiE '(^|[^a-zA-Z])(shred|wipefs|blkdiscard)\b|(^|[^a-zA-Z])truncate[[:space:]]+-s[[:space:]]*0\b'; then
    hook_policy_set_block "BLOCKED: data-destruction utility detected."
    return 0
  fi

  if echo "$cmd" | grep -qiE '(^|[^a-zA-Z])dd\b.*of=/dev/(sd|nvme|hd|vd|mmcblk|xvd|loop|disk)|(^|[^a-zA-Z])mkfs\.[a-z0-9]+\b|>[[:space:]]*/dev/(sd|nvme|hd|vd|mmcblk|xvd|disk)'; then
    hook_policy_set_block "BLOCKED: block-device write or format detected."
    return 0
  fi

  if echo "$cmd" | grep -qiE "(^|[^>])>[[:space:]]*[^[:space:]|;&]*/(\\.ssh/authorized_keys|\\.bashrc|\\.zshrc|\\.profile|\\.bash_profile|$protected_home_regex/(hooks/|$HOOK_PROTECTED_FILES_REGEX))|(^|[^>])>[[:space:]]*/etc/"; then
    hook_policy_set_block "BLOCKED: truncating redirect to a critical file."
    return 0
  fi

  local sql_patterns='DROP[[:space:]]+(TABLE|DATABASE|SCHEMA|INDEX|VIEW|FUNCTION|PROCEDURE|TRIGGER|USER|ROLE)\b|TRUNCATE[[:space:]]+TABLE\b|DELETE[[:space:]]+FROM[[:space:]]+[a-zA-Z_]+|ALTER[[:space:]]+TABLE[[:space:]]+[a-zA-Z_]+[[:space:]]+DROP[[:space:]]+COLUMN'
  if echo "$cmd" | grep -qiE "$sql_patterns"; then
    local matched=""
    matched=$(echo "$cmd" | grep -oiE "$sql_patterns" | head -1)
    hook_policy_set_block "BLOCKED: SQL destructive statement detected: '$matched'."
    return 0
  fi

  local git_destructive='git[[:space:]]+reset[[:space:]]+--hard\b|git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*[fdx][a-zA-Z]*\b|git[[:space:]]+checkout[[:space:]]+\.([[:space:]]|$)|git[[:space:]]+restore[[:space:]]+\.([[:space:]]|$)|git[[:space:]]+checkout[[:space:]]+--[[:space:]]|git[[:space:]]+filter-branch\b|git[[:space:]]+filter-repo\b|git[[:space:]]+reflog[[:space:]]+expire\b|git[[:space:]]+update-ref[[:space:]]+-d\b|git[[:space:]]+gc[[:space:]]+.*--prune=now|git[[:space:]]+worktree[[:space:]]+remove[[:space:]]+.*--force\b'
  if echo "$cmd" | grep -qE "$git_destructive"; then
    local matched=""
    matched=$(echo "$cmd" | grep -oE "$git_destructive" | head -1)
    hook_policy_set_block "BLOCKED: destructive git operation detected: '$matched'."
    return 0
  fi

  if echo "$cmd" | grep -qE 'git[[:space:]]+push\b' && echo "$cmd" | grep -qE '(--force\b|--force-with-lease\b|[[:space:]]-[a-zA-Z]*f[a-zA-Z]*([[:space:]]|$))'; then
    hook_policy_set_block "BLOCKED: force push detected."
    return 0
  fi

  if echo "$cmd" | grep -qE 'git[[:space:]]+push\b.*(--delete\b|[[:space:]]:[a-zA-Z_])'; then
    hook_policy_set_block "BLOCKED: remote branch deletion detected."
    return 0
  fi

  if echo "$cmd" | grep -qiE '(curl|wget|fetch)\b[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh|fish|python[0-9]?|ruby|perl|node)\b'; then
    hook_policy_set_block "BLOCKED: pipe-to-shell execution detected."
    return 0
  fi

  if echo "$cmd" | grep -qiE '(^|[^a-zA-Z])sudo[[:space:]]+(pacman[[:space:]]+.*-R[a-zA-Z]*\b|apt(-get)?[[:space:]]+.*\b(remove|purge|autoremove)\b|dnf[[:space:]]+.*\b(remove|erase)\b|yum[[:space:]]+.*\bremove\b|zypper[[:space:]]+.*\b(remove|rm)\b|apk[[:space:]]+.*\b(del|remove)\b)'; then
    hook_policy_set_block "BLOCKED: system package uninstall detected."
    return 0
  fi

  if echo "$cmd" | grep -qiE '(^|[^a-zA-Z])(sudo[[:space:]]+)?(shutdown|reboot|halt|poweroff)\b|(^|[^a-zA-Z])init[[:space:]]+[06]\b|systemctl[[:space:]]+(poweroff|reboot|halt)\b'; then
    hook_policy_set_block "BLOCKED: shutdown or reboot command detected."
    return 0
  fi

  if echo "$cmd" | grep -qiE "chmod\b[^;|&]*(~|\\\$HOME|/home/[^/]+)/$protected_home_regex/(hooks/|$HOOK_PROTECTED_FILES_REGEX)"; then
    hook_policy_set_block "BLOCKED: chmod targeting $HOOK_PLATFORM_LABEL hook or config files."
    return 0
  fi
}
