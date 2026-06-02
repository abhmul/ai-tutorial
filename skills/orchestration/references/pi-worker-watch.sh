#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage:
  pi-worker-watch.sh [options] "<pointer to task>"
  pi-worker-watch.sh [options] --watch <run-dir>

Starts a pi worker in a detached tmux session, then waits until either the
worker exits or the wait window elapses. It prints the worker run directory,
status, and the last log lines before exiting.

Options:
  --wait-seconds N   Seconds to wait before returning for a progress check (default: 1800)
  --poll-seconds N   Seconds between status checks (default: 5)
  --tail-lines N     Log lines to print when returning (default: 25)
  --tools LIST       Tool allowlist passed to pi -t (default: read,grep,find,ls,edit,write,bash)
  --worker-root DIR  Directory for worker logs/status (default: $PWD/.pi-workers)
  --watch DIR        Watch an existing worker run directory instead of starting a new worker
  -h, --help         Show this help

Environment:
  PI_BIN             pi executable to run (default: pi)
USAGE
}

is_uint() {
  [[ "${1:-}" =~ ^[0-9]+$ ]]
}

shell_quote() {
  printf '%q' "$1"
}

wait_seconds="${PI_WORKER_WAIT_SECONDS:-1800}"
poll_seconds="${PI_WORKER_POLL_SECONDS:-5}"
tail_lines="${PI_WORKER_TAIL_LINES:-25}"
tools="${PI_WORKER_TOOLS:-read,grep,find,ls,edit,write,bash}"
worker_root="${PI_WORKER_ROOT:-$PWD/.pi-workers}"
pi_bin="${PI_BIN:-pi}"
watch_dir=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wait-seconds)
      wait_seconds="${2:-}"
      shift 2
      ;;
    --poll-seconds)
      poll_seconds="${2:-}"
      shift 2
      ;;
    --tail-lines)
      tail_lines="${2:-}"
      shift 2
      ;;
    --tools)
      tools="${2:-}"
      shift 2
      ;;
    --worker-root)
      worker_root="${2:-}"
      shift 2
      ;;
    --watch)
      watch_dir="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      exit 64
      ;;
    *)
      break
      ;;
  esac
done

if ! is_uint "$wait_seconds" || ! is_uint "$poll_seconds" || ! is_uint "$tail_lines"; then
  echo "--wait-seconds, --poll-seconds, and --tail-lines must be non-negative integers" >&2
  exit 64
fi

if [[ "$poll_seconds" -eq 0 && "$wait_seconds" -gt 0 ]]; then
  echo "--poll-seconds must be greater than 0 when --wait-seconds is greater than 0" >&2
  exit 64
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
script_path="$script_dir/$(basename "${BASH_SOURCE[0]}")"

print_tail() {
  local log="$1"
  echo "--- tail -n $tail_lines $log ---"
  if [[ -f "$log" ]]; then
    tail -n "$tail_lines" "$log" || true
  else
    echo "log file not found: $log"
  fi
}

watch_run() {
  local run_dir="$1"
  local run_id
  run_id="$(basename "$run_dir")"
  local status="$run_dir/status"
  local log="$run_dir/output.log"
  local deadline now remaining sleep_for code

  deadline=$(( $(date +%s) + wait_seconds ))
  while [[ ! -s "$status" ]]; do
    now=$(date +%s)
    if [[ "$now" -ge "$deadline" ]]; then
      break
    fi
    remaining=$(( deadline - now ))
    sleep_for="$poll_seconds"
    if [[ "$remaining" -lt "$sleep_for" ]]; then
      sleep_for="$remaining"
    fi
    if [[ "$sleep_for" -le 0 ]]; then
      break
    fi
    sleep "$sleep_for"
  done

  echo "worker run dir: $run_dir"

  if [[ -s "$status" ]]; then
    code="$(tr -d '\r\n' < "$status" || true)"
    echo "worker finished: $run_id exit $code"
    print_tail "$log"
    if is_uint "$code"; then
      exit "$code"
    fi
    exit 1
  fi

  if command -v tmux >/dev/null 2>&1 && tmux has-session -t "$run_id" 2>/dev/null; then
    echo "$wait_seconds-second check: worker still running: $run_id"
    echo "watch again: bash $(shell_quote "$script_path") --watch $(shell_quote "$run_dir")"
    echo "attach: tmux attach-session -t $(shell_quote "$run_id")"
    print_tail "$log"
    exit 0
  fi

  echo "worker session ended but no status file: $run_id" >&2
  print_tail "$log"
  exit 1
}

if [[ -n "$watch_dir" ]]; then
  if [[ $# -gt 0 ]]; then
    echo "Unexpected arguments after --watch: $*" >&2
    usage
    exit 64
  fi
  if [[ ! -d "$watch_dir" ]]; then
    echo "worker run directory not found: $watch_dir" >&2
    exit 66
  fi
  watch_run "$watch_dir"
fi

if [[ $# -lt 1 ]]; then
  echo "Missing pointer to task" >&2
  usage
  exit 64
fi

task="$*"

if ! command -v "$pi_bin" >/dev/null 2>&1; then
  echo "pi executable not found: $pi_bin" >&2
  exit 127
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required to run detached pi workers" >&2
  exit 127
fi

cwd="$PWD"
mkdir -p "$worker_root"
worker_root="$(cd "$worker_root" && pwd -P)"
run_id="pi-worker-$(date +%Y%m%d-%H%M%S)-$$-${RANDOM}"
run_dir="$worker_root/$run_id"
mkdir -p "$run_dir"

log="$run_dir/output.log"
status="$run_dir/status"
runner="$run_dir/run-worker.sh"
metadata="$run_dir/metadata.txt"
: > "$log"

cat > "$metadata" <<EOF
started_at=$(date -Iseconds)
cwd=$cwd
tmux_session=$run_id
tools=$tools
task=$task
EOF

{
  echo '#!/usr/bin/env bash'
  echo 'set -u'
  printf 'cd %q\n' "$cwd"
  printf 'pi_bin=%q\n' "$pi_bin"
  printf 'tools=%q\n' "$tools"
  printf 'task=%q\n' "$task"
  printf 'log=%q\n' "$log"
  printf 'status=%q\n' "$status"
  cat <<'RUNNER'
"$pi_bin" -p -t "$tools" "$task" </dev/null >"$log" 2>&1
code=$?
printf '%s\n' "$code" >"$status"
exit "$code"
RUNNER
} > "$runner"
chmod +x "$runner"

tmux new-session -d -s "$run_id" "bash $(shell_quote "$runner")"

echo "worker started: $run_id"
watch_run "$run_dir"
