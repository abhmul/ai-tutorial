# Recommendations: Getting Started with AI Tools

These are my practical recommendations for basic AI tool usage and for understanding the core principles of using these tools effectively and safely. The path is: try chat tools, try one agentic tool on a real project, learn permissions, and manage context. The advanced skills and hooks in this repository are examples you can inspect later; they are not beginner defaults.

## Overview

This guide moves from chat-based use of language models, to agentic tools that act on your filesystem and terminal, to the permission and misalignment concerns that come with them, and finally to further resources. Expect your productivity to be low at first because these tools take practice.

- [Recommendations: Getting Started with AI Tools](#recommendations-getting-started-with-ai-tools)
  - [Overview](#overview)
  - [Quick start](#quick-start)
  - [1. Get a feel for language model capabilities](#1-get-a-feel-for-language-model-capabilities)
  - [2. Move from chat to agentic tools](#2-move-from-chat-to-agentic-tools)
    - [Local examples versus beginner defaults](#local-examples-versus-beginner-defaults)
    - [Permissions: a caution](#permissions-a-caution)
    - [Misalignment](#misalignment)
  - [3. Resources once you're going](#3-resources-once-youre-going)
  - [Contact](#contact)

## Quick start

A condensed version of the steps below; each links to the section that expands it.

1. **Try a chat model on real work.** Use [ChatGPT or Claude](#1-get-a-feel-for-language-model-capabilities) on something you are actually working on, and think about how to give it the relevant context.
2. **Compare capability deliberately.** Free plans are enough to learn the basics. If a task matters and the tool offers a paid or reasoning-focused mode, try it for a bounded period and check current official pricing before subscribing.
3. **Debug failures in a separate chat.** When it gets something wrong, open a separate chat with the prompt, the response, and what the problem was.
4. **Move to an agentic tool.** Install [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) or [Codex](https://developers.openai.com/codex) and try it on a real project. Claude Code and Codex document `/init` commands; for other tools, check the tool's own setup docs.
5. **Learn it deliberately.** Ask the tool to help you learn it, and keep a separate notes file of usage patterns.
6. **Never blind-approve permissions.** Review every [permission prompt](#permissions-a-caution), track what you approve, and start from normal permissions or sandboxing rather than high-privilege no-approval modes.
7. **Keep advanced examples separate.** The repository's [skills](skills/README.md) and [hooks](hooks/README.md) can be useful, but install or adapt them only after review.
8. **Manage context and misalignment.** When the agent misunderstands you, [debug with it](#misalignment) and keep its context buffer relevant and concise.

## 1. Get a feel for language model capabilities

Start with [ChatGPT](https://chatgpt.com/) or [Claude AI](https://claude.ai/) to get a feel for how language models can be useful in general. The free versions are enough to learn the interaction pattern. Paid plans, model names, and model features change over time, so check the official product pages when deciding whether a subscription is worth it for your use case.

I recommend the following approach: when you are working on something, try to use ChatGPT or Claude to help with it. Consider how to give it the relevant context, then problem-solve when it does not get something right. A good technique is to use the model to help you debug the issue, since the issue may be arising from a misunderstanding embedded in the model's context.

Going through this process builds intuition for how to get better results from language models. For hard tasks, it can be useful to compare the normal mode with a more capable or reasoning-focused mode if the tool offers one. Treat this as an experiment, not a guarantee of correctness.

If you are working on research-level problems, especially math, state your problem rigorously and clearly. Here is my template for difficult math problems:

```text
[Problem statement, with all notation defined and assumptions stated. Be as rigorous and precise as possible. If there are multiple parts, break them into separate steps.]

[State your prior knowledge and results you already know.]

[Pose your conjecture/question or series of conjectures/questions that build on each other.]

First verify my claims. Then work your way toward these questions.

Develop a strategy and workflow to do so. Then execute your approach. If you run into obstructions, explain the obstruction and come back to the drawing board. Decide whether to re-evaluate your current approach or try a different approach. As you try more things, develop a picture of what is going on. Continue until you arrive at a solution or a clear explanation of why the current path is blocked. Verify your solution rigorously.
```

Requesting that it first verify your claims provides useful exercises that can seed its context before it tackles the hard problem. This process may also trigger it to retrieve relevant information. It may find an alternative approach that you had not thought of, or it may identify a mistake in your reasoning.

Check the final work it produces. A good exercise is to break down the argument yourself and simplify it; you can do this interactively with the model. Do not rely on unsupported citations, unverified calculations, or plausible-sounding proofs without checking them.

## 2. Move from chat to agentic tools

The above approach is a good way to get a feel for language models, but it is only one way to use them. A common next step is an agentic tool. An agentic tool has a language model at its core, plus a harness: the program that gives the model tools, files, permissions, and a user interface. A harness can allow the model to:

- read and write files,
- run commands and read their output,
- fetch web pages when web access is available,
- and, in some tools, run subagents with separate context.

The interface is often a terminal user interface, or TUI. Integrated development environments, or IDEs, such as VSCode or Cursor let you interact with an agentic tool inside an editor.

To get started, I recommend installing [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) or [Codex](https://developers.openai.com/codex), depending on whether you have access to Anthropic or OpenAI. They are documented, general-purpose agentic tools and are good first tools to compare.

To try one out, identify a real project that may benefit from file and terminal access. A coding project is a good candidate, but these tools can also help with non-coding projects such as literature review, presentation planning, or grant design. The important difference from a chatbot is that an agentic tool can inspect project files, edit them, run commands, and maintain persistent notes across sessions when you ask it to.

Claude Code and Codex include `/init` commands for setting up persistent project instructions. For another tool, check whether it has an equivalent. From there, ask the tool to help you learn how to use it for your specific tasks. You can ask it to keep notes in a separate file about usage patterns you develop and things you learn as you go. Expect your productivity to be low at first; start with simple tasks and build trust gradually.

### Local examples versus beginner defaults

This repository contains local examples that are useful to study, but they are not required to get started.

- [`skills/README.md`](skills/README.md) explains the skill examples. `grill-me` and `checkpoint` are the most beginner-relevant examples; `web-discovery`, `orchestration`, and `tdd` are more advanced. Checkpoint writes daily notes and may create Git commits, so review that side effect before using it.
- [`hooks/README.md`](hooks/README.md) explains hook and extension examples for Claude Code, Codex, and Pi. A hook is a command or extension that the harness runs around a tool event, such as a proposed shell command. These hooks are advanced, opt-in accident guards. They are not security boundaries and should not be installed by blind copy-paste.
- The orchestration skill provides a portable task-and-handoff pattern for large work. Its `SETUP.md` describes how to choose a worker method for the user's harness. The included Pi/tmux watcher is one advanced implementation method for the Pi coding harness, not Raspberry Pi hardware and not a general subagent system. Claude Code and Codex have their own native subagent workflows.

Prefer agent-assisted installation and customization with human review. A good setup request is: "Inspect this README and my current tool config, then draft a small deployment plan and diff. Do not apply it until I review it." This is safer than blindly running an installer or copying a config snippet you do not understand.

### Permissions: a caution

Agentic tools usually ask you to approve certain actions, such as reading a file, editing a file, running a command, or using the network. Treat a permission prompt as a decision point, not as proof that the action is safe. Read what the tool is asking to do and check whether it matches the task.

Repeated prompts can create permission fatigue: after many prompts, people become more likely to choose the easy approval path. To reduce that risk, keep a short notes file with permission patterns you have approved and patterns you do not want to approve. You can then ask the agent to help draft better instructions, project rules, or guardrails based on those notes, but review the changes before enabling them.

Common ways to reduce prompt volume include:

- **Sandboxing and permission modes.** Start from the tool's normal permission and sandbox settings. [Claude Code permission modes](https://docs.anthropic.com/en/docs/claude-code/permission-modes) and [Codex approvals and security](https://developers.openai.com/codex/agent-approvals-security) document ways to control what the tool can do. Use the smallest access level that fits the task.
- **Auto permission review.** Claude Code documents an auto permission mode that uses a separate classifier model to reduce prompts and escalate riskier commands. It can add cost or latency, and it is not a guarantee of safety.
- **Advanced no-approval profiles.** Codex supports configuration choices such as `approval_policy = "never"` and `sandbox_mode = "danger-full-access"`, but this combination is a high-privilege profile for isolated environments, not a beginner default.
- **Hooks and local guards.** Hooks can add friction before risky commands, but they run as part of your local tool configuration and must be reviewed. The hooks in this repository are generic examples for advanced users. If your workflow has additional risky commands, ask an agent to draft guarded patterns and tests for those commands, then review the changes before enabling them.

### Misalignment

Here, misalignment means the agent is acting on a different interpretation of the task than the one you intended. Agentic tools can amplify this problem because they can modify files or run commands before the misunderstanding is obvious. When you encounter misalignment, debug with the agent and try to identify the misunderstanding.

I tend to find misalignment comes from two main issues:

1. **The agent lacks necessary context.** It may guess what you want rather than asking for clarification. To mitigate this, ask it to interview you before acting, or use a questioning workflow such as [`grill-me`](skills/grill-me/SKILL.md) for important tasks.
2. **The context buffer is too full or contains irrelevant information.** The context buffer is the text the model can see during a response. Long or irrelevant context can make tools perform worse, so keep the buffer relevant and concise. Consider:
   - tightening automatically loaded memory files such as [AGENTS.md](https://agents.md/) so they contain only information the model is unlikely to infer automatically;
   - keeping temporary notes in a separate folder the model is told not to read unless explicitly asked, which reduces context rot from stale notes;
   - using subagents for complex research and retrieval only when your tool supports them. [Claude Code](https://docs.anthropic.com/en/docs/claude-code/sub-agents) and [Codex](https://developers.openai.com/codex/subagents) document native subagents; the local [orchestration skill](skills/orchestration/SKILL.md) also shows a task-and-handoff pattern that can be adapted to other tools with review;
   - clearing the context buffer whenever you start a new task. If there is important context to keep, ask the agent to save it to a handoff file, then start a fresh session and load only that file.

## 3. Resources once you're going

1. [Markdown](https://www.markdownguide.org/basic-syntax/) — a simple formatting language that is widely used for writing notes and documentation. Most agentic tools use Markdown for instruction files, notes, or generated documentation.
2. **Skills** — reusable instruction bundles for agents. The [Agent Skills specification](https://agentskills.io/home) describes a shared `SKILL.md` format, and this repository's [skills README](skills/README.md) explains the local examples. See also [Skills Workshop](https://www.youtube.com/watch?v=pFsfax19yOM), [Obra Superpowers](https://github.com/obra/superpowers), and [Matt Pocock's Agent Tools Workshop](https://www.youtube.com/watch?v=-QFHIoCo-Ko). I have local versions of [`grill-me`](skills/grill-me/SKILL.md) and [`checkpoint`](skills/checkpoint/SKILL.md); checkpoint may write `daily-notes/` and commit to Git.
3. **Hooks and guardrails** — optional advanced examples for adding friction around risky commands. Start with [`hooks/README.md`](hooks/README.md), and do not install hooks or high-privilege profiles without reviewing what files and commands they change.
4. [Obsidian.md](https://obsidian.md/) — a note-taking app that can be used to build a wiki of your knowledge and notes. Agents work well with this kind of structure. If you let an agent manage a vault, keep some control files maintained by you rather than the agent.
5. [Git](https://git-scm.com/) — a version control system that tracks changes to files over time. It is useful for managing files that agents edit and for keeping an audit trail of agent work.

## Contact

Feel free to email me at [abhmul@gmail.com](mailto:abhmul@gmail.com) with any questions, or if you want to share your experience with these tools. I'm also interested in hearing about any interesting use cases you come up with, or any insights you have about how to use these tools effectively.
