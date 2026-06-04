# Orchestration setup

Use this file to configure how the orchestration skill dispatches workers in a specific project and harness. Keep `SKILL.md` focused on orchestration behavior; keep install commands, tool choices, paths, and harness-specific worker details here or in a project-local setup note.

When this file says Pi, it means the `pi` terminal coding harness documented at pi.dev, not Raspberry Pi hardware.

## Setup outcome

A completed setup should produce a reviewed project-local orchestration profile, stored somewhere the user approves, such as `AGENTS.md`, `.agents/orchestration.md`, `.pi/orchestration.md`, or another project note. The profile should state:

```md
# Orchestration local setup
- Harness:
- Worker dispatch method:
- Task directory:
- State file path:
- Handoff directory:
- Worker command or subagent invocation:
- Tool and network limits:
- Forbidden reads and writes:
- Verification requirements:
- How to check a running worker:
```

Do not silently edit global harness configuration. Draft changes for review when setup affects permissions, installs tools, changes global settings, or starts background workers.

## Agent-guided setup procedure

1. Identify the current harness and constraints: Pi coding harness, Codex, Claude Code, another tool, or manual sessions; note OS, shell, available commands, network policy, and project safety rules.
2. Choose task storage: a project-local task directory, state file, and handoff directory. Avoid `tmp/` and `archive/` unless the project explicitly permits them.
3. Choose one worker dispatch method from the options below. Prefer the simplest method that satisfies the worker contract in `SKILL.md`.
4. Record the selected method in the project-local orchestration profile, including exact commands or subagent invocation steps.
5. Run a small smoke test: create one read-only task, dispatch one worker, require a handoff, ingest it, and confirm that the worker respected file boundaries and tool limits.
6. Only after the smoke test should the orchestrator use the method for real delegated work.

## Worker dispatch options

### Manual fresh-session handoff

Use this when no native or scripted worker method is configured, or when the user wants maximum transparency.

1. The orchestrator writes a task file and handoff path.
2. The user starts a fresh session in the chosen harness and gives it the task file path plus any must-read files.
3. The worker writes the requested handoff artifact.
4. The orchestrator reads the handoff, updates state, and schedules verification or follow-up tasks.

This requires no install, but it is slower and depends on the user to start each worker.

### Native subagents

Codex and Claude Code document native subagent workflows. Use the current official docs for the user's installed version, then record the exact project-local invocation pattern in the orchestration profile.

- Codex: see [Codex subagents](https://developers.openai.com/codex/subagents).
- Claude Code: see [Claude Code subagents](https://docs.anthropic.com/en/docs/claude-code/sub-agents). Claude Code also documents [agent teams](https://docs.anthropic.com/en/docs/claude-code/agent-teams) as an advanced workflow; do not treat teams as the default without user review.

Do not copy Pi/tmux commands into Codex or Claude Code setup. Verify how the harness passes context, tools, sandboxing, and permissions to its subagents.

### Pi coding harness with tmux external workers

The [Pi usage docs](https://pi.dev/docs/latest/usage) describe Pi as intentionally not including built-in subagents. This optional method starts a separate `pi` process in a detached `tmux` session by using this skill's watcher script. It is a Pi coding harness implementation detail, not Raspberry Pi setup and not a cross-harness subagent system.

Prerequisites:

- `pi` is installed and on `PATH` for the shell that will launch workers;
- `tmux` is installed and on `PATH`;
- the worker process can see the project files, project instructions, needed skills, and needed tools;
- any network-dependent skill, such as web discovery, has its own setup completed first;
- the user has reviewed the tool allowlist and log/status directory.

Check prerequisites:

```bash
command -v pi
pi --version
command -v tmux
tmux -V
```

Run the watcher from the skill directory or from the installed skill path. From a normal `.agents` skill install, the command is:

```bash
bash .agents/skills/orchestration/references/pi-worker-watch.sh "<pointer to task>"
```

From inside this repository, use the repository-relative path:

```bash
bash skills/orchestration/references/pi-worker-watch.sh "<pointer to task>"
```

The script starts `pi -p -t "read,grep,find,ls,edit,write,bash" "<pointer to task>"` in detached `tmux`, writes logs and status under `.pi-workers` by default, waits for a bounded interval, and prints recent log lines. If the worker is still running, use the printed `--watch <run-dir>` command to check it later. Use `--tools`, `--wait-seconds`, `--worker-root`, and the script's `--help` output when the project needs different limits.

If `pi` or `tmux` is unavailable, report that this worker mechanism is unavailable and choose another setup option. Do not inline or reconstruct the watcher script.

For interactive Pi sessions inside tmux, modified Enter keys may need tmux extended-key configuration; see the [Pi tmux docs](https://pi.dev/docs/latest/tmux) if the user reports keybinding issues. Detached worker runs usually do not depend on interactive modified-key input.

### Other harness or custom worker command

Map the harness to the worker contract in `SKILL.md`. The setup record must answer:

- how to start a worker with bounded context;
- how to restrict tools, network, writes, and installs;
- how to pass task files and required context;
- where the worker writes handoffs;
- how the orchestrator checks completion or failure;
- how independent verification workers are separated from producer workers.

If any answer is missing, setup is incomplete.

## Smoke test template

Use a harmless task like this before real work:

```md
Task ID: smoke-001
Type: exploration
Scope: Read only the repository README and the orchestration setup profile.
Goals: Summarize the configured worker method and confirm the handoff path.
Non-goals: Do not edit files. Do not use network. Do not read tmp/ or archive/.
Success criteria: Handoff names files read, confirms no edits, and lists any setup blockers.
Handoff path: <handoff-dir>/smoke-001.md
```

If the smoke test fails, fix setup before using orchestration for substantive work.
