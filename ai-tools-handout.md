# Understanding AI Tools: A Beginner's Guide (featuring Claude Code)

This guide grew out of an introductory talk on AI tools. It assumes **no prior experience**. By the end you'll have a simple mental model for *any* AI tool, a clear-eyed sense of what these tools are good and bad at, and concrete starting points if you want to try one yourself.

A note on trust: every capability described here is drawn from official documentation, and every cautionary claim is backed by a peer-reviewed or primary source, cited at the bottom. We practice what we preach — *verify before you believe*.

**Contents**

- [The three-part lens](#the-three-part-lens)
- [The one principle to remember](#the-one-principle-to-remember)
- [Five ways to use it](#five-ways-to-use-it)
- [What to watch out for](#what-to-watch-out-for)
- [You don't have to take our word for it](#you-dont-have-to-take-our-word-for-it)
- [The same lens, every tool](#the-same-lens-every-tool)
- [Try it yourself](#try-it-yourself)
- [Take one thing home](#take-one-thing-home)

---

## The three-part lens

Every AI tool, no matter how it's marketed, is built from three parts. Learn to see all three and you can evaluate anything.

**1. Model — the source of intelligence.**
Picture an extraordinarily well-read expert who *just woke up with no memory of yesterday, no hands, and no internet*, and whose reading stopped on a fixed date (its "knowledge cutoff"). That's a model: pure reasoning, nothing else. By itself it remembers nothing between sessions and can take no action. Claude Code runs on the Claude family of models, in tiers — a most-capable one, a balanced one, and a fast/cheap one — and you can switch per task.

**2. Harness — how the model touches the world.**
The harness gives that "brain" hands, eyes, a workspace, and rules. For Claude Code that means: reading and writing your real files, running commands and *seeing the result*, searching the web and *actually reading the page*, spawning helper "subagents," and following reusable instructions you define. The defining mechanism is the **agentic loop**: *act → observe the result → correct → repeat.* This is the entire difference between a chatbot ("here's an answer, goodbye") and an agent ("let me try, check whether it worked, and fix it"). It asks your permission before risky actions, and a read-only "plan mode" lets it think before it touches anything.

**3. Interface — how you experience it.**
Where you actually meet the tool. Claude Code lives primarily in a **terminal**, and also in code editors (VS Code, JetBrains), a desktop app, and a website. You steer it in **plain English** — no special prompt language required.

> **The big idea:** the *same* model can be a toy or a power tool depending on the harness around it. **Claude Code = a strong model + a powerful harness.** Hold onto this; it's the key that unlocks every other AI tool too.

---

## The one principle to remember

> **Where reality can check the work, the agent is strong. Where *only you* can check it, its weaknesses bite hardest.**

Code can be run against tests — reality pushes back, and the agent's loop turns "looks plausible" into "demonstrably passes." A citation, a grant claim, or an argument has no test suite. There, *you* are the only feedback loop, and the AI's failure modes (inventing facts, agreeing with you) hit hardest. Every use case below is really just an application of this one idea.

---

## Five ways to use it

Each section gives a realistic workflow, why an *agent* beats a plain chatbot for it, and the single most important caution.

### 1. Literature review

**How:** Make a project folder and state your question and scope. Have it **web-search and *fetch* real papers**, read the actual pages, and write structured notes to a file. Use subagents to cover subtopics in parallel. Require every citation to be listed **with the source it actually retrieved** and a clickable DOI.

**Why an agent helps:** a chatbot generates citations from memory and invents plausible-looking ones; the harness can retrieve and quote the *real* source, and leave you an auditable file.

> ⚠️ **Caution — this is the big one.** AI fabricates references at high rates (see verified figures below). Force retrieval ("only cite papers you fetched"), **click every DOI yourself**, cross-check in Google Scholar or PubMed, and treat human verification as mandatory. Retrieval reduces fabrication; it does not eliminate it.

### 2. Coding (its strong suit)

**How:** Explore the codebase in **plan mode** (read-only). It writes a step-by-step plan you approve or edit. It implements, then **runs the tests, reads the failures, fixes, and re-runs** until they pass. Finally it opens a pull request for *you* to review.

**Why an agent helps:** the closed feedback loop. It doesn't just hand you code — it runs it and corrects itself. This is the cleanest example of the harness's power.

> ⚠️ **Caution.** Anthropic's own docs name the "trust-then-verify gap": a plausible-looking implementation that quietly mishandles edge cases. The rule: *if you can't verify it, don't ship it.* Keep permission prompts on, and always review before merging.

### 3. Presentation planning

**How:** It researches via the web, writes an outline to a **persistent file** (not disposable chat text), drafts speaker notes, runs a fresh critique pass on the structure, and iterates — with version history via git.

**Why an agent helps:** the outline is a real, versioned artifact it can reopen and restructure across a whole session, not a transcript you lose.

> ⚠️ **Caution — be honest about this one.** Presentation design is *not* a use case the vendor documents; it's standard harness features pointed at a non-coding task. There is **no test for a talk**, so you are the only feedback loop: every fetched fact must be verified, and the argument and voice must be *yours*. (This very guide is a live example of the workflow — and it was fact-checked exactly as advised.)

### 4. Grant design and planning

**How:** Put the funder's call text, your CV, and prior drafts in a project folder so the tool keeps them as persistent context. Have it **fetch the funder's official guidelines** and extract a requirements checklist to a file. Co-draft aims, significance, methods, timeline, and budget narrative as editable files. Use subagents to critique the draft against the checklist and against reviewer-style questions.

**Why an agent helps:** it works from the *actual current call text*, not stale memory, and holds a consistent multi-file proposal across a long session.

> ⚠️ **Caution.** Fluent text can be confidently wrong about feasibility or prior work — **domain-expert review is non-negotiable.** Funder rules vary; verify against the official call, not the AI's summary. And **do not paste sensitive unpublished ideas into a cloud tool** without checking your institution's data policy and the tool's retention terms.

### 5. Critical thinking and the Socratic method

**How:** Write your claim into a file. Assign an explicitly adversarial role: *"Do NOT agree with me. Give the strongest counterarguments and the weakest link. Don't concede until I've defended each point."* Defend, then make it push harder, appending the exchange so the dialogue compounds. Spawn an **independent critic subagent** that reviews the argument cold. Demand cited evidence — which *you* judge.

**Why an agent helps:** it can fetch real evidence to attack your claim, persist the argument so objections accumulate, and run independent critics with fresh context.

> ⚠️ **Caution — the deepest one.** AI systems are **sycophantic**: they tend to tell you what you want to hear, and human raters sometimes *prefer* a convincing wrong answer (verified below). They also **confabulate** — confidently inventing objections that change if you re-ask. Treat it as a sparring partner, not an oracle; re-ask challenges in a fresh subagent, and if an objection vanishes, it was made up.

---

## What to watch out for

Set your expectations correctly before you start. These are inherent to current AI, not bugs that will be patched away soon:

- **It can be confidently wrong.** Fluent and authoritative is *not* the same as correct.
- **Knowledge cutoff.** It won't reliably know about very recent libraries, events, or changes.
- **It can invent things** — citations, API methods, even fake command output. Verify outputs that matter.
- **It tends to agree with you (sycophancy).** This actively undermines using it to check your own thinking.
- **Memory is not automatic.** Each session starts fresh unless you deliberately give it project context.
- **Cost scales with use.** Long sessions and large projects consume more; keep an eye on usage.
- **Permission prompts are guardrails, not hard security.** Don't blindly auto-approve; a misled agent can still act wrongly.

None of this means "don't use it." It means: use it where reality can check the work, and stay in the loop where only you can.

---

## You don't have to take our word for it

These claims were independently fact-checked against primary sources:

- **Capabilities, models, and interfaces** — Anthropic's official documentation: <https://code.claude.com/docs/en/overview>
- **AI fabricates citations** — Walters, W. H., & Wilder, E. I. (2023), *Fabrication and errors in the bibliographic citations generated by ChatGPT*, **Scientific Reports** 13:14045. GPT‑3.5 fabricated **55%** of citations and GPT‑4 **18%**; among the *real* ones, 24–43% still contained errors. DOI: [10.1038/s41598-023-41032-5](https://doi.org/10.1038/s41598-023-41032-5)
- **AI tends to tell you what you want to hear (sycophancy)** — Sharma et al. (2023), *Towards Understanding Sycophancy in Language Models*, [arXiv:2310.13548](https://arxiv.org/abs/2310.13548) (Anthropic). Leading assistants consistently exhibit sycophancy; humans and preference models sometimes favor convincing-but-wrong answers.
- **AI can confidently make things up (confabulation)** — Farquhar et al. (2024), *Detecting hallucinations in large language models using semantic entropy*, **Nature** 630:625–630. DOI: [10.1038/s41586-024-07421-0](https://doi.org/10.1038/s41586-024-07421-0)

---

## The same lens, every tool

You'll hear many product names. They differ mostly in **harness** and **interface**, not in some secret intelligence. Run each through the three-part lens:

| Tool | Where it sits in the lens |
|---|---|
| **[ChatGPT](https://chatgpt.com/)** | OpenAI model; chat-first harness (agentic features are newer/optional); web-and-app interface. The familiar starting point. |
| **[Claude Code](https://code.claude.com/docs/en/overview)** | Claude model; full agentic harness (files, shell, web, subagents); terminal/editor interface. This guide's focus. |
| **[OpenAI Codex CLI](https://developers.openai.com/codex/cli)** | OpenAI model; agentic harness — *same category* as Claude Code; terminal interface. |
| **[Cursor](https://cursor.com/)** | Configurable models; harness integrated into a full code editor; the editor *is* the interface. |
| **[GitHub Copilot](https://github.com/features/copilot)** | Configurable models; assistance harness embedded in existing coding tools; lives inside your editor/IDE. |

(These are deliberately neutral category descriptions, not capability comparisons.)

---

## Try it yourself

A curious next step, not a commitment:

1. **Read the overview and quickstart** in the official docs: <https://code.claude.com/docs/en/overview>. Follow the official install steps there rather than any command you find second-hand.
2. **Learn a little Markdown** — the simple text format these tools read and write best: <https://www.markdownguide.org/basic-syntax/>
3. **Watch how someone actually works with it:** [a real workflow (Matt Pocock)](https://www.youtube.com/watch?v=-QFHIoCo-Ko) · [a skills workshop](https://www.youtube.com/watch?v=pFsfax19yOM)
4. **Start small and verifiable** — a task with a clear right answer (a script you can run, a fact you can check), so you learn where the tool is trustworthy before you rely on it where it isn't.

---

## Take one thing home

**AI is strongest where reality can check it, and most dangerous where only you can. Learn to tell which task you're in.**
