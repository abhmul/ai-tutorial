---
title: Agent Hooks
tags:
  - ai-generated
status: stable
---
# Agent Hooks

Version-controlled source files for the local hook and extension deployments used by Claude Code, Codex, and Pi. Canonical edits happen here; deployment to `~/.claude/`, `~/.codex/`, and `~/.pi/agent/` is still a manual step.

This directory is **not** symlinked into any runtime hook or extension directory. The deployed copies stay isolated so the write-guards in the live Claude, Codex, and Pi configs remain effective. Iteration happens against the working copy; deployed copies only change when you run an explicit manual install or copy command.

Drift between working and deployed copies is accepted as a local-only risk; no automatic sync.

## Layout

| Path | Purpose |
|---|---|
| `lib/obsidian-guard.py` | Shared helper that classifies destructive Obsidian CLI subcommands using `shlex`, so destructive words in argument values do not false-positive. |
| `lib/destructive-policy.sh` | Shared shell policy for destructive command detection, Obsidian confirmation flow, and self-protection checks. |
| `lib/evaluate-destructive-policy.sh` | CLI wrapper around the shared destructive policy for non-shell runtimes such as Pi extensions. |
| `lib/auto-mode-state.sh` | Shared shell helpers for the global `.auto-mode` toggle and per-project opt-out detection. |
| `claude/` | Claude-specific wrappers and a `settings.snippet.json` fragment showing how to wire them into `~/.claude/settings.json`. |
| `codex/` | Codex-specific wrappers plus `hooks.json` and `config.snippet.toml` snippets for `~/.codex/`. |
| `pi/` | Pi extension source for interactive destructive-command escalation. |
| `tests/` | Shared classifier tests plus harness-specific end-to-end tests for Claude, Codex, and Pi. |


## Runtime model

- Claude, Codex, and Pi share the same destructive-command policy and Obsidian delete classifier.
- Claude uses `PreToolUse` for both auto-mode allow and destructive blocking.
- Codex uses `PermissionRequest` for auto-mode allow and `PreToolUse` for destructive blocking.
- Pi uses a global extension with `tool_call` for model-invoked Bash and `user_bash` for `!` / `!!` commands. When a destructive command is detected and Pi has UI, it escalates to `ctx.ui.confirm()` for one-time approval; without UI, it fails closed.
- Claude and Codex support:
  - a global toggle file at `~/.claude/.auto-mode` or `~/.codex/.auto-mode`
  - a per-project opt-out at `<project-root>/.claude/no-auto-mode` or `<project-root>/.codex/no-auto-mode`
- All harnesses support a 30-second explicit confirmation file for destructive Obsidian delete-like commands. Pi also allows approving those commands directly in the interactive confirmation prompt.

## Deployment

Edit here, test here, then deploy manually **from a terminal outside the agent runtime**. That friction is deliberate: hook and config changes should still feel like privileged edits.

Claude and Codex wrappers resolve their shared lib via `$SCRIPT_DIR/../lib/`, so the deploy must place `lib/` as a sibling of `hooks/` under `~/.claude/` and `~/.codex/`. The Pi extension resolves its shared lib via `../lib/` from `~/.pi/agent/extensions/destructive-guard.ts`, so deploy `lib/` under `~/.pi/agent/lib/`. Deploying only the wrapper or extension without the lib leaves the hook broken at every Bash invocation.

### Claude

Deploy the Claude wrappers and the shared lib:

```bash
mkdir -p ~/.claude/lib
cp ~/Documents/vaults/agent-vault/hooks/claude/destructive-guard.sh ~/.claude/hooks/destructive-guard.sh
cp ~/Documents/vaults/agent-vault/hooks/claude/auto-mode.sh         ~/.claude/hooks/auto-mode.sh
cp ~/Documents/vaults/agent-vault/hooks/lib/destructive-policy.sh   ~/.claude/lib/destructive-policy.sh
cp ~/Documents/vaults/agent-vault/hooks/lib/auto-mode-state.sh      ~/.claude/lib/auto-mode-state.sh
cp ~/Documents/vaults/agent-vault/hooks/lib/obsidian-guard.py       ~/.claude/lib/obsidian-guard.py
```

Then merge the fragment in `claude/settings.snippet.json` into `~/.claude/settings.json`.

### Codex

Deploy the Codex wrappers and the shared lib:

```bash
install -D -m 755 ~/Documents/vaults/agent-vault/hooks/codex/destructive-guard.sh ~/.codex/hooks/destructive-guard.sh
install -D -m 755 ~/Documents/vaults/agent-vault/hooks/codex/auto-mode.sh         ~/.codex/hooks/auto-mode.sh
install -D -m 755 ~/Documents/vaults/agent-vault/hooks/lib/destructive-policy.sh  ~/.codex/lib/destructive-policy.sh
install -D -m 755 ~/Documents/vaults/agent-vault/hooks/lib/auto-mode-state.sh     ~/.codex/lib/auto-mode-state.sh
install -D -m 755 ~/Documents/vaults/agent-vault/hooks/lib/obsidian-guard.py      ~/.codex/lib/obsidian-guard.py
install -D -m 600 ~/Documents/vaults/agent-vault/hooks/codex/hooks.json           ~/.codex/hooks.json
```

If your shell aliases `install` to a package manager (e.g. `pacman -S` on Arch), `install -D` will be parsed as two operation flags and fail with `error: only one operation may be used at a time`. Bypass with `/usr/bin/install` or substitute `cp` + `chmod` (the `-D` create-parent behavior is replaceable with an explicit `mkdir -p ~/.codex/lib`).

Then merge the fragment in `codex/config.snippet.toml` into `~/.codex/config.toml`.
The `auto` profile is intentionally unsandboxed and non-interactive; the
destructive `PreToolUse` hook is the accident guard, not a security boundary.

### Pi

Deploy the Pi extension and the shared destructive-policy lib:

```bash
install -D -m 644 ~/Documents/vaults/agent-vault/hooks/pi/destructive-guard.ts              ~/.pi/agent/extensions/destructive-guard.ts
install -D -m 755 ~/Documents/vaults/agent-vault/hooks/lib/evaluate-destructive-policy.sh   ~/.pi/agent/lib/evaluate-destructive-policy.sh
install -D -m 755 ~/Documents/vaults/agent-vault/hooks/lib/destructive-policy.sh            ~/.pi/agent/lib/destructive-policy.sh
install -D -m 755 ~/Documents/vaults/agent-vault/hooks/lib/obsidian-guard.py                ~/.pi/agent/lib/obsidian-guard.py
```

Pi auto-discovers `~/.pi/agent/extensions/*.ts`. Restart Pi or run `/reload` in an existing interactive session after deployment.

Quick sanity checks:

```bash
for f in destructive-guard.sh auto-mode.sh; do
  diff -q ~/Documents/vaults/agent-vault/hooks/claude/$f ~/.claude/hooks/$f
done
for f in destructive-policy.sh auto-mode-state.sh obsidian-guard.py; do
  diff -q ~/Documents/vaults/agent-vault/hooks/lib/$f ~/.claude/lib/$f
done

for f in destructive-guard.sh auto-mode.sh; do
  diff -q ~/Documents/vaults/agent-vault/hooks/codex/$f ~/.codex/hooks/$f
done
for f in destructive-policy.sh auto-mode-state.sh obsidian-guard.py; do
  diff -q ~/Documents/vaults/agent-vault/hooks/lib/$f ~/.codex/lib/$f
done

diff -q ~/Documents/vaults/agent-vault/hooks/pi/destructive-guard.ts ~/.pi/agent/extensions/destructive-guard.ts
for f in evaluate-destructive-policy.sh destructive-policy.sh obsidian-guard.py; do
  diff -q ~/Documents/vaults/agent-vault/hooks/lib/$f ~/.pi/agent/lib/$f
done
```

No output from `diff -q` means the deployed and working copies are identical.

## Testing

From the vault root, use the shared `agent-python` environment documented in `agent-python/README.md`:

```bash
UV_PROJECT_ENVIRONMENT=~/.local/share/agent-python/.venv \
  uv run --project agent-python pytest hooks/tests
```

For a narrower run, pass a specific pytest file such as `hooks/tests/test_pi_hooks.py`.

The pytest suites use a temporary `HOME`, so they do not touch your real `~/.claude`, `~/.codex`, or `~/.pi` confirmation flags.

## Editing workflow

1. Edit files here in `agent-vault/hooks/`.
2. Run `UV_PROJECT_ENVIRONMENT=~/.local/share/agent-python/.venv uv run --project agent-python pytest hooks/tests` from the vault root.
3. Commit the change in `agent-vault`.
4. In a non-agent terminal, deploy the relevant harness files to `~/.claude`, `~/.codex`, and/or `~/.pi/agent`.
5. Restart any live Claude Code, Codex, or Pi sessions to pick up the new hook behavior.

## Known gaps

- The top-level Claude compatibility shims should eventually be removed after local deployments and muscle memory move to the subdirectories.
- Pi has destructive-command escalation, not Claude/Codex-style auto-mode. Add a separate Pi extension only if a real Pi auto-approval workflow becomes necessary.
- Deployment is manual. Keep it that way unless the step count grows enough to justify a deliberately reviewed installer.
