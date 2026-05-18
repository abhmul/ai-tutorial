# Understanding AI Tools — A Beginner's Guide

From an introductory talk on AI tools. It assumes no prior experience, gives you a way to reason about any AI tool using one — Claude Code — as the running example, and is explicit about where these tools are and are not reliable.

Sourcing: capability descriptions come from official documentation; cautionary claims from peer-reviewed or primary sources. Full citations are in [references.md](./references.md).

**Contents**

- [The three-part lens](#the-three-part-lens)
- [The core principle](#the-core-principle)
- [Five uses, with cautions](#five-uses-with-cautions)
- [Known limitations](#known-limitations)
- [References](#references)
- [The same lens, every tool](#the-same-lens-every-tool)
- [Next steps](#next-steps)

---

## The three-part lens

Any AI tool is built from three parts. Identifying all three lets you evaluate any of them.

**Model — the source of intelligence.** A model reasons over text. By itself it keeps no memory between sessions, takes no actions, and its knowledge stops at a fixed training cutoff date. Claude Code runs on the Claude model family, offered in tiers — a most-capable, a balanced, and a fast option — and you choose per task.

**Harness — how the model acts in the world.** The harness is the code around the model that lets it read and write your files, run commands and read their output, search and fetch web pages, delegate to helper "subagents," and follow instructions you define. Its central mechanism is a loop: act, observe the result, correct, repeat. That loop is the difference between a chatbot, which returns text and stops, and an agent, which can check and revise its own work. Claude Code asks permission before risky actions and has a read-only "plan mode."

**Interface — how you use it.** Claude Code runs in a terminal, and also in code editors (VS Code, JetBrains), a desktop app, and a website. You instruct it in plain language.

The practical consequence: the same model can be weak or strong depending on its harness. Claude Code pairs a capable model with a broad harness. The same lens applies to every tool in the last section.

---

## The core principle

> Where an external reality can check the work, the agent is reliable. Where only you can check it, its weaknesses matter most.

Code can be run and tested, so the act–observe–correct loop converges on something that works. A citation, a grant claim, or an argument has no automatic test; there you are the only check, and the failure modes below apply directly. Every use case is an instance of this principle.

---

## Five uses, with cautions

Each entry: a workflow, why it needs an agent rather than a chatbot, and the main caution.

### 1. Literature review

Workflow: state your question and scope; have it search and fetch real papers, read the actual pages, and write structured notes to a file; use subagents for subtopics in parallel; require every citation to list the source it retrieved, with a resolvable DOI.

Why an agent: a chatbot produces citations from memory and invents plausible ones; an agent can retrieve and quote the actual source and leave you an auditable file.

Caution: AI fabricates references at high rates. Require retrieval, check every DOI yourself, and cross-check in Google Scholar or PubMed. Retrieval reduces fabrication but does not remove it; human verification is required.

### 2. Coding

Workflow: have it read the codebase in plan mode (read-only); it proposes a plan you approve or edit; it implements, runs the tests, reads failures, and iterates until they pass; it opens a pull request for your review.

Why an agent: it runs the code and corrects itself against real errors, instead of returning code that only looks correct.

Caution: a plausible implementation can still mishandle edge cases — Anthropic's documentation calls this the trust-then-verify gap. If you cannot verify it, do not ship it. Keep permission prompts on; review before merging.

### 3. Presentation planning

Workflow: it researches the topic, writes an outline to a persistent file, drafts notes, runs a separate critique pass on the structure, and iterates, with version history in git.

Why an agent: the outline is a versioned file it can reopen and restructure across a session, not a chat transcript.

Caution: this is not a use case the vendor documents; it is general harness features applied to a non-coding task. There is no automatic test for a talk, so you are the only check: verify every researched fact, and keep the argument and voice your own. This guide was produced with this workflow and fact-checked as described.

### 4. Grant design and planning

Workflow: put the funder's call, your CV, and prior drafts in a project folder as persistent context; have it fetch the official guidelines and extract a requirements checklist; co-draft sections as editable files; use subagents to critique against the checklist and reviewer-style questions.

Why an agent: it works from the current call text rather than stale memory, and maintains a consistent multi-file draft.

Caution: fluent text can be wrong about feasibility or prior work; domain-expert review is required. Funder rules vary — verify against the official call, not the AI's summary. Do not put sensitive unpublished ideas into a cloud tool without checking your institution's policy and the tool's data-retention terms.

### 5. Critical thinking and the Socratic method

Workflow: write your claim to a file; instruct it to argue against you (strongest counterarguments, weakest link, no concession until you defend each point); make it push further and append the exchange so it accumulates; run an independent critic subagent on the argument cold; require cited evidence, which you judge.

Why an agent: it can fetch real evidence against your claim, keep the argument across sessions, and run independent critics with fresh context.

Caution: AI is sycophantic — it tends to agree with you, and human raters sometimes prefer a convincing wrong answer. It also confabulates: confident, invented objections that change when re-asked. Use it as a sparring partner, not an authority; re-ask challenges in a fresh subagent and discount objections that do not survive.

---

## Known limitations

Inherent to current AI, not imminent fixes:

- It can be wrong while sounding authoritative.
- Its knowledge stops at a training cutoff; recent changes may be unknown.
- It can invent citations, APIs, and even command output. Verify outputs that matter.
- It tends to agree with you, which undermines using it to check your own reasoning.
- It does not retain context between sessions unless you provide it.
- Cost scales with usage; long sessions and large projects cost more.
- Permission prompts are guardrails, not security. Do not auto-approve blindly.

Used where reality checks the work, these are manageable. Where only you can check, stay in the loop.

---

## References

Citations for the capability and cautionary claims: [references.md](./references.md).

---

## The same lens, every tool

These tools differ mainly in harness and interface, not in some hidden intelligence. Neutral category descriptions, not capability comparisons:

| Tool | In the three-part lens |
|---|---|
| [ChatGPT](https://chatgpt.com/) | OpenAI model; chat-first harness (agentic features newer/optional); web and app interface. |
| [Claude Code](https://code.claude.com/docs/en/overview) | Claude model; full agentic harness (files, shell, web, subagents); terminal/editor interface. |
| [OpenAI Codex CLI](https://developers.openai.com/codex/cli) | OpenAI model; agentic harness, same category as Claude Code; terminal interface. |
| [Cursor](https://cursor.com/) | Configurable models; harness integrated into a code editor; the editor is the interface. |
| [GitHub Copilot](https://github.com/features/copilot) | Configurable models; assistance embedded in existing coding tools and editors. |

---

## Next steps

1. Read the [overview and quickstart](https://code.claude.com/docs/en/overview) in the official docs; use the official install steps, not a second-hand command.
2. Learn basic [Markdown](https://www.markdownguide.org/basic-syntax/), the format these tools read and write.
3. See a [real workflow](https://www.youtube.com/watch?v=-QFHIoCo-Ko) and a [skills workshop](https://www.youtube.com/watch?v=pFsfax19yOM).
4. Start with a task that has a checkable answer, so you learn where the tool is reliable before relying on it where it is not.

---

The core idea: AI is most reliable where reality can check it, and least where only you can. Identify which case you are in.
