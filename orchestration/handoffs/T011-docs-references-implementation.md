# T011 docs and references implementation handoff

## Status

Complete. I updated the beginner-facing top-level docs and references, then made small guide/one-pager consistency fixes discovered during synchronization checks. I relied on T008 for web/source verification and did not perform new web retrieval. I did not read `tmp/`, `archive/`, private shell configuration, or use Python. I did not update `orchestration/state.json`, matching the prior T009/T010 pattern.

## Changed files

- `README.md`: separated beginner-facing materials from advanced local examples; linked `skills/README.md`, `hooks/README.md`, and `reports/generalization-review.md`; stated that setup instructions may live in README files; framed agent-assisted customization with human review as preferred over blind copy-paste.
- `recommendations.md`: preserved the high-level path of chat tools → one agentic tool on a real project → permissions → context management; removed unsupported exact price/time/context-threshold claims; added local-vs-general framing; made hooks/high-privilege profiles advanced opt-in; added tool-specific `/init`, permission, auto-mode, and subagent language.
- `references.md`: expanded scope to cover `recommendations.md`; added current official docs for Claude Code, Codex, Pi, and Agent Skills claims; added NIST/Stanton et al. support for permission/security fatigue.
- `ai-tools-guide.md`: small consistency fixes only: made subagent use conditional on tool support and updated Claude Code overview links to the current Anthropic docs path.
- `ai-tools-onepager.md`: updated the Claude Code overview link to the current Anthropic docs path.
- `orchestration/handoffs/T011-docs-references-implementation.md`: this handoff.

## Source-backed claims used

- Claude Code and Codex document `/init` commands: T008 verified Claude Code memory/best-practices docs and Codex slash-command/best-practices docs on 2026-06-02.
- Claude Code and Codex permission/sandbox behavior, Claude Code auto permission review, and Codex high-privilege no-approval/full-access config concepts: T008 verified the respective official docs on 2026-06-02.
- Codex and Claude Code have native subagents; Pi/tmux worker dispatch is an advanced local implementation rather than native Pi subagents: T008 and T010 verified this from official docs and local skill reads.
- Agent Skills use a shared `SKILL.md` format and Codex/Claude Code/Pi each have harness-specific skill support: T008/T010 verified the linked official/spec docs.
- Long or irrelevant context can hurt agent performance in broad terms: T008 verified official Claude Code context-management docs; the unsupported `100-150k` threshold was not retained.
- Permission/security fatigue is supported by NIST's 2016 release and Stanton, Theofanos, Prettyman, and Furman (2016), DOI `10.1109/MITP.2016.84`, now listed in `references.md`.

## Claims softened or removed

- Removed exact cross-vendor paid-tier price language such as `~$20/month`; replaced with “check current official pricing.”
- Removed exact response-time ranges for ChatGPT modes because T008 found no official retrievable support.
- Softened “reasoning depth heavily affects output quality” into a recommendation to compare modes for hard tasks without guaranteeing correctness.
- Replaced “most tools provide `/init`” with the verified narrower claim that Claude Code and Codex document `/init`; other tools should be checked separately.
- Replaced the exact `~100-150k tokens` context-degradation threshold with broad context cleanliness guidance.
- Replaced generic subagent claims with tool-conditional language and named Claude Code/Codex where native subagents are verified.
- Reframed hooks, auto permission review, and Codex no-approval/full-access config as advanced aids or profiles, not security guarantees or beginner defaults.
- Removed motivational/hype wording from the difficult-math prompt template and made blocked paths an acceptable outcome.

## Guide and one-pager synchronization decision

I inspected `ai-tools-guide.md` and `ai-tools-onepager.md` after the recommendation edits because subagent and official-doc link claims overlapped with the updated text. I made only small consistency fixes: conditional subagent wording in the guide and current Claude Code docs links in both files. I did not otherwise rewrite the companion guide or one-pager.

## Validation

- `git -C /home/abhmul/Documents/ai-tools-intro diff --check -- README.md recommendations.md references.md ai-tools-guide.md ai-tools-onepager.md orchestration/handoffs/T011-docs-references-implementation.md` passed with no output.
- `rg` stale-claim check over `README.md`, `recommendations.md`, `references.md`, `ai-tools-guide.md`, and `ai-tools-onepager.md` found no remaining `$20`, `15-30`, `1-5`, `100-150k`, `Most tools`, deprecated Codex config strings, author-vault paths, agent-python paths, or old Claude Code overview URL.
- Targeted subagent grep confirmed remaining public-facing subagent language is either tool-conditional or tied to Claude Code/Codex/local orchestration framing.

## Notes for T012

- Historical reports and orchestration handoffs still contain stale strings as audit history; I did not edit them.
- Existing repository dirty state included T007-T010 changes and `orchestration/state.json` before T011. Review diffs by file rather than assuming all dirty files came from this task.
