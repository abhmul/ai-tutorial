# T007 implementation planning handoff

## Status

Complete. I read the required project instructions, README, orchestration state, both generalization-review reports, and the relevant prior handoffs and target files needed for planning. I created follow-up task files T008 through T012. I did not implement repository content changes beyond these orchestration artifacts.

## Evidence and trust notes

- Directly read: `AGENTS.md`, `README.md`, `orchestration/state.json`, `reports/generalization-review.md`, `reports/generalization-review-presentation.html`, T002/T003/T004/T006 handoffs, `recommendations.md`, `hooks/README.md`, `hooks/codex/config.snippet.toml`, `hooks/codex/hooks.json`, `hooks/tests/test_codex_hooks.py`, and the main skill files for orchestration, web-discovery, checkpoint, TDD, and grill-me.
- `skills/README.md` does not currently exist. That is not a blocker; the user explicitly allows instructions for skills, hooks, and other files to live in README.md files, so T010 may create it if useful.
- Treat T002/T003/T004/T006 as useful but not sufficient for final edits. T008 is a fresh source/factual-claim verification task before implementation, and T012 is final independent verification after implementation.
- I did not read `tmp/`, `archive/`, `prompt-buffer.md`, or private shell configuration. I did not use Python.

## Current user decisions to carry forward

- Provide the tmux-based Pi orchestration skill, but frame it as one implementation method among many, not as a generic cross-harness subagent mechanism.
- Mention native subagent workflows where applicable, especially after T008 verifies the current Codex and Claude Code facts.
- State that agents can help adapt or port the orchestration skill/task pattern to a user's preferred tools; write this as an assistance option rather than a guaranteed automatic conversion.
- Allow setup instructions for skills, hooks, and related files to live in `README.md` files.
- Prefer agent-assisted installation/customization of skills, hooks, and other tools over one-click scripts or blind manual copy-paste. Keep human review explicit, especially for hooks and high-privilege profiles.
- Fix stale Codex configuration under `hooks/` and any copied or user-facing location that references it.

## Actionable recommendation summary by class

| Class | Items to implement | Primary target files | Dependency notes |
|---|---|---|---|
| Must-fix | Replace stale Codex config guidance: `codex_hooks` and `[profiles.auto]` are flagged stale by T003/T006 and must be re-verified by T008 before editing. If the `auto` profile remains, show it as advanced and separate from the base config. | `hooks/codex/config.snippet.toml`, likely new `hooks/codex/auto.config.snippet.toml`, `hooks/README.md`, `hooks/tests/test_codex_hooks.py`, any copied/user-facing Codex references discovered by T009/T011 | T008 must verify exact current Codex syntax first. T009 edits hook files and tests. |
| Must-fix | Stop presenting author-local hook deployment paths as portable setup. Existing `hooks/README.md` uses `~/Documents/vaults/agent-vault/...` copy/diff commands and author-local test paths. | `hooks/README.md` | T009 should replace with repo-relative or agent-assisted customization guidance, not one-click installer scripts. |
| Must-fix | Do not imply Pi/tmux worker dispatch is cross-harness. The skill currently tells orchestrators to use `pi-worker-watch.sh` directly. | `skills/orchestration/SKILL.md`, possibly `skills/README.md`, `recommendations.md` | T010 should put a portable task/handoff baseline first, then Pi/tmux, Codex subagents, and Claude Code subagents as separate options. |
| Must-fix | Label destructive hooks and auto-mode as advanced opt-in accident guards, not security boundaries or beginner defaults. | `hooks/README.md`, `recommendations.md` | T009 handles hook docs; T011 handles beginner-facing recommendations. |
| Must-fix if published | Fix TDD skill frontmatter pointing to missing artifacts. Since the skill is visible under `skills/`, either create the artifacts or remove stale artifact references. | `skills/tdd/SKILL.md` and optionally artifact files | T010 should choose the smallest coherent fix. |
| Should-explain | Explain Ketch or equivalent prerequisites for web-discovery, preserving the rule that search snippets are not evidence. | `skills/web-discovery/SKILL.md`, `skills/README.md`, `recommendations.md` | T008 verifies Ketch/backends if final docs mention them; T010 edits skill docs; T011 links or summarizes for newcomers. |
| Should-explain | Separate beginner path from advanced local infrastructure. | `README.md`, `recommendations.md`, `skills/README.md`, `hooks/README.md` | T009/T010 update advanced docs first; T011 updates top-level docs after links/targets exist. |
| Should-explain | Explain checkpoint side effects before recommending it: writes `daily-notes/` and may commit to Git. | `skills/checkpoint/SKILL.md`, `recommendations.md` | T010 edits skill; T011 adjusts public mention. |
| Should-explain | Explain author-local Python environment and portable alternatives if tests or helper commands are shown. | `hooks/README.md`, possibly `recommendations.md`, `references.md` | T009 updates hook testing docs; T011 adds references only if retained claims need them. |
| Should-explain | Prefer explicit commands over personal aliases; do not publish or require private shell configuration. | `recommendations.md`, `hooks/README.md` if aliases are mentioned | Existing recommendations do not show aliases, so T011 can simply avoid introducing them or label any examples optional. |
| Should-explain | Verify, cite, or soften volatile claims in `recommendations.md`: paid tiers/pricing, response-time ranges, `/init` availability, sandboxing and auto-mode behavior, context-size degradation, and permission-fatigue claims. | `recommendations.md`, `references.md` | T008 determines which claims are factual/citation-worthy; T011 edits. |
| Optional | Keep hooks, Obsidian guard, web-discovery, Pi/tmux worker watching, and local advanced skills as examples if framed as opt-in advanced material. | `hooks/README.md`, `skills/README.md`, skill files | Do not remove useful examples solely because they are advanced. |
| Optional | Add short harness-specific appendices or README sections for Pi, Codex, and Claude Code rather than forcing one generic workflow. | `skills/README.md`, `skills/orchestration/SKILL.md`, `recommendations.md` | Keep concise for newcomer audience. |
| No-change pending verification | Keep the high-level beginner sequence in `recommendations.md`: chat first, one agentic tool on a real project, permissions, context management. | `recommendations.md` | T011 should preserve this structure. |
| No-change pending verification | Keep web-discovery's research norm that search results are discovery artifacts, not evidence. | `skills/web-discovery/SKILL.md` | T010 should retain this principle. |
| No-change pending verification | Keep `hooks/codex/hooks.json` broad structure if T008/T009 final checks confirm it remains current. | `hooks/codex/hooks.json` | Do not edit unless verification finds exact output/event changes. |
| No-change | Keep `skills/orchestration/references/pi-worker-watch.sh` as an advanced Pi/tmux implementation detail unless documentation changes reveal a script bug. | `skills/orchestration/references/pi-worker-watch.sh` | T010 may read for documentation but should not remove it. |

## Likely files to edit

- `hooks/README.md`: portable/agent-assisted setup framing, prerequisites, opt-in warnings, Codex current config guidance, no author-vault copy commands as portable instructions, testing environment note.
- `hooks/codex/config.snippet.toml`: base Codex hook config with T008-verified current key.
- `hooks/codex/auto.config.snippet.toml`: likely new advanced profile snippet if T008 confirms separate profile files remain current.
- `hooks/tests/test_codex_hooks.py`: update stale assertions that currently expect `codex_hooks` and `[profiles.auto]`.
- `skills/README.md`: likely new README to frame beginner versus advanced skills and setup expectations.
- `skills/orchestration/SKILL.md`: portable baseline, native subagents where verified, Pi/tmux watcher as one advanced method, agent-assisted porting/adaptation.
- `skills/web-discovery/SKILL.md`: Ketch/equivalent setup requirements and backend caveats.
- `skills/checkpoint/SKILL.md`: upfront warning about daily notes and commits.
- `skills/tdd/SKILL.md`: remove or satisfy missing artifact references.
- `README.md`: distinguish beginner materials from advanced/local examples and reflect actual skills/hooks.
- `recommendations.md`: preserve beginner path; soften or source volatile claims; frame hooks/aliases/high-privilege profiles as advanced; mention agent-assisted setup and harness-specific delegation.
- `references.md`: update only if retained claims require official docs or primary/peer-reviewed cautionary support.
- `ai-tools-guide.md` and `ai-tools-onepager.md`: inspect only if edits or reference changes affect guide/one-pager synchronization.

## Facts requiring source verification before writing

- Exact Codex configuration and hook syntax: `features.hooks` versus deprecated keys, profile-file placement, `~/.codex/config.toml`, `~/.codex/<profile>.config.toml`, `hooks.json` locations/shapes, `approval_policy`, `sandbox_mode`, and risk guidance for full-access/no-approval operation.
- Codex subagents and Claude Code subagents/current agent-team status; Pi's current lack of built-in subagents and its relevant extension/settings/skills behavior.
- Ketch installation, commands, backend configuration, and which backends require API keys; Brave/Kagi only if recommended directly.
- Agent Skills format and installation locations if final docs make harness-specific skill claims.
- Python `venv`, uv, and pipx setup facts if portable environment instructions are retained.
- Obsidian CLI behavior if describing the Obsidian guard beyond local implementation details.
- Claude Code and Codex permission, sandbox, and auto-mode behavior if recommendations continue to make those claims.
- Paid tier/pricing, response-time ranges, model capability tier names, `/init` availability, and context-size performance degradation in `recommendations.md`; either source them, version/date-scope them, or soften/remove them.
- Permission fatigue or similar human-behavior cautions; if retained as a factual caution, add primary or peer-reviewed support in `references.md`, otherwise recast as personal workflow advice.

## Follow-up task queue

| ID | Dependency | Purpose | Expected handoff |
|---|---|---|---|
| T008 | T007 | Fresh source/factual-claim verification before implementation. Separates user preferences from factual claims and provides exact source-backed snippets/claims for later workers. | `orchestration/handoffs/T008-source-claim-verification.md` |
| T009 | T008 | Implement hook documentation, Codex config/snippet fixes, and Codex snippet tests. | `orchestration/handoffs/T009-hooks-codex-implementation.md` |
| T010 | T009 | Implement skill README/framing and portability fixes for orchestration, web-discovery, checkpoint, and TDD. | `orchestration/handoffs/T010-skills-implementation.md` |
| T011 | T010 | Implement top-level README, recommendations, and reference updates after hook/skill targets are ready. | `orchestration/handoffs/T011-docs-references-implementation.md` |
| T012 | T009, T010, T011 | Independent final verification of all implementation edits and factual/prompt-claim traceability; update state and create fix tasks if needed. | `orchestration/handoffs/T012-independent-final-verification.md` |

The queue intentionally serializes implementation tasks because they share user-facing framing and cross-link one another. T008 is separate from implementation so factual claims are checked before drafting; T012 is independent final verification and should not be run by any worker that produced T009, T010, or T011 edits.

## Validation performed

- Created task files: `T008-source-claim-verification.json`, `T009-hooks-codex-implementation.json`, `T010-skills-implementation.json`, `T011-docs-references-implementation.json`, and `T012-independent-final-verification.json`.
- Updated `orchestration/state.json` to mark T007 complete, add workstreams W6-W10, and queue T008-T012.
- No tests were run because this task only creates orchestration planning artifacts.
