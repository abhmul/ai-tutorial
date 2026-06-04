# AI Tools: An Introduction

Materials from an introductory talk on AI tools. Start with the beginner-facing materials first; the skills, hooks, and orchestration files are examples of more advanced local workflows, not required setup for newcomers.

## The talk

- **Recording:** [Zoom recording](https://uic.zoom.us/rec/play/QSn5tiLq4kKBP9jIiT3mxbatB5VWo4V6d3f_xlrGPgA15APxY-pQJy7ZkRD-U8an50M3bP8tFUmIlUHV.PYPsa1FIZO5e3v4V?accessLevel=meeting&canPlayFromShare=true&from=share_recording_detail&continueMode=true&oldStyle=true&componentName=rec-play&originRequestUrl=https%3A%2F%2Fuic.zoom.us%2Frec%2Fshare%2FO03pIMMDnJ3pXvuNbhB5jIvA7zU5lCAKes8SZ36i6BAcM9bA2Dy_QWLdQfu-6KcE.pH_bCBSi-RgUmLEG) (hosted on UIC Zoom).
- **Notes:** [`ai-tutorial-meeting-notes.pdf`](./ai-tutorial-meeting-notes.pdf) — the handwritten notes used during the talk.

The talk reasons about AI tools by separating model, harness, and interface. It then covers how a model works on a context buffer of tokens, how an agent loop lets it act through tools, and what permission and safety questions follow.

## Start here

- [`recommendations.md`](./recommendations.md) — step-by-step suggestions for trying chat tools, then one agentic tool on a real project, while learning permissions and context management.
- [`ai-tools-onepager.md`](./ai-tools-onepager.md) — a short summary of the companion guide.
- [`ai-tools-guide.md`](./ai-tools-guide.md) — a longer AI-generated companion guide using Claude Code as the running example.
- [`references.md`](./references.md) — sources for factual claims in the guide, one-pager, and recommendations.

## Advanced local examples

Setup instructions for examples live outside `SKILL.md`, usually in README files or companion `SETUP.md` files. Read the README before installing or adapting anything in these directories.

- [`skills/README.md`](./skills/README.md) — reusable agent skill examples. `grill-me` and `checkpoint` are the most beginner-relevant examples; `web-discovery`, `orchestration`, and `tdd` are more advanced. Checkpoint writes daily notes and may create Git commits, so review its side effects before use.
- [`hooks/README.md`](./hooks/README.md) — hook and extension examples for Claude Code, Codex, and Pi. These are advanced, opt-in accident guards and workflow examples, not security boundaries and not beginner defaults.

Prefer agent-assisted customization with human review over blind copy-paste: ask an agent to inspect the relevant README, compare it with your current tool configuration, and draft a small setup plan or diff for you to review.

### Prompt for installing skills

Copy this prompt into the agent you want to use, replacing the bracketed parts:

```text
I want to install these skill examples from this repository: [skill names]. My harness is [Claude Code, Codex, Pi, or another tool], and I want the install to be [project-local or global].

Please inspect README.md, skills/README.md, each selected skill's SKILL.md, and any SETUP.md before making changes. Then check the official docs or my current local configuration for the correct skill location and format for my harness.

First draft a small install plan that lists the files to copy or link, config changes, commands to run, permissions or network access needed, API keys or accounts needed without secret values, and side effects such as commits, background workers, or web access. Do not run install commands, edit global config, enable paid/API backends, or start background workers until I approve.

After I approve, apply the smallest change needed. Then verify that the harness can discover the skill and run any safe smoke test described in SETUP.md. Report what changed, what I still need to do manually, and any limits of the setup.
```

## Tool documentation

Use the official docs for current setup details:

- [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code/overview): see also [permission modes](https://docs.anthropic.com/en/docs/claude-code/permission-modes), [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks), [subagents](https://docs.anthropic.com/en/docs/claude-code/sub-agents), and [skills](https://docs.anthropic.com/en/docs/claude-code/skills).
- [OpenAI Codex documentation](https://developers.openai.com/codex): see also [configuration](https://developers.openai.com/codex/config-advanced), [hooks](https://developers.openai.com/codex/hooks), [subagents](https://developers.openai.com/codex/subagents), and [skills](https://developers.openai.com/codex/skills).
- [Pi documentation](https://pi.dev/docs/latest/): see also [usage](https://pi.dev/docs/latest/usage), [settings](https://pi.dev/docs/latest/settings), [extensions](https://pi.dev/docs/latest/extensions), and [skills](https://pi.dev/docs/latest/skills).

## Contact

Feel free to email me at [abhmul@gmail.com](mailto:abhmul@gmail.com) with any questions, or if you want to share your experience with these tools. I'm also interested in hearing about any interesting use cases you come up with, or any insights you have about how to use these tools effectively.
