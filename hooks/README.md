---
title: Agent Hooks
tags:
  - ai-generated
status: stable
---
# Agent Hooks

These are version-controlled examples of local hooks and extensions for Claude Code, Codex, and Pi. A hook is a command or extension that an agent harness runs around a tool event, such as a proposed Bash command. Treat these files as advanced, opt-in accident guards and workflow examples, not as beginner defaults and not as security boundaries.

The preferred setup path is agent-assisted customization with human review: ask an agent to inspect this directory, compare it with your existing harness config, and draft a small deployment plan or diff. Do not blindly copy these snippets into a live config, especially if you already have hooks, permissions, or profiles configured.

## Layout

| Path | Purpose |
|---|---|
| `lib/obsidian-guard.py` | Shared helper that classifies destructive Obsidian CLI subcommands using `shlex`, so destructive words in argument values do not false-positive. |
| `lib/destructive-policy.sh` | Shared shell policy for destructive command detection, Obsidian confirmation flow, and self-protection checks. |
| `lib/evaluate-destructive-policy.sh` | CLI wrapper around the shared destructive policy for non-shell runtimes such as Pi extensions. |
| `lib/auto-mode-state.sh` | Shared shell helpers for the global `.auto-mode` toggle and per-project opt-out detection. |
| `claude/` | Claude-specific wrappers and a `settings.snippet.json` fragment showing how to wire them into Claude Code settings. |
| `codex/` | Codex-specific wrappers, `hooks.json`, `config.snippet.toml` for the base config, and `auto.config.snippet.toml` for a separate advanced profile file. |
| `pi/` | Pi extension source for interactive destructive-command escalation. |
| `tests/` | Shared classifier tests plus harness-specific end-to-end tests for Claude, Codex, and Pi. |

## Prerequisites

- Bash for the Claude/Codex wrappers and the shared shell policy.
- `jq` for Claude and Codex hook input parsing. The destructive guards fail closed when they cannot parse input; the auto-mode wrappers do nothing without `jq`, so normal approval flow continues.
- `python3` for `lib/obsidian-guard.py`, which is called by the shared destructive policy when a command starts with `obsidian`.
- `git` if you want auto-mode project opt-outs to be discovered from a repository root; the wrappers still check the current directory even when `git` is unavailable.
- Harness support for the feature you are installing: [Claude Code hooks/settings](https://docs.anthropic.com/en/docs/claude-code/hooks), [Codex hooks](https://developers.openai.com/codex/hooks), [Codex configuration](https://developers.openai.com/codex/config-advanced), or [Pi extensions/settings](https://pi.dev/docs/latest/extensions).

## Runtime model

- Claude, Codex, and Pi share the same destructive-command policy and Obsidian delete classifier.
- Claude uses `PreToolUse` for both auto-mode allow and destructive blocking.
- Codex uses `PermissionRequest` for auto-mode allow and `PreToolUse` for destructive blocking. Current Codex docs use `features.hooks` as the explicit hook feature key; older hook feature aliases are deprecated.
- Pi uses a global extension with `tool_call` for model-invoked Bash and `user_bash` for `!` / `!!` commands. When a destructive command is detected and Pi has UI, it escalates to `ctx.ui.confirm()` for one-time approval; without UI, it blocks.
- Claude and Codex support a global auto-mode toggle file at `~/.claude/.auto-mode` or `~/.codex/.auto-mode`, plus a per-project opt-out file at `<project-root>/.claude/no-auto-mode` or `<project-root>/.codex/no-auto-mode`.
- All harnesses support a 30-second explicit confirmation file for destructive Obsidian delete-like commands. The file is `~/.claude/obsidian-delete-confirmed`, `~/.codex/obsidian-delete-confirmed`, or `~/.pi/agent/obsidian-delete-confirmed`; the policy consumes it after one check. Pi also allows approving those commands directly in the interactive confirmation prompt.

These guards are heuristic friction. They can catch common destructive commands, self-modification attempts, and delete-like Obsidian CLI calls, but they do not replace sandboxing, backups, human review, or a trusted hook configuration. Codex command hooks also require trust review through the harness UI according to the Codex hook docs.

## Failure behavior

- Claude destructive guard: if `jq` is missing or the hook input cannot be parsed, the wrapper exits with a block message so Bash access is not silently allowed. For safe commands it emits an explicit `allow` decision.
- Codex destructive guard: for blocked commands it returns a `PreToolUse` deny decision when possible; if `jq` is unavailable it exits non-zero with a block message. For safe commands it emits no output, so normal Codex behavior continues.
- Claude and Codex auto-mode wrappers: if the global toggle is absent, `jq` is missing, or a project opt-out exists, they emit no output and normal approval flow continues.
- Pi extension: evaluator errors, missing Bash command input, and destructive commands without an interactive UI are blocked.

## Deployment

Deployment is manual on purpose. The examples below assume you are at this repository root and have reviewed the destination files first. Replace paths or ask an agent to adapt the plan if your harness config lives somewhere else.

```bash
cd /path/to/ai-tools-intro
SRC="$PWD/hooks"
```

### Claude Code

Deploy the Claude wrappers and the shared lib, then merge the settings fragment by hand instead of overwriting an existing settings file:

```bash
mkdir -p ~/.claude/hooks ~/.claude/lib
cp "$SRC/claude/destructive-guard.sh" ~/.claude/hooks/destructive-guard.sh
cp "$SRC/claude/auto-mode.sh" ~/.claude/hooks/auto-mode.sh
cp "$SRC/lib/destructive-policy.sh" ~/.claude/lib/destructive-policy.sh
cp "$SRC/lib/auto-mode-state.sh" ~/.claude/lib/auto-mode-state.sh
cp "$SRC/lib/obsidian-guard.py" ~/.claude/lib/obsidian-guard.py
chmod 755 ~/.claude/hooks/destructive-guard.sh ~/.claude/hooks/auto-mode.sh ~/.claude/lib/destructive-policy.sh ~/.claude/lib/auto-mode-state.sh
```

Review `claude/settings.snippet.json` and merge it into the appropriate Claude Code settings file for your scope. Claude Code supports user and project settings; choose the smallest scope that matches your use case.

### Codex

Deploy the Codex wrappers, shared lib, and hook map, then merge the base config snippet by hand:

```bash
mkdir -p ~/.codex/hooks ~/.codex/lib
cp "$SRC/codex/destructive-guard.sh" ~/.codex/hooks/destructive-guard.sh
cp "$SRC/codex/auto-mode.sh" ~/.codex/hooks/auto-mode.sh
cp "$SRC/lib/destructive-policy.sh" ~/.codex/lib/destructive-policy.sh
cp "$SRC/lib/auto-mode-state.sh" ~/.codex/lib/auto-mode-state.sh
cp "$SRC/lib/obsidian-guard.py" ~/.codex/lib/obsidian-guard.py
cp "$SRC/codex/hooks.json" ~/.codex/hooks.json
chmod 755 ~/.codex/hooks/destructive-guard.sh ~/.codex/hooks/auto-mode.sh ~/.codex/lib/destructive-policy.sh ~/.codex/lib/auto-mode-state.sh
chmod 600 ~/.codex/hooks.json
```

Review `codex/config.snippet.toml` and merge it into `~/.codex/config.toml` only if you want to show the hook feature key explicitly. Current Codex docs say hooks are enabled by default, and the current explicit key is `features.hooks`.

`codex/auto.config.snippet.toml` is a separate advanced example for `~/.codex/auto.config.toml`. It uses top-level profile settings in the separate profile file, not a nested profile table in the main config. This profile sets `approval_policy = "never"` and `sandbox_mode = "danger-full-access"`, so reserve it for isolated environments where you have decided that full-access/no-approval operation is acceptable. Use current Codex profile invocation such as `codex --profile auto` or `codex exec --profile auto ...`; do not make this profile your default beginner setup.

After adding or changing Codex command hooks, review and trust them through Codex's hook UI as described in the Codex hook docs.

### Pi

Deploy the Pi extension and shared destructive-policy lib:

```bash
mkdir -p ~/.pi/agent/extensions ~/.pi/agent/lib
cp "$SRC/pi/destructive-guard.ts" ~/.pi/agent/extensions/destructive-guard.ts
cp "$SRC/lib/evaluate-destructive-policy.sh" ~/.pi/agent/lib/evaluate-destructive-policy.sh
cp "$SRC/lib/destructive-policy.sh" ~/.pi/agent/lib/destructive-policy.sh
cp "$SRC/lib/obsidian-guard.py" ~/.pi/agent/lib/obsidian-guard.py
chmod 755 ~/.pi/agent/lib/evaluate-destructive-policy.sh ~/.pi/agent/lib/destructive-policy.sh
```

Pi auto-discovers extensions under `~/.pi/agent/extensions/`. Restart Pi or run `/reload` in an existing interactive session after deployment.

## Drift checks

Run drift checks from the same repository root after deployment. No output from `diff -q` means the deployed and working copies are identical.

```bash
SRC="$PWD/hooks"
diff -q "$SRC/claude/destructive-guard.sh" ~/.claude/hooks/destructive-guard.sh
diff -q "$SRC/claude/auto-mode.sh" ~/.claude/hooks/auto-mode.sh
diff -q "$SRC/codex/destructive-guard.sh" ~/.codex/hooks/destructive-guard.sh
diff -q "$SRC/codex/auto-mode.sh" ~/.codex/hooks/auto-mode.sh
diff -q "$SRC/codex/hooks.json" ~/.codex/hooks.json
diff -q "$SRC/pi/destructive-guard.ts" ~/.pi/agent/extensions/destructive-guard.ts
```

## Testing

Use a Python environment with `pytest` installed. One portable project-local option is:

```bash
cd /path/to/ai-tools-intro
python3 -m venv .venv
. .venv/bin/activate
python -m pip install pytest
python -m pytest hooks/tests
```

The tests use a temporary `HOME`, so they do not touch your real `~/.claude`, `~/.codex`, or `~/.pi` files. Claude and Codex tests require `jq`; Pi extension tests require `node`; tests that cannot find those programs are skipped. Python 3.11 or newer is needed for the Codex TOML assertions because the tests use `tomllib`.

## Editing workflow

1. Edit files in this repository's `hooks/` directory.
2. Run the relevant tests, or at least the harness-specific test file for the files you changed.
3. Review config snippets against the current harness docs before deploying.
4. From a non-agent terminal, copy the reviewed files into `~/.claude`, `~/.codex`, or `~/.pi/agent` as needed.
5. Restart or reload live Claude Code, Codex, or Pi sessions to pick up the new hook behavior.

## Known gaps

- The guards are command-pattern checks, not a complete parser for every shell program or every agent tool path.
- Pi has destructive-command escalation, not Claude/Codex-style auto-mode. Add a separate Pi extension only if a real Pi auto-approval workflow becomes necessary.
- Deployment is manual. Keep it that way unless a future installer is deliberately reviewed and documented as a privileged operation.
