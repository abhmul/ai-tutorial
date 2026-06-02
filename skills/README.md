# Skills

A skill is a reusable instruction bundle for an agent. The main file is usually `SKILL.md`; setup instructions should live in companion files such as `references/setup.md` or in this README. Extra examples or scripts may live beside the skill. A harness is the program that runs the model and tools, such as Codex, Claude Code, or Pi.

These skills are examples, not drop-in setup for every tool. Read each skill's requirements before use, and ask an agent to help adapt the wording, paths, and permissions to your harness if needed.

## Beginner path

- `grill-me`: a questioning skill for stress-testing an idea, plan, draft, proof, or design. File, network, and literature exploration only works when the current agent has the needed tools and permissions.
- `checkpoint`: a work-saving skill. It writes `daily-notes/YYYY-MM-DD.md` and may create a Git commit, so use it only when those side effects fit the task.

## Advanced examples

- `web-discovery`: web/code/docs research. It needs network permission plus Ketch or an equivalent search-plus-retrieval workflow; see [`web-discovery/references/setup.md`](web-discovery/references/setup.md). Search results are leads; retrieved source text is evidence.
- `orchestration`: task delegation for large work. Start with the portable task-and-handoff pattern, then choose a harness-specific worker method. The included Pi/tmux watcher is one advanced implementation, not a general subagent system.
- `tdd`: test-driven development workflow guidance. It is useful when you want a red-green-refactor loop and behavior-focused tests.

## Portability and setup

The [Agent Skills specification](https://agentskills.io/specification) defines a common `SKILL.md` format, and Codex, Claude Code, and Pi each document their own skill support in [Codex skills](https://developers.openai.com/codex/skills), [Claude Code skills](https://docs.anthropic.com/en/docs/claude-code/skills), and [Pi skills](https://pi.dev/docs/latest/skills). Tool locations, permissions, network access, and subagent behavior differ by harness. Treat any port as a reviewed adaptation, not automatic conversion.

Prefer agent-assisted setup with human review over blind copy-paste. For hooks, high-privilege profiles, web backends, and worker processes, review what files will be changed and what commands will run before enabling them.
