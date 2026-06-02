# T009 hooks Codex implementation handoff

## Status

Complete. I read the required T009 task file, project instructions, T007/T008 handoffs, the generalization review, current hook docs, Codex snippets, Codex hooks file, Codex tests, and read-if-needed hook wrappers/libs/tests. I relied on T008 for official-source Codex/Claude/Pi capability and configuration claims. I did not deploy anything into `~/.claude`, `~/.codex`, or `~/.pi`.

## Changed files

- `hooks/README.md`: reframed hooks as advanced opt-in accident guards rather than beginner defaults or security boundaries; replaced author-vault copy/diff commands with repository-relative examples plus agent-assisted customization guidance; added prerequisites, runtime behavior, failure behavior, auto-mode toggles, project opt-outs, Obsidian confirmation-file behavior, Codex hook trust review, and portable testing guidance.
- `hooks/codex/config.snippet.toml`: replaced the stale Codex hook feature alias and embedded profile table with the current explicit base config form: `[features] hooks = true`.
- `hooks/codex/auto.config.snippet.toml`: added a separate advanced profile-file example for `~/.codex/auto.config.toml` using top-level `approval_policy = "never"` and `sandbox_mode = "danger-full-access"` with warning comments.
- `hooks/tests/test_codex_hooks.py`: updated snippet assertions to expect `features.hooks`, verify no embedded profile table in the base config, and verify the separate auto profile snippet uses top-level profile settings.

## Validation

Before running Python tests, I read `/home/abhmul/Documents/vaults/agent-vault/agent-python/README.md` after `/home/abhmul/Documents/vaults/agent-vault/agent-python/README` was absent.

- `cd /home/abhmul/Documents/ai-tools-intro && ~/.local/share/agent-python/.venv/bin/python -m pytest hooks/tests/test_codex_hooks.py` → 13 passed.
- `cd /home/abhmul/Documents/ai-tools-intro && ~/.local/share/agent-python/.venv/bin/python -m pytest hooks/tests` → 50 passed.
- `rg -n 'codex_hooks|\[profiles\.auto\]|~/Documents/vaults/agent-vault|~/.local/share/agent-python' /home/abhmul/Documents/ai-tools-intro/hooks || true` → no output.
- `git -C /home/abhmul/Documents/ai-tools-intro diff --check -- hooks/README.md hooks/codex/config.snippet.toml hooks/tests/test_codex_hooks.py` → no output.

## Remaining references and issues

- `reports/generalization-review.md` and `reports/generalization-review-presentation.html` still contain historical statements that the old hook README/snippet were stale, including the old author-local path and deprecated Codex syntax. I did not edit reports in T009 scope; if those reports remain public-facing after implementation, T011/T012 should decide whether to add an update note or leave them as historical audit artifacts.
- Orchestration task and handoff files still contain stale strings as task history and evidence. I left them unchanged.
- I did not update `orchestration/state.json`; it already appeared modified in `git status` during this session.
- No runtime config was changed, so users still need a reviewed manual deployment if they want these hooks live.
