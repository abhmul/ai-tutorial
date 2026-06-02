# T008 source claim verification handoff

## Status

Complete. I read the required T008 task file, project instructions, orchestration state, T007 task/handoff, prior audit/freshness/verification handoffs, the generalization review, current recommendations/references, hook docs/snippets/tests, and the orchestration and web-discovery skill files. I also read README/guide/one-pager and selected read-if-needed setup files where they affected claim verification. I did not edit any repository file other than this handoff.

## Method and boundaries

Access date for web and local documentation checks: 2026-06-02. Retrieval used `ketch scrape`/`ketch search` for official or primary web sources and direct reads of the locally installed Pi documentation under `/home/abhmul/.local/lib/node_modules/@earendil-works/pi-coding-agent/`. Search snippets were used only to find source pages, not as evidence. I did not read `tmp/`, `archive/`, `prompt-buffer.md`, or private shell configuration. I did not use Python.

Retrieval limitations: OpenAI ChatGPT pricing/help pages returned HTTP 403 through Ketch, so exact ChatGPT plan prices and plan-tier details are not verified in this task. Response-time claims for ChatGPT reasoning tiers were not found in official retrievable sources. Exact context-degradation thresholds around `100-150k` tokens were not found; only broader official guidance that long/filled context can degrade performance was verified.

## Exact Codex setup guidance for T009

Use this as the source-backed Codex replacement guidance. The local `hooks/codex/config.snippet.toml` is stale because it uses `codex_hooks` and `[profiles.auto]`.

Base user config, if showing the hook feature key explicitly:

```toml
# ~/.codex/config.toml
[features]
hooks = true
```

Notes: current Codex docs say hooks are enabled by default, but if the feature key is shown, `hooks` is canonical and `codex_hooks` is only a deprecated alias. Keep project/user hook files separate from profile examples.

Advanced high-privilege profile example, only if retained with a clear warning:

```toml
# ~/.codex/auto.config.toml
approval_policy = "never"
sandbox_mode = "danger-full-access"
```

Notes: profile settings must be top-level keys in a separate `~/.codex/<profile-name>.config.toml` file. In Codex 0.134.0+, `--profile` no longer reads `[profiles.<name>]` tables in `~/.codex/config.toml`, and the top-level `profile = "..."` selector is unsupported. Use `codex --profile auto` or `codex exec --profile auto ...`; do not document `codex -p auto` unless a later worker verifies that shorthand from current CLI docs. Full-access/no-approval operation is elevated risk and not recommended as a general default.

Current `hooks/codex/hooks.json` shape is broadly approved for user-facing use as an example, subject to T009 test updates:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$HOME/.codex/hooks/destructive-guard.sh\"",
            "statusMessage": "Checking command policy"
          }
        ]
      }
    ],
    "PermissionRequest": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$HOME/.codex/hooks/auto-mode.sh\"",
            "statusMessage": "Checking auto approval"
          }
        ]
      }
    ]
  }
}
```

Codex hook output requirements approved for local scripts/tests: `PreToolUse` may deny with `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}`; `PermissionRequest` may allow with `{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}` or deny with `decision.behavior = "deny"` plus a message. Plain `stdout` is ignored. No matching decision uses normal approval flow. `PermissionRequest` must not return `updatedInput`, `updatedPermissions`, or `interrupt` because those fail closed today.

Do not present hook trust or the destructive guard as security. Current Codex docs say non-managed command hooks must be reviewed/trusted through `/hooks`, matching hooks can run concurrently, and `PreToolUse` is a guardrail rather than complete enforcement.

## Claim table

| Claim | Verdict | Source URL or primary source | Access date | Implementation consequence | `references.md` consequence |
|---|---|---|---|---|---|
| Codex local state/config defaults to `CODEX_HOME`, usually `~/.codex`; user config is `~/.codex/config.toml`; hooks can live in `~/.codex/hooks.json`, `~/.codex/config.toml`, repo `.codex/hooks.json`, or repo `.codex/config.toml`. | Approved | https://developers.openai.com/codex/config-advanced and https://developers.openai.com/codex/hooks | 2026-06-02 | T009 may write portable setup around these paths. Mention project `.codex/` layers load only in trusted projects. | Add Codex config/hooks docs if final user-facing files retain Codex setup paths. |
| Codex profiles are separate `~/.codex/<profile>.config.toml` files with top-level keys; Codex 0.134.0+ no longer reads `[profiles.<name>]` from `config.toml`. | Approved | https://developers.openai.com/codex/config-advanced and https://developers.openai.com/codex/config-basic | 2026-06-02 | Replace `[profiles.auto]` in `hooks/codex/config.snippet.toml`; create a separate advanced profile snippet if keeping `auto`. | Add Codex advanced config doc if profile guidance appears in final docs. |
| Codex canonical hook feature key is `features.hooks`; `codex_hooks` remains only a deprecated alias. | Approved | https://developers.openai.com/codex/hooks | 2026-06-02 | Replace `codex_hooks = true` with `hooks = true` under `[features]`, or omit because hooks are enabled by default. | Add Codex hooks doc if retained. |
| Codex `PreToolUse` and `PermissionRequest` event names, matchers, command hook shape, `statusMessage`, and JSON outputs match the local `hooks.json` and scripts in broad structure. | Approved | https://developers.openai.com/codex/hooks | 2026-06-02 | Keep `hooks/codex/hooks.json` structure unless T009 finds local test/script-specific issues. Update tests to expect `features.hooks`, not `codex_hooks`. | Add Codex hooks doc if hook examples are user-facing. |
| Codex `PreToolUse` is not a complete enforcement boundary; non-managed command hooks require trust review via `/hooks`. | Approved | https://developers.openai.com/codex/hooks | 2026-06-02 | Describe destructive guard as an accident guard/friction layer, not security. Include hook trust review as a setup step. | Add Codex hooks/security docs if caution remains. |
| Codex `approval_policy = "never"` and `sandbox_mode = "danger-full-access"` are valid config concepts, but full-access/no-approval operation is elevated risk and not recommended as a default. | Approved with strong warning | https://developers.openai.com/codex/agent-approvals-security and https://developers.openai.com/codex/config-advanced | 2026-06-02 | Keep only as an advanced opt-in profile for isolated environments. Beginner docs should start from normal sandbox/approval modes. | Add Codex approvals/security doc if retained. |
| Codex permission profiles exist with built-ins `:read-only`, `:workspace`, `:danger-full-access`, but are beta and do not compose with older `sandbox_mode` settings. | Approved but optional | https://developers.openai.com/codex/permissions | 2026-06-02 | Do not introduce permission profiles in T009 unless needed. If mentioned, label beta and say not to mix with `sandbox_mode` examples. | Add Codex permissions doc only if retained. |
| Codex has native subagent workflows in current CLI/app releases, enabled by default and only spawned when explicitly requested; built-ins include `default`, `worker`, and `explorer`; custom agents are TOML files under `~/.codex/agents/` or `.codex/agents/`; subagents inherit sandbox policy. | Approved | https://developers.openai.com/codex/subagents | 2026-06-02 | T010/T011 may state Codex has native subagents, but should not imply they are the same as the Pi/tmux worker watcher. | Add Codex subagents doc if final docs mention Codex delegation. |
| Codex supports Agent Skills in CLI/IDE/app; skills can live in repo `.agents/skills` and user `$HOME/.agents/skills`; skill format uses `SKILL.md`. | Approved | https://developers.openai.com/codex/skills and https://agentskills.io/specification | 2026-06-02 | If skill portability is discussed, use the shared Agent Skills standard and harness-specific locations. | Add Codex skills and Agent Skills spec if retained. |
| Claude Code hooks/settings use JSON settings with user `~/.claude/settings.json`, project `.claude/settings.json`, and local `.claude/settings.local.json`; hooks and permissions reload during a session. | Approved | https://docs.anthropic.com/en/docs/claude-code/hooks and https://docs.anthropic.com/en/docs/claude-code/settings | 2026-06-02 | T009 may keep Claude hook settings as a supported example, with scope and reload caveats. | Existing references cite Claude docs broadly; add hooks/settings pages if final docs include exact snippets. |
| Claude Code permission modes include `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, and `bypassPermissions`; auto mode uses a separate classifier model, is a research preview, does not guarantee safety, and adds usage/cost/latency; bypassPermissions should be used only in isolated environments. | Approved | https://docs.anthropic.com/en/docs/claude-code/permission-modes and https://docs.anthropic.com/en/docs/claude-code/settings | 2026-06-02 | Replace vague “auto-mode is safe” language with exact behavior: reduces prompts through classifier checks, not a security guarantee. | Add Claude permission-modes doc if retained; no peer-reviewed citation needed for vendor feature behavior. |
| Claude Code has native subagents with separate context windows, custom prompts, tool access, and independent permissions; user subagents live in `~/.claude/agents/` and project subagents in `.claude/agents/`. | Approved | https://docs.anthropic.com/en/docs/claude-code/sub-agents | 2026-06-02 | T010/T011 may state Claude Code has native subagents. Use “subagents,” not generic “workers,” unless explaining the difference. | Add Claude subagents doc if retained. |
| Claude Code agent teams are experimental and disabled by default; they differ from subagents and can use tmux/iTerm2 split panes with overhead and limitations. | Approved | https://docs.anthropic.com/en/docs/claude-code/agent-teams | 2026-06-02 | Mention agent teams only as experimental advanced material, not as beginner default. | Add Claude agent-teams doc only if retained. |
| Claude Code skills follow Agent Skills, can live in `~/.claude/skills/<skill>/SKILL.md` or `.claude/skills/<skill>/SKILL.md`, and can be invoked as slash commands. | Approved | https://docs.anthropic.com/en/docs/claude-code/skills and https://agentskills.io/specification | 2026-06-02 | Skill README can explain cross-harness skill portability with concrete per-harness locations. | Add Claude skills and Agent Skills spec if retained. |
| Pi intentionally lacks built-in subagents, permission popups, plan mode, to-dos, MCP, and background bash; users can build/install workflows with extensions/packages or use external tools such as containers and tmux. | Approved | https://pi.dev/docs/latest/usage and local `/home/abhmul/.local/lib/node_modules/@earendil-works/pi-coding-agent/README.md` | 2026-06-02 | T010 must frame `pi-worker-watch.sh` as a Pi/tmux example, not native Pi behavior and not cross-harness. | Add Pi usage/README reference if Pi is discussed in final docs. |
| Pi extensions can intercept `tool_call` and `user_bash`, block or mutate tool calls, and prompt via `ctx.ui.confirm`; extensions auto-discover under `~/.pi/agent/extensions/` and `.pi/extensions/`. | Approved | https://pi.dev/docs/latest/extensions and local `docs/extensions.md` | 2026-06-02 | Pi destructive guard is plausible as a custom extension. State extensions run with user permissions and require trust. | Add Pi extensions doc if retained. |
| Pi settings live in `~/.pi/agent/settings.json` globally and `.pi/settings.json` for projects; `shellCommandPrefix`, `extensions`, `skills`, `packages`, and `enableSkillCommands` are documented settings. | Approved | https://pi.dev/docs/latest/settings and local `docs/settings.md` | 2026-06-02 | Pi-specific setup may mention these paths; keep it in Pi appendix/advanced section. | Add Pi settings doc if retained. |
| Pi skills load from `~/.pi/agent/skills/`, `~/.agents/skills/`, `.pi/skills/`, and project `.agents/skills/`; `/skill:name` is supported. | Approved | https://pi.dev/docs/latest/skills and local `docs/skills.md` | 2026-06-02 | Skill portability docs may mention these locations. | Add Pi skills doc if retained. |
| Pi shell aliases require `shellCommandPrefix` or equivalent because Pi runs non-interactive `bash -c`; this does not generalize to Claude Code or Codex without separate evidence. | Approved for Pi only | https://pi.dev/docs/latest/shell-aliases and local `docs/shell-aliases.md` | 2026-06-02 | Do not publish cross-harness alias claims. Prefer explicit commands. | Add Pi shell-aliases doc only if Pi alias setup is retained. |
| Pi works in tmux but modified keys may require `extended-keys on` and `extended-keys-format csi-u`; tmux 3.2+ and a terminal with extended keys are requirements for that fix. | Approved | https://pi.dev/docs/latest/tmux and local `docs/tmux.md` | 2026-06-02 | If the Pi/tmux worker watcher is documented, list tmux as an advanced prerequisite and avoid implying the tutorial depends on it. | Add Pi tmux doc only if retained. |
| The local Pi subagent example is an extension that spawns separate `pi` processes, with user/project agent scopes and project-agent trust prompts. | Approved as example, not built-in | local `/home/abhmul/.local/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/README.md` and `index.ts` | 2026-06-02 | If saying “Pi can be extended to spawn subagents,” cite as extension/example. Do not say Pi has native subagents. | Add no public URL unless final docs cite examples; otherwise cite Pi extensions/usage. |
| Ketch install paths include Homebrew, `go install github.com/1broseidon/ketch@latest`, and GitHub releases; core commands include `ketch search`, `search --scrape`, `scrape`, `code`, `docs`, `crawl`, and `config`; defaults/config live in `~/.config/ketch/config.json`. | Approved | https://github.com/1broseidon/ketch | 2026-06-02 | T010 may add Ketch setup instructions or a “Ketch-equivalent search+retrieve” contract. | Add Ketch GitHub source if web-discovery setup is user-facing. |
| Ketch backend requirements: `brave` default needs a Brave Search API key; `ddg` is zero-config but rate-limited; `searxng` needs a self-hosted URL; `grepapp` and `sourcegraph` code backends are zero-config; GitHub code backend needs `gh auth login`, configured token, or env token; Context7 docs backend needs `context7_api_key`; browser rendering needs Chrome or `ketch browser install`. | Approved | https://github.com/1broseidon/ketch and Brave token example at https://api-dashboard.search.brave.com/app/documentation/web-search/get-started | 2026-06-02 | Do not make Brave/Kagi a universal prerequisite. If recommending Ketch directly, explain default Brave key or alternate backend setup. | Add Ketch; add Brave only if Brave is recommended directly. Do not add Kagi unless mentioned. |
| Web-discovery principle “search snippets are discovery, not evidence; retrieve source text before relying” is source-methodologically sound and consistent with task requirements, but it is a local skill norm rather than a vendor fact. | Approved as workflow advice | local `skills/web-discovery/SKILL.md` plus T008 retrieval practice | 2026-06-02 | Keep as research rule. No external citation needed unless final docs present it as a study-backed claim. | No reference needed unless formalized as cautionary research claim. |
| Python `venv` creates lightweight isolated environments, conventionally `.venv`/`venv`; venvs should not be checked into source control, are disposable, and are not movable/copyable; command is `python -m venv /path/to/env`. | Approved | https://docs.python.org/3/library/venv.html | 2026-06-02 | Replace author-local `~/.local/share/agent-python/.venv` as a requirement with portable venv setup. | Add Python `venv` doc if setup instructions are retained. |
| uv can be installed by standalone installer or package managers; uv recommends `pipx install uv` for PyPI installs; `uv venv` creates `.venv`, and uv requires a virtual environment by default for environment-mutating operations. | Approved | https://docs.astral.sh/uv/getting-started/installation/ and https://docs.astral.sh/uv/pip/environments/ | 2026-06-02 | T009/T011 may give uv as an optional portable path, not as required. | Add uv docs only if retained. |
| pipx requires Python 3.10+ to install, works on macOS/Linux/Windows, and `pipx ensurepath` adds the binary directory to PATH; PEP 668 Linux distributions should prefer distro packages or a self-contained venv. | Approved | https://pipx.pypa.io/stable/how-to/install-pipx/ | 2026-06-02 | T011 may recommend pipx for standalone Python CLI tools. | Add pipx docs only if retained. |
| Obsidian CLI must be enabled in the Obsidian app; commands include `create`, `append`, `move`, `rename`, and `delete`; `delete` trashes by default and has `permanent`; move/rename update internal links only if vault settings enable that behavior. | Approved | https://obsidian.md/help/cli | 2026-06-02 | Hook docs may describe the Obsidian guard as a conservative custom confirmation for delete-like commands, not comprehensive Obsidian safety. | Add Obsidian CLI doc if retained. |
| Claude Code and Codex both have `/init` commands for scaffolding persistent instruction files; saying “most tools provide `/init`” is broader than verified. | Partially approved | Claude: https://docs.anthropic.com/en/docs/claude-code/memory and https://docs.anthropic.com/en/docs/claude-code/best-practices; Codex: https://developers.openai.com/codex/cli/slash-commands and https://developers.openai.com/codex/learn/best-practices | 2026-06-02 | Change to “Claude Code and Codex include `/init` commands...” or “check your tool’s docs for the equivalent.” | Add Claude memory/best-practices and Codex slash-command docs if retained. |
| Exact paid tier/pricing claim in `recommendations.md` that basic paid versions are about `$20/month`; Claude Pro price at `$20` monthly was verified, but OpenAI ChatGPT pricing pages were not retrievable. | Partially verified; volatile | Claude pricing: https://claude.com/pricing. OpenAI pricing/help pages attempted but returned HTTP 403: https://openai.com/chatgpt/pricing/, https://chatgpt.com/pricing, and OpenAI Help pages. | 2026-06-02 | Do not keep exact cross-vendor pricing as a sourced fact from this task. Prefer “paid plans change; check the official pricing page” or date-scope and cite each accessible vendor separately. | If exact prices remain, add current official pricing references after retrieval; otherwise no exact-price reference. |
| Specific response time ranges in `recommendations.md` such as ChatGPT Pro taking `15-30 minutes` and Thinking taking `1-5 minutes`. | Unsupported as factual claim | No official retrievable source found in this task. | 2026-06-02 | Remove exact times or phrase as personal anecdote/expectation, not a general fact. | Do not add reference unless a primary source is found. |
| Claim that reasoning depth/model tier strongly affects output quality and that higher tiers are useful for difficult math/research. | Preference/workflow advice, not independently quantified here | Claude/OpenAI docs document tiers/effort/modes, but this task did not verify comparative quality claims. | 2026-06-02 | Keep only as author recommendation with neutral wording; avoid hard factual claims such as “requires” or “will solve.” | No reference unless final text makes measurable capability claims. |
| Agentic tools can use subagents for complex research/retrieval, giving workers separate context buffers. | Approved for Claude Code and Codex; not for Pi built-in | Codex subagents: https://developers.openai.com/codex/subagents; Claude subagents: https://docs.anthropic.com/en/docs/claude-code/sub-agents; Pi usage: https://pi.dev/docs/latest/usage | 2026-06-02 | Write harness-specific text. Do not imply every agentic tool has native subagents. | Add Codex/Claude/Pi docs if retained. |
| Long/irrelevant context can reduce performance; exact degradation threshold around `100-150k` tokens. | Broad claim approved; exact threshold unsupported | https://docs.anthropic.com/en/docs/claude-code/best-practices and https://docs.anthropic.com/en/docs/claude-code/context-window | 2026-06-02 | Replace `~100-150k` threshold with “as the context window fills” unless a source is found. | Add Claude best-practices/context docs for broad context-management claim; do not cite threshold. |
| Permission fatigue/security fatigue can lead users to avoid decisions, choose easiest options, or fail to follow security rules. | Approved if phrased as security/decision fatigue, not necessarily AI-agent-specific | NIST primary release: https://www.nist.gov/news-events/news/2016/10/security-fatigue-can-cause-computer-users-feel-hopeless-and-act-recklessly; paper DOI: https://doi.org/10.1109/MITP.2016.84 | 2026-06-02 | If `permission fatigue` remains as a caution, cite NIST/Stanton et al. or soften to “many users find repeated prompts tiring.” | Add Stanton, Theofanos, Prettyman, and Furman (2016), *Security Fatigue*, DOI `10.1109/MITP.2016.84`, if retained. |
| “Hooks are guardrails, not security mechanisms” for Claude/Codex. | Approved | Codex hooks/security docs: https://developers.openai.com/codex/hooks and https://developers.openai.com/codex/agent-approvals-security; Claude permissions/hooks: https://docs.anthropic.com/en/docs/claude-code/permissions, https://docs.anthropic.com/en/docs/claude-code/permission-modes, https://docs.anthropic.com/en/docs/claude-code/hooks | 2026-06-02 | Keep. Be precise: hooks/permissions/sandboxing are separate layers and none replaces human review/backups/isolation. | Add vendor docs if retained. |
| Agent-led installation/customization of skills/hooks/tools is preferred over scripts/manual copy-paste. | User preference, not external fact | User/T007 decision, not sourced externally | 2026-06-02 | Present as “this tutorial prefers agent-assisted setup with human review,” not as a universal best practice. | No reference. |
| README.md files are allowed locations for skill/hook/tool instructions. | User decision/repo convention, not external fact | User/T007 decision; local repository pattern | 2026-06-02 | T010/T011 may create/update README files for setup guidance. Do not cite external docs for this preference. | No reference. |
| “Agents can help port a skill to a user's preferred tool.” | Reasonable assistance option, not guaranteed capability | No primary source; grounded only in general agent assistance and Agent Skills cross-tool standard | 2026-06-02 | Phrase as “an agent can help adapt the task pattern or draft a port, but you must review tool-specific permissions, paths, and syntax.” | No reference unless final text makes a specific tool capability claim. |
| Local shell alias behavior from `~/.bash_aliases` summaries. | Do not independently raise trust in T008; use only T002 summary if needed | T002 handoff only; private shell config intentionally not re-read | 2026-06-02 | Avoid publishing aliases. Prefer explicit commands. If mentioning, summarize effects only and mark author-local. | No reference. |

## Approved, softened, and unresolved claims for implementation

Approved for user-facing use with citations or source links: current Codex config/profile/hook guidance; Codex and Claude Code native subagents; Claude Code agent teams as experimental/disabled by default; Pi no built-in subagents and extension/skill/settings locations; Ketch install/config/backend facts; Python venv/uv/pipx setup facts; Obsidian CLI delete/move/rename/create facts; Claude/Codex `/init` availability when named specifically; broad context-management guidance; security/permission fatigue if backed by NIST/Stanton et al.

Must be softened into opinion/workflow advice: agent-led installation/customization, agent-assisted skill porting, “use a more powerful tier” recommendations, productivity-learning-curve advice, web-discovery’s “search snippets are not evidence” norm unless framed as local research practice, and any claims about response-time expectations.

Unresolved or not approved as factual: exact OpenAI/ChatGPT pricing from this pass; exact ChatGPT response-time ranges; exact `100-150k` context degradation threshold; any statement that “most tools” have `/init`; any statement that Pi has native subagents or permission popups; any guarantee that hooks prevent destructive behavior.

## Ketch/web-discovery setup language T010 may use

A portable, source-backed setup paragraph can say: “The web-discovery skill requires Ketch on `PATH`, or an equivalent workflow with one command that finds candidate sources and another command that retrieves source text. Ketch can be installed with Homebrew, `go install github.com/1broseidon/ketch@latest`, or a GitHub release. Run `ketch config init` and `ketch config` to inspect `~/.config/ketch/config.json` and active backends. Use `ketch search`, `ketch scrape`, `ketch code`, and `ketch docs`; treat search results as leads and scrape the original page before relying on a claim.”

Backend caveat text can say: “Ketch’s default `brave` search backend needs a Brave Search API key. `ddg` is zero-config but may be rate-limited; `searxng` needs a SearXNG URL. For code search, `grepapp` and `sourcegraph` are zero-config in Ketch’s docs, while the GitHub backend needs a `gh` token or configured token. For docs search, Context7 needs a `context7_api_key`. Configure only the backends you intend to recommend.”

## Implementation consequences by target

- `hooks/codex/config.snippet.toml`: replace with base `[features] hooks = true` only, or remove the snippet if hooks default is enough. Do not include `[profiles.auto]`.
- New `hooks/codex/auto.config.snippet.toml`: optional. If created, use top-level `approval_policy = "never"` and `sandbox_mode = "danger-full-access"`, with warnings and destination `~/.codex/auto.config.toml`.
- `hooks/tests/test_codex_hooks.py`: update TOML assertions for `features.hooks`; if an auto profile snippet is separate, test that file separately and stop expecting `profiles.auto` in the base snippet.
- `hooks/README.md`: replace author-vault deployment commands with repo-relative or agent-assisted customization guidance; add prerequisites (`bash`, `jq`, `python3` for Obsidian guard, relevant harness), Codex hook trust review, failure behavior, and warnings that hooks are local accident guards.
- `skills/orchestration/SKILL.md`: portable baseline first; Pi/tmux watcher only as one advanced Pi implementation; Codex and Claude Code native subagents as separate options; Pi native subagents must be “no.”
- `skills/web-discovery/SKILL.md`: add Ketch or equivalent setup contract and backend caveats above.
- `README.md`/`recommendations.md`: separate beginner path from advanced local infrastructure; replace “most tools provide `/init`” with tool-specific wording; soften exact pricing/timing/context-threshold claims; cite or soften permission fatigue.
- `references.md`: add official docs only for setup/capability claims retained in guide/one-pager/recommendations; add NIST/Stanton et al. only if permission/security fatigue remains as a factual caution.

## Sources checked

OpenAI/Codex: `https://developers.openai.com/codex/config-advanced`, `https://developers.openai.com/codex/config-basic`, `https://developers.openai.com/codex/hooks`, `https://developers.openai.com/codex/agent-approvals-security`, `https://developers.openai.com/codex/permissions`, `https://developers.openai.com/codex/subagents`, `https://developers.openai.com/codex/skills`, `https://developers.openai.com/codex/cli/slash-commands`, `https://developers.openai.com/codex/learn/best-practices`.

Anthropic/Claude Code: `https://docs.anthropic.com/en/docs/claude-code/hooks`, `settings`, `permission-modes`, `sub-agents`, `agent-teams`, `skills`, `memory`, `best-practices`, `context-window`, `quickstart`, and `cli-reference` pages.

Pi: `https://pi.dev/docs/latest/usage`, `extensions`, `settings`, `skills`, `shell-aliases`, `tmux`, plus local installed docs and the local `examples/extensions/subagent/` example.

Other primary sources: `https://github.com/1broseidon/ketch`, `https://api-dashboard.search.brave.com/app/documentation/web-search/get-started`, `https://docs.python.org/3/library/venv.html`, `https://docs.astral.sh/uv/getting-started/installation/`, `https://docs.astral.sh/uv/pip/environments/`, `https://pipx.pypa.io/stable/how-to/install-pipx/`, `https://obsidian.md/help/cli`, `https://agentskills.io/specification`, `https://www.nist.gov/news-events/news/2016/10/security-fatigue-can-cause-computer-users-feel-hopeless-and-act-recklessly`, and DOI `10.1109/MITP.2016.84`.
