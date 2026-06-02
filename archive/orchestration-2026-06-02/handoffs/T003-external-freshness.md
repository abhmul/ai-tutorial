# T003 external freshness verification handoff

Access date: 2026-06-02. Retrieval used `ketch search` and `ketch scrape`, plus the locally installed Pi package documentation where required by Pi-specific guidance. No `tmp/` or `archive/` directories were read. This task did not edit guide text or `references.md`.

## Verdict table

| Focus item | Verdict | Evidence-backed summary |
|---|---|---|
| 1. Codex global config/profile changes | Partially confirmed | Codex still uses `~/.codex/config.toml`, `~/.codex/hooks.json`, approval policies, and sandbox modes, but the current OpenAI docs explicitly say Codex 0.134.0+ no longer reads `[profiles.<name>]` in `config.toml`; profiles now live in separate `~/.codex/<profile-name>.config.toml` files. The local `hooks/codex/config.snippet.toml` is therefore stale for profiles, and `features.codex_hooks` should be replaced with canonical `features.hooks` if shown. |
| 2. Web-discovery setup prerequisites | Partially confirmed | The local `skills/web-discovery/SKILL.md` states `Requires ketch on PATH`, and Ketch primary docs confirm install paths, `search`, `scrape`, `code`, and `docs` commands, and backend configuration. The tutorial should not assume the author’s local Ketch/Brave/Context7 setup; it should tell users to install Ketch or substitute an equivalent search+scrape tool and configure required backends/API keys. |
| 3. Orchestration worker dispatch across Pi, Codex, and Claude Code | Confirmed | The local orchestration skill’s dispatch command is Pi-specific (`pi-worker-watch.sh` starts `pi -p ...` in tmux). Current Pi docs say Pi intentionally has no built-in sub-agents and suggests extensions/packages or external tools such as tmux. Current Codex docs have built-in subagent workflows enabled by default. Current Claude Code docs have subagents and experimental agent teams. Neutral guide text should separate these workflows instead of implying one portable dispatch mechanism. |
| 4. Destructive hooks and permission hooks | Partially confirmed | Codex and Claude Code official docs confirm hook events and JSON shapes matching the local snippets in broad structure. Codex docs add current constraints: hooks are enabled with canonical `features.hooks`, non-managed hooks require trust review, and `PreToolUse` is a guardrail rather than a complete enforcement boundary. Claude docs confirm settings scopes, hook locations, permission modes, and that hooks/permissions are complementary rather than model instructions. Pi docs confirm extensions can intercept `tool_call` and `user_bash` and prompt with `ctx.ui.confirm`; Pi does not have built-in permission popups. Obsidian official CLI confirms destructive commands such as `delete` exist, but the Obsidian guard here is custom policy, not an official security boundary. |
| 5. Agent-python-like environment setup | Partially confirmed | Python, uv, and pipx official docs support recommending an isolated, reproducible Python environment rather than mutating system Python. The local `agent-python` environment itself is machine-specific; general-user setup should explain how to create a similar `.venv` or shared tool environment and should mark exact paths such as `~/.local/share/agent-python/.venv` as examples only. |
| 6. `~/.bash_aliases` or harness-command alias setup | Partially confirmed | Pi official docs have a specific `shellCommandPrefix` setting for making aliases available because Pi runs `bash -c` in non-interactive mode. I did not find an equivalent official cross-harness mechanism for Claude Code or Codex in this pass. Treat alias setup as optional, harness-specific, and avoid reading or publishing unrelated shell configuration. |

## Source evidence

| Source | Access date | Evidence summary |
|---|---:|---|
| https://developers.openai.com/codex/config-advanced | 2026-06-02 | Profiles now load `~/.codex/config.toml` then overlay `~/.codex/<profile>.config.toml`; in Codex 0.134.0+, `--profile` no longer reads `[profiles.profile-name]` and top-level `profile = "..."` is unsupported. `CODEX_HOME` defaults to `~/.codex`; hooks can live in `~/.codex/hooks.json`, `~/.codex/config.toml`, repo `.codex/hooks.json`, or repo `.codex/config.toml`. Approval policy and sandbox mode keys remain documented. |
| https://developers.openai.com/codex/hooks | 2026-06-02 | Hooks are enabled by default; canonical feature key is `features.hooks`, while `codex_hooks` is deprecated. Supported hook locations include user and project hook files/config. Non-managed command hooks require review/trust. `PreToolUse` and `PermissionRequest` JSON output shapes match the local Codex hook scripts. Docs state `PreToolUse` is a guardrail, not a complete enforcement boundary, and does not intercept all tool paths. |
| https://developers.openai.com/codex/agent-approvals-security | 2026-06-02 | Codex defaults include no network access and workspace-limited writes for local CLI/IDE. Documents `sandbox_mode = "danger-full-access"`, `approval_policy = "never"`, network settings, and common sandbox/approval combinations. `--dangerously-bypass-approvals-and-sandbox`/`--yolo` is explicitly elevated risk and not recommended. |
| https://developers.openai.com/codex/permissions | 2026-06-02 | Permission profiles are beta and separate from older `sandbox_mode` settings. Built-ins include `:read-only`, `:workspace`, and `:danger-full-access`; custom profiles can constrain filesystem and network access. Do not mix `default_permissions`/`[permissions]` with `sandbox_mode`. |
| https://developers.openai.com/codex/subagents | 2026-06-02 | Codex subagent workflows are enabled by default, surface in app and CLI, and only spawn when explicitly requested. Built-ins include `default`, `worker`, and `explorer`; custom agents are TOML files under `~/.codex/agents/` or `.codex/agents/`. Subagents inherit sandbox policy, with documented config fields under `[agents]`. |
| https://developers.openai.com/codex/skills and https://developers.openai.com/codex/concepts/customization | 2026-06-02 | Codex supports Agent Skills with progressive disclosure; skills can be global in `$HOME/.agents/skills` or repo-specific in `.agents/skills`. Customization docs list AGENTS.md, memories, skills, MCP, and subagents as separate layers. |
| https://docs.anthropic.com/en/docs/claude-code/hooks | 2026-06-02 | Claude Code hooks are configured in JSON settings; locations include `~/.claude/settings.json`, `.claude/settings.json`, `.claude/settings.local.json`, managed policy, plugins, and skill/agent frontmatter. Documents `PreToolUse`, `PermissionRequest`, `SubagentStart/Stop`, and many other events, with `permissionDecision: "deny"` examples for blocking destructive Bash commands. |
| https://docs.anthropic.com/en/docs/claude-code/settings | 2026-06-02 | Claude Code settings scopes are Managed, User, Project, and Local. User settings live in `~/.claude/settings.json`; project settings in `.claude/settings.json`; local settings in `.claude/settings.local.json`. Settings reload during a session for keys including `permissions` and `hooks`. |
| https://docs.anthropic.com/en/docs/claude-code/permissions and https://docs.anthropic.com/en/docs/claude-code/permission-modes | 2026-06-02 | Claude Code has permission rules, modes (`default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`), and hook extension points. Docs state permission rules are enforced by Claude Code, not by model instructions. `bypassPermissions` should only be used in isolated environments. Auto mode is a research preview and does not guarantee safety. |
| https://docs.anthropic.com/en/docs/claude-code/sub-agents | 2026-06-02 | Claude Code subagents are specialized assistants with separate context windows, custom prompts, tool access, and independent permissions. User subagents live in `~/.claude/agents/`, project subagents in `.claude/agents/`, and plugins/managed settings can provide additional definitions. |
| https://docs.anthropic.com/en/docs/claude-code/agent-teams | 2026-06-02 | Agent teams are experimental, disabled by default, and coordinate multiple Claude Code sessions. They differ from subagents by allowing teammate-to-teammate communication and direct interaction; they add coordination overhead and token cost. |
| https://pi.dev/docs/latest/extensions and local `/home/abhmul/.local/lib/node_modules/@earendil-works/pi-coding-agent/docs/extensions.md` | 2026-06-02 | Pi extensions are TypeScript modules; auto-discovered extension locations include `~/.pi/agent/extensions/*.ts` and `.pi/extensions/*.ts`. Extensions can intercept `tool_call`, mutate or block tool inputs, intercept `user_bash`, use `ctx.ui.confirm`, and register commands/tools. |
| https://pi.dev/docs/latest/skills | 2026-06-02 | Pi implements Agent Skills, loads from `~/.pi/agent/skills`, `~/.agents/skills`, `.pi/skills`, and project `.agents/skills`, supports `/skill:name`, and can use skill directories from other harnesses via settings. |
| https://pi.dev/docs/latest/settings | 2026-06-02 | Pi global settings are `~/.pi/agent/settings.json`; project settings are `.pi/settings.json`. Relevant keys include `shellCommandPrefix`, `extensions`, `skills`, `packages`, and `enableSkillCommands`. |
| https://pi.dev/docs/latest/usage | 2026-06-02 | Pi has `-p/--print`, `--mode json`, `--mode rpc`, built-in tools, resource flags, context files, and design principles. The design section says Pi intentionally does not include built-in MCP, sub-agents, permission popups, plan mode, to-dos, or background bash; users can build/install workflows or use external tools such as containers and tmux. |
| https://pi.dev/docs/latest/shell-aliases | 2026-06-02 | Pi runs bash as non-interactive `bash -c`, so aliases do not expand by default. The documented mechanism is `shellCommandPrefix` in `~/.pi/agent/settings.json`, e.g. enabling `expand_aliases` and evaluating aliases from a shell rc file. |
| https://github.com/1broseidon/ketch | 2026-06-02 | Ketch primary docs describe install via Homebrew, Go, or releases; `ketch search`, `search --scrape`, `scrape`, `code`, `docs`, and `crawl`; config in `~/.config/ketch/config.json`; default search backend Brave, DDG/SearXNG alternatives; Context7 docs backend; and agent integration guidance that operators configure backends once. |
| https://api-dashboard.search.brave.com/app/documentation/web-search/get-started | 2026-06-02 | Brave Search API docs show requests with `X-Subscription-Token`, freshness filters, search operators, pagination, and rich/local data options. Use only if the guide recommends Brave directly or Ketch’s Brave backend setup. |
| https://help.kagi.com/kagi/api/quick-start.html and https://help.kagi.com/kagi/api/search.html | 2026-06-02 | Kagi API docs require a Kagi account, API portal key, and separate API billing. Search API example uses an Authorization token. Use only as an optional alternative if the guide mentions Kagi; the local web-discovery skill does not depend on Kagi. |
| https://obsidian.md/help/cli | 2026-06-02 | Obsidian CLI must be enabled in the Obsidian app and supports commands including `create`, `append`, `move`, `rename`, and `delete`. `delete` trashes by default and has a `permanent` flag. Move/rename can update internal links if vault settings are enabled. |
| https://docs.python.org/3/library/venv.html | 2026-06-02 | Python `venv` creates lightweight isolated environments, conventionally `.venv` or `venv`, not checked into source control, disposable and not movable. Creation command is `python -m venv /path/to/env`; activation is optional because scripts can invoke the venv interpreter directly. |
| https://docs.astral.sh/uv/getting-started/installation/ and https://docs.astral.sh/uv/pip/environments/ | 2026-06-02 | uv installs via standalone installer or package managers; PyPI install recommends `pipx`. uv can create `.venv` with `uv venv`, use specific Python versions, auto-detect `.venv`, and requires a virtual environment by default for environment-mutating operations. |
| https://pipx.pypa.io/stable/how-to/install-pipx/ | 2026-06-02 | pipx requires Python 3.10+ to install and works on macOS/Linux/Windows. Recommended install varies by platform; PEP 668 Linux distributions should use distro package managers or a self-contained venv. `pipx ensurepath` adds the binary directory to PATH. |
| https://agentskills.io/specification | 2026-06-02 | Agent Skills standard requires a directory with `SKILL.md`, YAML frontmatter with `name` and `description`, optional scripts/references/assets, and progressive disclosure. Compatibility fields can state environment requirements such as network access or required tools. |

## Findings and implications

### 1. Codex config/profile guidance

The current local Codex snippet is not current for profiles:

```toml
[features]
codex_hooks = true

[profiles.auto]
approval_policy = "never"
sandbox_mode = "danger-full-access"
```

Current docs imply the updated form should be split by layer, for example:

```toml
# ~/.codex/config.toml
[features]
hooks = true
```

```toml
# ~/.codex/auto.config.toml
approval_policy = "never"
sandbox_mode = "danger-full-access"
```

Then invoke with `codex --profile auto` or `codex exec --profile auto ...`. `features.hooks` can be omitted if relying on the default, but if shown, use the canonical key. If the tutorial keeps an unsandboxed non-interactive example, label it as a convenience example for isolated environments; official docs mark full-access/no-approval operation as elevated risk and not recommended as a general default.

### 2. Web discovery setup

The skill can remain Ketch-based, but setup text should be explicit. Minimal general prerequisites: install `ketch`; ensure it is on `PATH`; run `ketch config` to inspect active backends; configure a web search backend such as Brave, DDG, or SearXNG; optionally configure Context7 for `ketch docs`; optionally configure GitHub/Sourcegraph/Grep backends for `ketch code`; optionally configure Chrome/Chromium for JavaScript-rendered pages. If the guide wants a non-Ketch path, it should state the functional contract: one command for search result discovery and one command for source-text retrieval/scraping, with source URLs and access dates recorded.

### 3. Orchestration and worker dispatch

The tutorial should not present the current `skills/orchestration` worker dispatch as cross-tool. It is Pi-specific because it calls a Pi watcher script that starts `pi -p -t ...` in tmux. A neutral newcomer version can say: Pi has no built-in subagents; use tmux, separate Pi processes, or a Pi extension/package if you need workers. Codex has official subagent workflows in CLI/app and custom TOML agent definitions. Claude Code has official subagents and experimental agent teams. For users who are not ready for subagents, a simple sequential handoff file plus a fresh session is the portable baseline.

### 4. Hooks, destructive guard, and Obsidian guard

Codex: local `hooks.json` broadly matches the documented hook structure and event names. The snippets should be revised for `features.hooks` and for hook trust review. Codex docs explicitly warn `PreToolUse` is not complete enforcement; do not call it a security boundary.

Claude Code: local `settings.snippet.json` uses documented settings hook placement and hook shape. Claude docs support PreToolUse blocking and permission hook use, but permission rules and sandboxing remain separate layers. Do not imply model instructions or hooks alone provide OS-level isolation.

Pi: local `hooks/pi/destructive-guard.ts` is plausible as a Pi extension because official docs support `tool_call`, `user_bash`, `ctx.ui.confirm`, and blocking. This is a custom extension, not built-in Pi behavior; Pi docs explicitly say Pi has no built-in permission popups.

Obsidian: official CLI docs confirm a `delete` command with a `permanent` flag and many mutating commands. The local guard’s parser focuses on delete-like subcommands. If final recommendations cover this guard, say it is a conservative custom confirmation layer for delete-like Obsidian CLI commands, not comprehensive Obsidian safety. If final recommendations discuss broader Obsidian safety, include `move`, `rename`, `create overwrite`, plugin uninstall, publish removal, and vault setting dependencies as separate cases to assess.

### 5. Agent-python-like setup

For general users, avoid the local path `~/.local/share/agent-python/.venv` except as an example. A portable setup can be one of: project-local `.venv` with `python -m venv .venv`; uv-managed `.venv` with `uv venv` and `uv pip install ...`; or CLI tools installed with pipx when they are applications rather than project libraries. State that virtual environments are disposable, not checked into Git, and should be reproducible from a requirements/lock file or documented install command. If the final guide recommends uv, cite uv’s install and environment docs; if it recommends pipx for CLIs, cite pipx’s install docs.

### 6. Shell aliases / harness command setup

Pi is the only harness where I verified an official alias-enablement setting in this pass: `shellCommandPrefix`. Because reading `~/.bash_aliases` can expose unrelated private shell configuration, any local audit should extract only relevant aliases/functions and should not quote secrets or unrelated setup. For newcomer-facing documentation, prefer explicit commands over personal aliases. If aliases are included, make them optional convenience examples and label them by harness.

## Sources the next worker should cite

- Cite OpenAI Codex `config-advanced`, `hooks`, `agent-approvals-security`, `subagents`, and `skills` for current Codex behavior.
- Cite Anthropic Claude Code `hooks`, `settings`, `permissions`, `permission-modes`, `sub-agents`, and `agent-teams` for Claude behavior.
- Cite Pi docs from `pi.dev/docs/latest/...` for Pi settings, skills, extensions, shell aliases, and the statement that Pi intentionally lacks built-in subagents/permission popups.
- Cite Ketch primary docs for the local web-discovery skill’s CLI dependency. Cite Brave/Kagi only when recommending those services directly or as backend alternatives.
- Cite Python `venv`, uv, and pipx docs for environment setup.
- Cite Obsidian CLI docs if discussing the Obsidian guard or Obsidian CLI commands.

## Sources or claims to avoid unless separately verified

- Do not cite blogs or secondary summaries for current Codex, Claude Code, Pi, Ketch, or Obsidian behavior when official docs above are available.
- Do not cite the local `hooks/codex/config.snippet.toml` as current Codex profile guidance; it is stale for Codex 0.134.0+.
- Do not claim hooks are a complete security boundary. Official Codex docs explicitly call `PreToolUse` a guardrail, and Claude docs distinguish permission rules from sandboxing.
- Do not generalize the Pi `shellCommandPrefix` alias setup to Claude Code or Codex without separate official documentation.
- Do not present local paths, local aliases, or the author’s Ketch configuration as prerequisites for all users.

## Blockers and unresolved items

No web-access blocker was encountered. The long Claude, Codex, Pi, Obsidian, and Python pages were retrievable, though some tool outputs were truncated after relevant sections; re-scrape exact pages or anchors if the next worker needs verbatim quotes. I did not verify an official Claude/Codex equivalent of Pi’s alias expansion mechanism. I did not add citations to `references.md`; if final guide text keeps broad cautionary claims about permission fatigue, prompt injection, or human approval behavior, add primary or peer-reviewed references according to the repository rule.
