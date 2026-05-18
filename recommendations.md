# Recommendations: Getting Started with AI Tools

Here are my recommendations to get started with basic AI tool usage and to understand the core principles of using these tools effectively and safely.

## Overview

This guide moves from chat-based use of language models, to agentic tools that act on your filesystem and terminal, to the permission and misalignment concerns that come with them, and finally to further resources. Expect your productivity to be low at first — these tools have a real learning curve.

- [Recommendations: Getting Started with AI Tools](#recommendations-getting-started-with-ai-tools)
  - [Overview](#overview)
  - [Quick start](#quick-start)
  - [1. Get a feel for language model capabilities](#1-get-a-feel-for-language-model-capabilities)
  - [2. Move from chat to agentic tools](#2-move-from-chat-to-agentic-tools)
    - [Permissions: a caution](#permissions-a-caution)
    - [Misalignment](#misalignment)
  - [3. Resources once you're going](#3-resources-once-youre-going)
  - [Contact](#contact)

## Quick start

A condensed version of the steps below; each links to the section that expands it.

1. **Try a chat model on real work.** Use [ChatGPT or Claude](#1-get-a-feel-for-language-model-capabilities) on something you are actually working on, and think about how to give it the relevant context.
2. **Gauge real capability with a more powerful tier.** Reasoning depth heavily affects output quality; temporarily subscribe to a more powerful version, and for research-level math use the most capable tier.
3. **Debug failures in a separate chat.** When it gets something wrong, open a separate chat with the prompt, the response, and what the problem was.
4. **Move to an agentic tool.** Install [Claude Code or Codex](#2-move-from-chat-to-agentic-tools) and run `/init` on a real project.
5. **Learn it deliberately.** Ask the tool to help you learn it, and keep a separate notes file of usage patterns.
6. **Never blind-approve permissions.** Review every [permission prompt](#permissions-a-caution); track what you approve, and reduce prompts with sandboxing or auto-mode.
7. **Manage context and misalignment.** When the agent misunderstands you, [debug with it](#misalignment) and keep its context buffer relevant and concise.

## 1. Get a feel for language model capabilities

Start with [ChatGPT](https://chatgpt.com/) or [Claude AI](https://claude.ai/) to get a feel for how language models can be useful in general, as well as their capabilities. The free version can be useful to familiarize yourself with the technology, but the basic paid versions (~$20/month) are more powerful and a better gauge of what these tools can do.

I recommend the following approach: when you are working on something, try to use ChatGPT or Claude to help with it. Consider how to give it the relevant context, then problem-solve when it doesn't get something right. A good technique is to use the model to help you debug the issue, since the issue may be arising from a misunderstanding embedded in the model's context.

Going through this process builds intuition for how to get better results from language models.

Keep in mind that the reasoning depth (e.g. ChatGPT Instant vs Thinking vs Pro) will heavily influence the quality of the output for most tasks. Getting the best sense of the capabilities of these tools will require temporarily subscribing to the more powerful versions. If you are working on research-level problems, in particular math, I recommend using the ChatGPT Pro version and stating your problem rigorously and clearly. You may find it is able to solve very difficult problems. Here is my template for difficult math problems:

```text
[Problem statement, with all notation defined and assumptions stated. Be as rigorous and precise as possible. If there are multiple parts, break them into separate steps.]

[State your prior knowledge and results you already know.]

[Pose your conjecture/question or series of conjectures/questions that build on each other.]

First verify my claims. Then work your way to solve these questions.

Develop a strategy and workflow to do so. Then execute your approach. If you run into obstructions come back to the drawing board. Decide whether to re-evaluate your current approach or try a completely new approach. As you try more things you will develop a picture of what is going on. Continue this process until you arrive at a solution. Verify your solution rigorously. Do not give up if things seem tough. You have the capability to obtain the novel results if you persevere relentlessly.
```

Requesting that it first verify your claims provides important exercises that can seed its context before it tackles the hard problem. This process may also trigger it to retrieve relevant information. It may find an alternative approach that you hadn't thought of, or it may identify a mistake in your reasoning.

It is important to check the final work it produces. A good exercise is to break down the argument yourself and simplify it; you can do this interactively with the model. Note that the ChatGPT Pro version can take ~15-30 minutes to respond, so for this interactive step you may want to use ChatGPT Thinking, which takes 1-5 minutes to respond.

## 2. Move from chat to agentic tools

The above approach is a good way to get a feel for the capabilities of language models, but it is only a limited way to use them. The primary way that language models are used in industry is through agentic tools. These tools have a language model at their core, but they also have a "harness" that allows the language model to interact with the world. This can include:

- reading and writing files,
- running commands and reading their output,
- fetching web pages,
- and even running sub-agents with fresh context.

The interface is typically a *terminal user interface* (TUI). *Integrated development environments* (IDEs) like VSCode or Cursor let you interact with the tool in a more natural way.

To get started, I recommend installing [Claude Code](https://code.claude.com/docs/en/overview) or [Codex](https://developers.openai.com/codex), depending on whether you have a subscription to Anthropic or OpenAI. They are good, general-purpose agentic tools that work well out of the box, with plenty of features to implement more complicated workflows.

To try them out, identify a project you are working on that may benefit from the capabilities of agentic tools. A coding project is a good candidate, but these can also be used for non-coding projects, such as literature review, presentation planning, or grant design. The important addition these tools provide over a chatbot is that they can interact with your filesystem and terminal, so they can automate a lot of tasks you would otherwise do manually. They can also use your filesystem to maintain persistent context across sessions, and naturally pull from relevant files without you having to tell them to.

Most tools provide an `/init` command that sets up the files they need in your project. From there, I recommend asking the tool to help you learn how to use it for your specific tasks. You can ask it to help you keep notes in a separate file about usage patterns you develop and things you learn about the tool as you go. **Expect your productivity to be quite low at first as you learn how to use these tools.** They can be surprisingly effective for basic tasks, but there is a learning curve to using them for more complex tasks.

### Permissions: a caution

Agentic tools typically have permission prompts that ask you to approve certain actions, such as reading a file or running a command. These are important guardrails, but they are not a security mechanism. Do not auto-approve these prompts without checking what they are asking for. If you do, you may end up with the tool doing something you didn't intend, such as deleting files or sending data to the internet. Always review the permissions it is asking for and make sure they align with what you want it to do.

A common issue users face is *permission fatigue* due to the large number of permission prompts. This can lead to users blindly approving permissions without checking them. To mitigate this, I recommend keeping a separate file with notes about the permissions you have approved and the patterns you have developed for when to approve certain permissions. You can then ask the agent to implement better guardrails based on these patterns.

Alternatively, you can use some of the features of agentic tools to reduce the number of permission prompts. Some common approaches include:

- *sandboxing* — running the tool in a sandboxed environment where it has limited access to your filesystem and terminal. Both Claude Code and Codex have features that allow you to do this.
- *auto-mode* — Claude Code has an auto-mode feature that uses a separate model to review permissions and escalate risky commands to you. This can reduce permission fatigue while still maintaining some level of safety. However, it does use some of your usage budget.

### Misalignment

In principle, since agentic tools have access to the terminal, they can be used to accomplish any task that can be done from a computer. In practice, however, they can amplify misalignment issues due to a lack of relevant context. This is an important caution to keep in mind. When you start encountering misalignment issues, I recommend trying to debug with the agent and figure out what the misunderstanding was. I tend to find misalignment comes from two main issues:

1. *The agent doesn't have the necessary context to understand what you want it to do.* Agents tend to be over-eager due to their training, so they may try to guess what you want rather than asking for clarification. To mitigate this, consider methods to get the agent to do a more careful interview of you to obtain the relevant missing context.
2. *The context buffer of the agent is too full, or full of irrelevant information.* Agents tend to have a drop in performance when their context buffer starts exceeding ~100-150k tokens. Ideally, you want to keep the context buffer as relevant and concise as possible. Consider:
   - tightening any automatically loaded memory files (e.g. [AGENTS.md](https://agents.md/)) and only keeping information the model may not be able to figure out automatically.
   - keeping temporary notes in a separate folder the model is told not to read unless explicitly asked to. This prevents *context rot*, where stale information is loaded by the model when it is building background context for a task.
   - encouraging the agent to use sub-agents for complex research and retrieval tasks. Sub-agents get their own context buffer and will surface only the relevant information and files to the main agent.
   - clearing the context buffer whenever you start a new task. If there is important context you want to keep, instruct the agent to save all relevant information to a file for a new agent, and then have the new agent load that file into its context.

## 3. Resources once you're going

1. [Markdown](https://www.markdownguide.org/basic-syntax/) — a simple formatting language that is widely used for writing notes and documentation. It is also the format that most agentic tools use for their files, so it is good to be familiar with it.
2. *Skills*: a standardized format for extending AI agent capabilities with specialized knowledge and workflows. They are essentially *programs* written in Markdown. The agent uses the description of the skill to decide when to execute the program; it can also be manually invoked. See:
   - [Skills Documentation](https://agentskills.io/home)
   - [Skills Workshop](https://www.youtube.com/watch?v=pFsfax19yOM)
   - [Obra Superpowers](https://github.com/obra/superpowers) — a collection of open-source skills to help agents work on complex coding and design tasks.
   - [Matt Pocock's Agent Tools Workshop](https://www.youtube.com/watch?v=-QFHIoCo-Ko) — he has a nice skill called `/grill-me` which attempts to solve the misalignment issue by relentlessly grilling the user until there is a shared "understanding" of the task. This can be effective but time-consuming, so I only recommend using it for important tasks where misalignment would be a major issue. I have my own version of this skill in [this repo](skills/grill-me/SKILL.md).
3. [Obsidian.md](https://obsidian.md/) — a powerful note-taking app that can be used to build a wiki of your knowledge and notes. Agents work well with this kind of structure, and you can even allow an agent to manage the wiki. I do recommend keeping some "control files" that are maintained by you and not the agent, to inject important context and guardrails.
4. [Git](https://git-scm.com/) — a version control system that allows you to track changes to files over time. It is a powerful tool for managing the files that agents work with, and it can also be used to keep an audit trail of the agent's work. Agents can then use the audit trail to understand the history of a project and make informed decisions about how to proceed. I personally use a [`/checkpoint`](skills/checkpoint/SKILL.md) skill that the model knows to execute so as to automatically commit changes and maintain a more detailed log of its work in a separate `daily-notes/` folder.

## Contact

Feel free to email me at [abhmul@gmail.com](mailto:abhmul@gmail.com) with any questions, or if you want to share your experience with these tools. I'm also interested in hearing about any interesting use cases you come up with, or any insights you have about how to use these tools effectively.
