# Generalization review: setup recommendations for newcomers

This report synthesizes the local audit in [T002](../orchestration/handoffs/T002-local-audit.md) and the freshness check in [T003](../orchestration/handoffs/T003-external-freshness.md). I did not independently re-verify the external sources; capability and configuration facts below rely on T003's 2026-06-02 retrievals. The practical conclusion is that the repository contains useful examples from the author's local agent setup, but several pieces should be clearly separated from the beginner path before they are presented as general-user instructions.

**Implementation status:** this is a historical review from before the T009-T012 implementation pass. The stale Codex examples and author-local setup issues described below were later addressed in the current [`hooks/README.md`](../hooks/README.md), [`hooks/codex/config.snippet.toml`](../hooks/codex/config.snippet.toml), [`hooks/codex/auto.config.snippet.toml`](../hooks/codex/auto.config.snippet.toml), [`skills/README.md`](../skills/README.md), and top-level setup documents. Treat remaining mentions of `codex_hooks`, `[profiles.auto]`, and author-local paths in this report as audit history, not current setup guidance.

## Executive recommendations

### Must-fix before using this as general setup guidance

- Update the Codex configuration example: [hooks/codex/config.snippet.toml](../hooks/codex/config.snippet.toml) uses stale profile placement and a deprecated feature key according to the current [Codex advanced configuration](https://developers.openai.com/codex/config-advanced) and [Codex hooks](https://developers.openai.com/codex/hooks) docs summarized in T003.
- Stop presenting author-local deployment commands as portable commands: [hooks/README.md](../hooks/README.md) copies from `~/Documents/vaults/agent-vault/...`, which will not exist for most readers.
- Do not imply that the orchestration worker script is cross-harness. The local [orchestration skill](../skills/orchestration/SKILL.md) dispatches Pi workers through `tmux`; Codex and Claude Code have different official subagent workflows.
- Label destructive hooks and auto-mode as advanced, opt-in accident guards, not security boundaries. T003 found official Codex and Claude Code docs that distinguish hooks, permissions, and sandboxing.

### Should-explain in newcomer-facing text

- Explain prerequisites for web discovery: Ketch or an equivalent search-plus-retrieval tool, configured search backends, and a habit of retrieving source text before citing claims.
- Explain the difference between a beginner path and advanced local infrastructure. The beginner path can remain: try chat tools, try one agentic tool on a real project, learn permissions, and keep context clean.
- Explain that the local `agent-python` path and shell aliases are author-machine conveniences, not requirements.
- Explain what the checkpoint skill changes before recommending it: it writes `daily-notes/` and may commit to Git.

### Optional material

- Keep the hooks, web-discovery, orchestration, and checkpoint files as advanced examples if they are framed as examples, not install-and-run defaults.
- Add short harness-specific appendices for Pi, Codex, and Claude Code rather than forcing one generic workflow.
- Offer a portable virtual environment recipe with Python `venv`, uv, or pipx, but only if the presentation needs setup details for Python-backed tools.

### No-change recommendations

- Keep the high-level structure of [recommendations.md](../recommendations.md): chat first, then agentic tools, then permissions and context management.
- Keep the web-discovery skill's research norm that search results are discovery artifacts, not evidence, because it is a useful newcomer-safe principle.
- Keep the local hook policy as a concrete example if the docs clearly state its limits and prerequisites.

## Focus item 1: Codex global config and profile guidance

**Verified external facts from T003.** Current Codex docs still use `~/.codex/config.toml`, `~/.codex/hooks.json`, approval policies, and sandbox modes. However, T003 reports that current [Codex advanced configuration](https://developers.openai.com/codex/config-advanced) docs no longer read `[profiles.<name>]` from `config.toml` in Codex 0.134.0+; profiles now live in separate `~/.codex/<profile-name>.config.toml` files. T003 also reports that [Codex hooks](https://developers.openai.com/codex/hooks) use `features.hooks`, while `codex_hooks` is deprecated. [Codex approvals and security](https://developers.openai.com/codex/agent-approvals-security) docs document `approval_policy = "never"` and `sandbox_mode = "danger-full-access"`, but describe full-access/no-approval operation as elevated risk and not a general default.

**Local observations.** The local [Codex config snippet](../hooks/codex/config.snippet.toml) currently says `codex_hooks = true` and defines `[profiles.auto]` with `approval_policy = "never"` and `sandbox_mode = "danger-full-access"`. [hooks/README.md](../hooks/README.md) tells readers to merge that snippet into `~/.codex/config.toml` and says the `auto` profile is intentionally unsandboxed and non-interactive. The local [Codex hooks file](../hooks/codex/hooks.json) uses `PreToolUse` for the destructive guard and `PermissionRequest` for auto-mode; T003 found that the broad event shape matches current docs.

**Recommendations.** Must-fix: replace or split [hooks/codex/config.snippet.toml](../hooks/codex/config.snippet.toml) so the base config uses `features.hooks`, and the `auto` profile is shown as a separate `~/.codex/auto.config.toml` example if it is kept. Must-fix: update [hooks/README.md](../hooks/README.md) so it does not instruct readers to merge stale profile syntax. Should-explain: present full-access/no-approval as an advanced convenience for isolated environments, not a default. Optional: mention newer Codex permission profiles only after exact syntax is verified for the target Codex version. No-change: the local `hooks.json` event names can likely remain as a working example, subject to final verification.

**Unresolved questions.** Decide whether the tutorial wants to support older Codex versions or only current Codex. T006 should verify exact final snippets before any implementation task lands them.

## Focus item 2: web-discovery and Ketch-equivalent prerequisites

**Verified external facts from T003.** T003 checked Ketch primary docs and found installation paths plus `ketch search`, `ketch scrape`, `ketch code`, and `ketch docs` commands. It also found Ketch backend configuration in `~/.config/ketch/config.json`, a default Brave backend with DDG/SearXNG alternatives, Context7 docs integration, and optional code-search backends. T003 checked [Brave Search API docs](https://api-dashboard.search.brave.com/app/documentation/web-search/get-started) only as a direct backend option, not as a requirement for all users. T003 also notes the [Agent Skills specification](https://agentskills.io/specification) supports compatibility fields for requirements such as tools or network access.

**Local observations.** The local [web-discovery skill](../skills/web-discovery/SKILL.md) says `compatibility: Requires ketch on PATH`, routes ordinary web/code/docs lookup through Ketch, and requires source retrieval before relying on claims. Current tutorial-facing files do not tell a newcomer how to install Ketch, configure a backend, or substitute an equivalent workflow.

**Recommendations.** Must-fix: do not present web-discovery as ready to run unless Ketch setup is documented or the skill is labeled local-only. Should-explain: give the functional contract in plain language: use one tool to find candidate sources, use another command to retrieve the actual source text, record URLs and access dates, and mark inaccessible pages as unresolved. Optional: provide Ketch-specific setup as one path and a Ketch-equivalent path for users who already have another search/retrieval tool. No-change: keep the skill's distinction between search snippets and evidence.

**Unresolved questions.** Choose which backend, if any, to recommend directly. If recommending Brave, add exact API-key setup and cite Brave docs; otherwise avoid making Brave a hard prerequisite.

## Focus item 3: orchestration and worker dispatch across Pi, Codex, and Claude Code

**Verified external facts from T003.** T003 reports that Pi docs say Pi intentionally lacks built-in subagents and suggests extensions, packages, or external tools such as tmux. T003 reports that [Codex subagents](https://developers.openai.com/codex/subagents) are available in Codex CLI/app and can be customized with TOML files. T003 reports that [Claude Code subagents](https://docs.anthropic.com/en/docs/claude-code/sub-agents) are official, while [Claude Code agent teams](https://docs.anthropic.com/en/docs/claude-code/agent-teams) are experimental and disabled by default.

**Local observations.** The local [orchestration skill](../skills/orchestration/SKILL.md) tells the orchestrator to run `.agents/skills/orchestration/references/pi-worker-watch.sh`, which starts `pi -p -t "read,grep,find,ls,edit,write,bash"` in detached `tmux`. T002 found this is Pi-specific, assumes `tmux`, and assumes `.agents` skill installation semantics.

**Recommendations.** Must-fix: describe the local worker watcher as a Pi/tmux example, not a cross-tool dispatch mechanism. Should-explain: give a harness-neutral baseline first: write a task file, start a fresh session or subagent with only the needed context, and require a handoff artifact. Then explain harness-specific options: Pi uses external processes or extensions; Codex has official subagents; Claude Code has subagents and experimental teams. Optional: keep the Pi watcher script in the repo for advanced users who install Pi and tmux. No-change: keep the flat task/handoff schema because it transfers well across harnesses.

**Unresolved questions.** Decide whether Pi should appear in the main presentation or only as an advanced appendix. For a newcomer audience, Codex and Claude Code may be enough for the main path.

## Focus item 4: destructive hooks, permission hooks, and Obsidian guard

**Verified external facts from T003.** T003 reports that [Codex hooks](https://developers.openai.com/codex/hooks) and [Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) broadly match the local hook event structure. T003 also reports that Codex docs call `PreToolUse` a guardrail rather than complete enforcement, and Claude docs distinguish permission rules from model instructions and sandboxing. T003 found that Pi [extensions](https://pi.dev/docs/latest/extensions) can intercept `tool_call` and `user_bash` and use `ctx.ui.confirm`, while Pi docs say Pi has no built-in permission popups. T003 also checked the [Obsidian CLI docs](https://obsidian.md/help/cli), which include destructive commands such as `delete`.

**Local observations.** [hooks/README.md](../hooks/README.md) documents a shared destructive-command policy for Claude, Codex, and Pi. T002 found `jq` is required for Claude/Codex hook input parsing; Claude blocks with an install message if `jq` is missing, while Codex fails closed through its deny path. The local auto-mode wrappers use a global toggle file and project opt-out files. The shared policy includes a 30-second explicit confirmation file for Obsidian delete-like commands, and the Pi extension can prompt interactively when UI is available.

**Recommendations.** Must-fix: state plainly that these hooks are local accident guards, not security boundaries. Must-fix: make installation opt-in and advanced; do not put full-access/no-approval profiles in the beginner path. Should-explain: prerequisites include Bash, `jq`, `python3` for the Obsidian classifier, harness-specific hook support, and Pi for the Pi extension. Should-explain: failure behavior, toggle files, project opt-out files, and the temporary Obsidian confirmation file. Optional: include the Obsidian guard as a focused example of adding friction before delete-like CLI commands. No-change: keep the shared destructive-policy design as a concrete local example if its limits are documented.

**Unresolved questions.** The current [recommendations.md](../recommendations.md) has permission-fatigue language. If that remains in final tutorial prose as a human-behavior caution, add a primary or peer-reviewed source to [references.md](../references.md), or soften it into a personal workflow recommendation.

## Focus item 5: agent-python-like environment setup

**Verified external facts from T003.** T003 checked Python [`venv`](https://docs.python.org/3/library/venv.html), uv [installation](https://docs.astral.sh/uv/getting-started/installation/) and [environment](https://docs.astral.sh/uv/pip/environments/) docs, and [pipx installation](https://pipx.pypa.io/stable/how-to/install-pipx/) docs. Those sources support isolated, reproducible environments rather than mutating system Python. T003 notes that venvs are disposable and should be reproducible from documented install commands or dependency files.

**Local observations.** [hooks/README.md](../hooks/README.md) tells the author to run tests using `UV_PROJECT_ENVIRONMENT=~/.local/share/agent-python/.venv uv run --project agent-python pytest hooks/tests`. T002 found local shell functions that prepend the same virtual environment to `PATH` before invoking Claude Code or Codex. This is an author-local tool environment, not something a newcomer will already have.

**Recommendations.** Must-fix: none unless the guide currently tells users they need the exact `~/.local/share/agent-python/.venv` path. Should-explain: if tests or helper scripts are shown, describe the author's path as an example and give a portable alternative such as `python -m venv .venv`, `uv venv`, or `pipx` for standalone command-line tools. Optional: add a short reproducibility note: do not commit `.venv`; record dependencies and install commands. No-change: keep the author's exact path in private/local deployment notes if it is explicitly labeled author-local.

**Unresolved questions.** The repo does not currently provide a general dependency file for recreating the author's shared environment. Add one only if a future task turns the hooks into a portable package.

## Focus item 6: shell aliases and harness command wrappers

**Verified external facts from T003.** T003 found official Pi docs for [shell aliases](https://pi.dev/docs/latest/shell-aliases): Pi runs non-interactive `bash -c`, so aliases require `shellCommandPrefix` or an equivalent explicit setup. T003 did not find an equivalent official cross-harness alias mechanism for Claude Code or Codex in this pass.

**Local observations.** T002 extracted only relevant shell functions from `~/.bash_aliases`: local `claude()` and `codex()` wrappers inject the author-local Python environment; `codex()` invokes the `auto` profile; `pi()` supplies default tools unless flags are present. These aliases silently change command behavior and, for Codex, couple command startup to the high-privilege auto profile.

**Recommendations.** Must-fix: do not tell users to source or copy the author's full shell config. Should-explain: prefer explicit commands in documentation; if aliases are shown, label them optional and explain exactly what each wrapper changes. Optional: include a Pi-specific note about `shellCommandPrefix` only if the tutorial includes Pi. No-change: continue avoiding unrelated shell configuration in public materials.

**Unresolved questions.** If the final guide wants alias examples for Claude Code or Codex, verify official recommended mechanisms or present them as ordinary shell functions, not harness-supported behavior.

## Draft general-user setup directions

These are draft directions for a later edit task; they should be adapted into [README.md](../README.md), [recommendations.md](../recommendations.md), or an advanced setup appendix.

### Web discovery setup

1. Decide whether you need web access. For many local editing tasks, local files are enough.
2. If you use the provided web-discovery skill, install Ketch or provide an equivalent pair of commands: one command that finds candidate sources and one command that retrieves source text. Ketch's documented commands include `ketch search`, `ketch scrape`, `ketch code`, and `ketch docs`.
3. Configure a search backend before relying on the skill. Ketch can use backends such as Brave, DDG, or SearXNG; only configure Brave directly if you have a Brave Search API token.
4. Treat search results as leads. Retrieve the page, inspect the source text, and record access dates for current product or API claims.
5. If a page is blocked, paywalled, browser-only, or empty after retrieval, mark the point unresolved rather than treating it as evidence.

### Orchestration setup

1. Use the portable baseline first: write a task file, give it to a fresh agent session or official subagent, and require a handoff file that records evidence, changes, blockers, and follow-up tasks.
2. For Pi, treat the included worker watcher as an advanced example that requires Pi and `tmux`; Pi itself does not provide built-in subagents.
3. For Codex, use Codex's official subagent workflow when you want delegated workers, and remember that subagents inherit the configured sandbox policy.
4. For Claude Code, use official subagents for specialized assistants; treat agent teams as experimental unless the user deliberately opts in.
5. Do not assume a task file written for one harness is enough to reproduce the same permissions, tools, or isolation in another harness.

### Destructive guard and auto-mode setup

1. Start with the harness's normal permissions and sandboxing. Do not begin with full-access/no-approval mode.
2. If you install the local hooks, do it as an explicit advanced step. Install the hook scripts and shared libraries together; deploying only one side leaves the hook broken.
3. Install prerequisites first: Bash, `jq`, and `python3` for the Obsidian classifier; Pi users also need the Pi extension path and reload behavior.
4. For Codex, update the snippet to current config syntax before use: enable hooks with `features.hooks` if shown, and put an `auto` profile in a separate `~/.codex/auto.config.toml` file if that profile is kept.
5. Treat the destructive guard as a friction layer. It can catch many obvious destructive commands, but it is not a complete security boundary and does not replace backups, sandboxing, or human review.
6. Document the opt-in controls: global auto-mode toggle files, per-project opt-out files, and the temporary Obsidian confirmation file for delete-like commands.

### Agent-python-like environment setup

1. Do not require the author's `~/.local/share/agent-python/.venv` path.
2. For a project-local Python environment, use `python -m venv .venv` or `uv venv`, then install documented dependencies.
3. For standalone Python command-line tools, consider pipx so each application gets an isolated environment.
4. Do not commit virtual environment directories. Commit dependency files or install instructions instead.
5. If showing hook tests, provide a command that works from this repository rather than from the author's vault path.

### Shell alias setup

1. Prefer explicit commands in beginner documentation.
2. If you provide aliases or shell functions, make them short, optional, and harness-specific.
3. Explain privilege-changing aliases in the alias itself or immediately next to it. For example, a Codex alias that selects an unsandboxed auto profile should be labeled advanced and high-privilege.
4. For Pi, use the documented `shellCommandPrefix` approach if aliases must be visible inside Pi-run shell commands.
5. Never ask readers to source a private `.bash_aliases` file wholesale.

## Later edit backlog

| Target path | Recommendation class | Rationale |
|---|---|---|
| `/home/abhmul/Documents/ai-tools-intro/README.md` | Should-explain | Add a short distinction between beginner materials and advanced local examples. The README currently says `recommendations.md` links to two example skills, but the repo contains additional advanced skills. |
| `/home/abhmul/Documents/ai-tools-intro/recommendations.md` | Must-fix / should-explain | Add the local-vs-general distinction; soften or verify paid-tier, response-time, `/init`, sandboxing, auto-mode, and context-size claims; avoid making advanced hooks/aliases sound like defaults. |
| `/home/abhmul/Documents/ai-tools-intro/references.md` | Should-explain | Add official docs for capability/config claims that remain in guide or one-pager. Add primary or peer-reviewed sources for human-behavior cautions such as permission fatigue if those claims remain. |
| `/home/abhmul/Documents/ai-tools-intro/hooks/README.md` | Must-fix | Replace author-vault copy commands with repo-relative examples or label them author-local; add prerequisites, opt-in warnings, and current Codex config syntax. |
| `/home/abhmul/Documents/ai-tools-intro/hooks/codex/config.snippet.toml` | Must-fix | Replace `codex_hooks` with `hooks` if the feature key is shown, and move `auto` profile settings out of `[profiles.auto]` into a separate profile config example. |
| `/home/abhmul/Documents/ai-tools-intro/hooks/codex/hooks.json` | No-change / final verify | Broad structure matches current docs per T003; keep but final-verify exact JSON output expectations when editing docs. |
| `/home/abhmul/Documents/ai-tools-intro/hooks/claude/settings.snippet.json` | No-change / should-explain | Broad structure matches current docs per T003; document settings scopes and that hooks complement permissions rather than replacing them. |
| `/home/abhmul/Documents/ai-tools-intro/skills/web-discovery/SKILL.md` | Should-explain | Add setup requirements for Ketch or mark the skill local-only; keep source-retrieval research contract. |
| `/home/abhmul/Documents/ai-tools-intro/skills/orchestration/SKILL.md` | Must-fix / should-explain | Mark worker dispatch as Pi/tmux-specific; add portable baseline and separate Codex/Claude Code guidance if this skill remains public. |
| `/home/abhmul/Documents/ai-tools-intro/skills/orchestration/references/pi-worker-watch.sh` | Optional | Keep as an advanced Pi implementation detail; do not make newcomers inspect or run it before they understand Pi and tmux. |
| `/home/abhmul/Documents/ai-tools-intro/skills/checkpoint/SKILL.md` | Should-explain | Add an upfront warning that the skill writes `daily-notes/` and may commit changes. |
| `/home/abhmul/Documents/ai-tools-intro/skills/tdd/SKILL.md` | Must-fix if published | T002 found missing artifact paths in frontmatter. Add the artifacts or remove the references. |

## Suggested presentation outline for T005

1. **What we reviewed.** Evidence: T002 local audit plus T003 freshness handoff; scope was setup portability, not model capability benchmarking.
2. **Main finding: examples are useful, but not drop-in setup.** Evidence: local paths in [hooks/README.md](../hooks/README.md), author-local aliases, and unframed advanced skills.
3. **Codex config needs a freshness fix.** Evidence: local [config snippet](../hooks/codex/config.snippet.toml) versus current Codex configuration and hooks docs summarized in T003.
4. **Web discovery needs prerequisites.** Evidence: [web-discovery skill](../skills/web-discovery/SKILL.md) requires Ketch; T003 Ketch docs confirm setup and backend requirements.
5. **Orchestration is harness-specific.** Evidence: Pi worker watcher in [orchestration skill](../skills/orchestration/SKILL.md); T003 Codex and Claude Code subagent docs.
6. **Hooks are opt-in friction, not security.** Evidence: local [hooks README](../hooks/README.md); T003 Codex hooks/security docs, Claude Code permissions/hooks docs, Pi extension docs, and Obsidian CLI docs.
7. **Portable setup means explicit commands, isolated environments, and minimal aliases.** Evidence: T003 Python venv/uv/pipx docs and Pi shell alias docs.
8. **Recommended next edits.** Evidence: later edit backlog above; split must-fix, should-explain, optional, and no-change items.

## Blockers and verification needs

No blocker prevents T005 from drafting the presentation. Before editing final guide text, T006 or a follow-up implementation task should verify exact Codex snippet syntax, decide whether Pi belongs in the main beginner presentation, and either cite or soften claims about permission fatigue and other human-behavior risks.