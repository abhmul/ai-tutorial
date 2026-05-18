# AI Tools — One-Page Summary

A condensed version of the full guide (`ai-tools-guide.md`), for an audience with no prior AI experience.

## Three parts of any AI tool

- **Model** — the intelligence. Reasons over text; no memory between sessions; knowledge stops at a training cutoff.
- **Harness** — what lets the model act: read/write files, run commands and read output, fetch web pages, check its own work. This is what turns a chatbot into an agent.
- **Interface** — how you use it: terminal, code editor, app, or website; instructed in plain language.

The same model is weak or strong depending on its harness. Claude Code pairs a capable model with a broad harness.

## Core principle

An agent is reliable only as far as the check on its work reaches. Code can be tested, so the loop can converge — but only within what the tests cover. Citations and arguments have no automatic test; there you are the only check.

## Five uses, with the main caution

| Task | How to use it | Main caution |
|---|---|---|
| Literature review | Have it fetch and quote real papers; require resolvable DOIs | It invents references; check every DOI yourself |
| Coding | Let it plan, write, run tests, fix, open a pull request you review | Looks-right is not works; review before shipping |
| Presentation planning | Research, then a persistent outline file, then critique, then iterate | No test for a talk; you are the only check; voice must be yours |
| Grant design | Give it the funder's call; build a requirements checklist; co-draft | Confidently wrong; expert review required; do not upload confidential ideas |
| Critical thinking / Socratic | Tell it to argue against you; use an independent critic | It agrees with you, and invents objections that change when re-asked; sparring partner, not authority |

## References

Evidence for these claims: [references.md](./references.md).

## The same lens, every tool

- [ChatGPT](https://chatgpt.com/) — OpenAI model; chat-first harness; web/app interface.
- [Claude Code](https://code.claude.com/docs/en/overview) — Claude model; full agentic harness; terminal/editor interface.
- [OpenAI Codex CLI](https://developers.openai.com/codex/cli) — OpenAI model; agentic harness; terminal interface.
- [Cursor](https://cursor.com/) — configurable models; harness inside a code editor.
- [GitHub Copilot](https://github.com/features/copilot) — configurable models; embedded in existing coding tools.

## Learn more

- [Markdown basics](https://www.markdownguide.org/basic-syntax/)
- Videos: [a real workflow](https://www.youtube.com/watch?v=-QFHIoCo-Ko) and a [skills workshop](https://www.youtube.com/watch?v=pFsfax19yOM)

Core idea: AI is most reliable where reality can check it, least where only you can.
