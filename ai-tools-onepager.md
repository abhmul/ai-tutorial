# AI Tools — One-Page Summary

A condensed version of the full guide (`ai-tools-guide.md`), for an audience with no prior AI experience.

## Three parts of any AI tool

- **Model** — the intelligence. Reasons over text; no memory between sessions; knowledge stops at a training cutoff.
- **Harness** — what lets the model act: read/write files, run commands and read output, fetch web pages, check its own work. This is what turns a chatbot into an agent.
- **Interface** — how you use it: terminal, code editor, app, or website; instructed in plain language.

The same model is weak or strong depending on its harness. Claude Code pairs a capable model with a broad harness.

## Core principle

Where reality can check the work, the agent is reliable. Where only you can check it, its weaknesses matter most. Code has tests; citations and arguments do not.

## Five uses, with the main caution

| Task | How to use it | Main caution |
|---|---|---|
| Literature review | Have it fetch and quote real papers; require resolvable DOIs | It invents references; check every DOI yourself |
| Coding | Let it plan, write, run tests, fix, open a PR you review | Looks-right is not works; review before shipping |
| Presentation planning | Research, then a persistent outline file, then critique, then iterate | No test for a talk; you are the only check; voice must be yours |
| Grant design | Give it the funder's call; build a requirements checklist; co-draft | Confidently wrong; expert review required; do not upload confidential ideas |
| Critical thinking / Socratic | Tell it to argue against you; use an independent critic | It tends to agree with you; sparring partner, not authority |

## Sources (independently verified)

- Capabilities/models/interfaces — Anthropic documentation: https://code.claude.com/docs/en/overview
- Citation fabrication — Walters & Wilder, *Scientific Reports* (2023): GPT-3.5 55%, GPT-4 18% fabricated. DOI: 10.1038/s41598-023-41032-5
- Sycophancy — Sharma et al. (2023), arXiv:2310.13548 (Anthropic)
- Confabulation — Farquhar et al. (2024), *Nature* 630:625–630. DOI: 10.1038/s41586-024-07421-0

## The same lens, every tool

- [ChatGPT](https://chatgpt.com/) — OpenAI model; chat-first harness; web/app interface.
- [Claude Code](https://code.claude.com/docs/en/overview) — Claude model; full agentic harness; terminal/editor interface.
- [OpenAI Codex CLI](https://developers.openai.com/codex/cli) — OpenAI model; agentic harness; terminal interface.
- [Cursor](https://cursor.com/) — configurable models; harness inside a code editor.
- [GitHub Copilot](https://github.com/features/copilot) — configurable models; embedded in existing coding tools.

## Learn more

- Markdown basics: https://www.markdownguide.org/basic-syntax/
- Videos: a real workflow https://www.youtube.com/watch?v=-QFHIoCo-Ko — skills workshop https://www.youtube.com/watch?v=pFsfax19yOM

Core idea: AI is most reliable where reality can check it, least where only you can.
