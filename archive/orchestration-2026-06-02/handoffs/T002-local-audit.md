# T002 local audit handoff

## Scope and evidence status

- Local-only audit only. I did not perform external web verification, did not write the final presentation, and did not edit tutorial, skill, hook, recommendation, reference, or report files.
- I read the T002 task file, the T001 handoff, all T002 `read_first` files, the needed hook auto-mode wrappers and policy helpers, the orchestration worker script, selected skill files, and a targeted subset of `~/.bash_aliases` relevant to agent harness setup.
- I did not read `tmp/`, `archive/`, or `prompt-buffer.md`. I did not run Python. The TDD skill lists artifact paths, but those artifact files were missing when read was attempted.
- Treat all external-tool freshness claims below as `needs T003`; this handoff records direct local evidence and setup assumptions only.

## Source-copy map

- Explicit file comparison against `/home/abhmul/Documents/vaults/agent-vault` found these `ai-tools-intro` files identical to local agent-vault sources: hook snippets/scripts/libs, `skills/web-discovery/SKILL.md`, `skills/orchestration/SKILL.md`, and `skills/tdd/SKILL.md`.
- Differences found: `hooks/README.md` removes one old top-level shim note; `skills/checkpoint/SKILL.md` is an older/simpler copy than agent-vault; `skills/grill-me/SKILL.md` is simplified and no longer points to `to-spec` or artifact files.
- This means much of the material is author-local operational infrastructure copied into a newcomer tutorial repo, not independently generalized installation guidance.

## Findings by focus item

### 1. Author-machine and deployment-path assumptions

- Direct evidence: `hooks/README.md` says these are local hook deployments for Claude Code, Codex, and Pi, deployed manually to `~/.claude/`, `~/.codex/`, and `~/.pi/agent/` (`hooks/README.md:9`, `hooks/README.md:42-44`).
- Direct evidence: deploy and drift-check commands copy from `~/Documents/vaults/agent-vault/...`, not from this repository (`hooks/README.md:52-56`, `hooks/README.md:66-71`, `hooks/README.md:85-88`, `hooks/README.md:97-112`).
- Risk: a newcomer running these commands without the author's vault layout will fail or copy the wrong files.
- Recommended next action: in `hooks/README.md`, separate “author's local deployment example” from “portable setup”; either replace `~/Documents/vaults/agent-vault` with repo-relative paths for this repo or explicitly mark those commands as non-portable examples.

### 2. Obsidian and daily-note assumptions

- Direct evidence: `recommendations.md` recommends Obsidian as a wiki-style knowledge system and mentions human-maintained control files (`recommendations.md:104`).
- Direct evidence: `checkpoint` creates or appends `daily-notes/YYYY-MM-DD.md`, uses Obsidian wikilink-style date links, validates with `git diff --check`, and commits unless stopped (`skills/checkpoint/SKILL.md:17-31`, `skills/checkpoint/SKILL.md:57-66`).
- Direct evidence: the destructive policy treats commands beginning with `obsidian` specially, uses `python3` to classify delete-like subcommands, and requires a 30-second confirmation file such as `$HOOK_HOME/obsidian-delete-confirmed` (`hooks/lib/destructive-policy.sh:39-54`; classifier at `hooks/lib/obsidian-guard.py:15-29`).
- Assessment: this is probably safe as an opt-in local guard, but not general-user-safe as unexplained default setup. It assumes an Obsidian CLI named `obsidian`, a hook home directory, `python3`, and familiarity with temporary confirmation files.
- Recommended next action: add an opt-in Obsidian section explaining prerequisites, what the confirmation file does, and how the checkpoint skill changes a repo; do not present checkpoint as a generic first skill without warning that it writes daily notes and may commit.

### 3. Pi-specific orchestration and worker dispatch

- Direct evidence: the orchestration skill instructs workers to run `.agents/skills/orchestration/references/pi-worker-watch.sh`, which starts `pi -p -t "read,grep,find,ls,edit,write,bash"` in detached `tmux` and assumes web access if `web-discovery` is available in `.agents` (`skills/orchestration/SKILL.md:135-143`).
- Direct evidence: the worker script requires `pi` and `tmux`, defaults logs/status to `$PWD/.pi-workers`, and starts the worker with `"$pi_bin" -p -t "$tools" "$task"` (`skills/orchestration/references/pi-worker-watch.sh:18-24`, `skills/orchestration/references/pi-worker-watch.sh:39-41`, `skills/orchestration/references/pi-worker-watch.sh:183-189`, `skills/orchestration/references/pi-worker-watch.sh:224`, `skills/orchestration/references/pi-worker-watch.sh:232`).
- Risk: this is Pi-specific and will not work for Claude Code, Codex, or users without tmux/Pi. It also assumes `.agents` skill installation semantics.
- Recommended next action: mark orchestration as an advanced Pi-only example or provide harness-neutral alternatives; add prerequisites and explain `.pi-workers` logs.

### 4. Codex config/profile and auto-mode assumptions

- Direct evidence: `hooks/codex/config.snippet.toml` enables hooks and defines `[profiles.auto]` with `approval_policy = "never"` and `sandbox_mode = "danger-full-access"` (`hooks/codex/config.snippet.toml:2-6`).
- Direct evidence: `hooks/README.md` says the Codex `auto` profile is intentionally unsandboxed and non-interactive, with the destructive hook as an accident guard rather than a security boundary (`hooks/README.md:77-78`).
- Direct evidence: Codex `hooks.json` wires `PreToolUse` to `destructive-guard.sh` and `PermissionRequest` to `auto-mode.sh` for Bash (`hooks/codex/hooks.json:3-21`).
- Direct evidence from targeted shell-alias extraction: the local `codex()` shell function routes through `~/.local/share/agent-python/.venv` and invokes `codex -p auto "$@"` (`~/.bash_aliases:236-240`).
- Assessment: this is a setup-specific, high-privilege local workflow. It requires strong opt-in language, not newcomer default guidance. Freshness of Codex hook/profile syntax needs T003.
- Recommended next action: in `hooks/README.md` and any recommendations that mention auto-mode, move this behind an “advanced local setup” warning; consider showing a safer default Codex profile first.

### 5. Ketch/web-discovery setup assumptions

- Direct evidence: `web-discovery` declares `compatibility: Requires ketch on PATH`, routes default lookup through `ketch search`, `ketch code`, `ketch docs`, and `ketch scrape`, and reserves Brave Search for fuzzy/semantic discovery (`skills/web-discovery/SKILL.md:4-5`, `skills/web-discovery/SKILL.md:38-43`).
- Direct evidence: it treats search snippets as discovery only and requires source retrieval before relying on claims (`skills/web-discovery/SKILL.md:25-31`).
- Risk: no local tutorial file currently explains how a newcomer obtains or configures `ketch` or Brave access. Freshness and portability need T003.
- Recommended next action: either add a local-only note saying this skill requires the author's `ketch` setup, or add a verified setup/prerequisites section after T003.

### 6. Destructive-guard behavior and general-user safety

- Direct evidence: Claude and Codex destructive guards require `jq` to parse hook input; Claude blocks with an install-message if `jq` is missing, while Codex fails closed via its `deny` path (`hooks/claude/destructive-guard.sh:14-21`, `hooks/codex/destructive-guard.sh:21-28`).
- Direct evidence: auto-mode wrappers silently do nothing if `jq` is missing and only auto-allow when `$HOOK_HOME/.auto-mode` exists and no project opt-out file is found (`hooks/claude/auto-mode.sh:12-28`, `hooks/codex/auto-mode.sh:12-27`, `hooks/lib/auto-mode-state.sh:14-34`).
- Direct evidence: the shared policy blocks patterns for recursive `rm`, `find -delete` or `-exec rm`, data-destruction tools, block-device writes/formats, critical truncating redirects, destructive SQL statements, destructive git operations, force push/remote deletion, pipe-to-shell, package uninstalls, shutdown/reboot, and writes to protected hook/config files (`hooks/lib/destructive-policy.sh:59-141`).
- Direct evidence: Pi's extension resolves its evaluator under `~/.pi/agent` by default, protects Pi extension/lib/config/auth files, prompts through `ctx.ui.confirm()` when UI is available, and blocks without UI (`hooks/pi/destructive-guard.ts:20-33`, `hooks/pi/destructive-guard.ts:93-115`, `hooks/pi/destructive-guard.ts:123-140`).
- Assessment: the guard is useful as a local accident guard but should not be framed as security. Its regex/string-based policy can have false positives and false negatives; the repo itself states the Codex guard is not a security boundary (`hooks/README.md:77-78`).
- Recommended next action: add a plain-language section explaining prerequisites (`bash`, `jq`, `python3`, hook support, and Pi for the Pi extension), fail-closed behavior, what it does not protect against, and how to disable or opt out.

### 7. Agent-python-like setup assumptions

- Direct evidence: hook tests are documented as running from the vault root with `UV_PROJECT_ENVIRONMENT=~/.local/share/agent-python/.venv uv run --project agent-python pytest hooks/tests` (`hooks/README.md:120-124`).
- Direct evidence from targeted shell-alias extraction: local `claude()` and `codex()` shell functions set `VIRTUAL_ENV="$HOME/.local/share/agent-python/.venv"` and prepend that venv's `bin` to `PATH` before invoking the harness (`~/.bash_aliases:225-240`).
- Risk: a newcomer will not have this shared venv, the `agent-python` project, or the same workaround need. This should be described as author-local, not prerequisite-free.
- Recommended next action: either omit agent-python from public setup or add a verified “testing environment used by the author” note with an alternative using a standard venv.

### 8. Bash alias setup

- Direct evidence extracted from `~/.bash_aliases`: `claude()` wraps `claude --effort max`, `codex()` wraps `codex -p auto`, and `pi()` defaults to `--tools read,grep,find,ls,edit,write,bash` unless tool flags are provided (`~/.bash_aliases:229-255`).
- Risk: these aliases silently change tool behavior and privileges. In particular, `codex -p auto` couples shell startup to the unsandboxed/non-interactive Codex profile.
- Recommended next action: if aliases are included in tutorial material, present them as optional examples with exact consequences; do not suggest sourcing the author's full shell config.

## Other local packaging issues

- `skills/tdd/SKILL.md` frontmatter lists `artifacts/tdd--SKILL/audience-purpose.md` and `artifacts/tdd--SKILL/outline.md` (`skills/tdd/SKILL.md:8-10`), but those files were not present under `skills/tdd/`. Fix by adding the artifacts or removing those frontmatter entries.
- `README.md` says `recommendations.md` links to two example skills, `grill-me` and `checkpoint` (`README.md:17-20`). Extra skills currently exist under `skills/` (`web-discovery`, `orchestration`, `tdd`) without top-level newcomer framing; either hide them from the beginner path or add a clear “advanced/local examples” section.
- `grill-me` is mostly portable, but it instructs the agent to explore vaults, codebases, literature, prior work, and formal tools when useful (`skills/grill-me/SKILL.md:5-11`); add a note that this depends on the agent's allowed file/network access.

## Candidate freshness checks for T003

- Verify current official docs for Claude Code hooks, permission events, sandboxing, and the “auto-mode uses a separate model” claim in `recommendations.md:83`.
- Verify current Codex hook support, `hooks.json` event names, `codex_hooks`, profile fields, `approval_policy = "never"`, and `sandbox_mode = "danger-full-access"`.
- Verify Pi extension API details: `tool_call`, `user_bash`, `ctx.ui.confirm()`, extension auto-discovery at `~/.pi/agent/extensions/*.ts`, and `/reload` behavior.
- Verify whether `ketch` is public, how it is installed, and whether `ketch search/code/docs/scrape` and Brave routing are current.
- Verify beginner-facing claims in `recommendations.md` about paid tiers, model tier names, response times, `/init`, sandboxing availability, and context-buffer degradation around `~100-150k` tokens.

## Recommended edit targets, without applying changes

- `/home/abhmul/Documents/ai-tools-intro/hooks/README.md`: replace author-path deployment commands or label them local-only; add prerequisites, opt-in warnings, and safer defaults.
- `/home/abhmul/Documents/ai-tools-intro/recommendations.md`: clarify that hooks/aliases/advanced skills are examples from the author's setup; soften or verify auto-mode, tier, timing, and context claims after T003.
- `/home/abhmul/Documents/ai-tools-intro/skills/web-discovery/SKILL.md`: add or link setup requirements for `ketch` and Brave, or mark as local-only.
- `/home/abhmul/Documents/ai-tools-intro/skills/orchestration/SKILL.md` and `skills/orchestration/references/pi-worker-watch.sh`: mark as Pi/tmux-specific and advanced; explain `.agents` and `.pi-workers`.
- `/home/abhmul/Documents/ai-tools-intro/skills/checkpoint/SKILL.md`: add an upfront warning that it writes `daily-notes/` and may commit; consider a `--no-commit` beginner variant.
- `/home/abhmul/Documents/ai-tools-intro/skills/tdd/SKILL.md`: fix missing artifact references or remove them.
- `/home/abhmul/Documents/ai-tools-intro/hooks/codex/config.snippet.toml`: keep `danger-full-access`/`approval_policy = "never"` only as an explicitly advanced, opt-in profile after T003 verification.
