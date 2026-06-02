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

Setup instructions for examples live in README files. Read the README before installing or adapting anything in these directories.

- [`skills/README.md`](./skills/README.md) — reusable agent skill examples. `grill-me` and `checkpoint` are the most beginner-relevant examples; `web-discovery`, `orchestration`, and `tdd` are more advanced. Checkpoint writes daily notes and may create Git commits, so review its side effects before use.
- [`hooks/README.md`](./hooks/README.md) — hook and extension examples for Claude Code, Codex, and Pi. These are advanced, opt-in accident guards and workflow examples, not security boundaries and not beginner defaults.

Prefer agent-assisted customization with human review over blind copy-paste: ask an agent to inspect the relevant README, compare it with your current tool configuration, and draft a small setup plan or diff for you to review.

## Contact

Feel free to email me at [abhmul@gmail.com](mailto:abhmul@gmail.com) with any questions, or if you want to share your experience with these tools. I'm also interested in hearing about any interesting use cases you come up with, or any insights you have about how to use these tools effectively.
