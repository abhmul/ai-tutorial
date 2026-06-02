import json
import os
import shutil
import subprocess
import time
import tomllib
from pathlib import Path

import pytest

HOOKS_DIR = Path(__file__).resolve().parents[1]
GUARD = HOOKS_DIR / "codex" / "destructive-guard.sh"
AUTO = HOOKS_DIR / "codex" / "auto-mode.sh"
CONFIG_SNIPPET = HOOKS_DIR / "codex" / "config.snippet.toml"

pytestmark = pytest.mark.skipif(shutil.which("jq") is None, reason="Codex hook wrappers require jq")


@pytest.fixture
def hook_dirs(tmp_path: Path) -> tuple[Path, Path]:
    home = tmp_path / "home"
    project = tmp_path / "project"
    (home / ".codex" / "hooks").mkdir(parents=True)
    (project / ".git").mkdir(parents=True)
    return home, project


def make_payload(command: str, cwd: Path) -> str:
    return json.dumps({"tool_input": {"command": command}, "cwd": str(cwd)})


def run_guard(home: Path, project: Path, command: str) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env["HOME"] = str(home)
    return subprocess.run(
        ["bash", str(GUARD)],
        input=make_payload(command, project),
        text=True,
        capture_output=True,
        env=env,
        check=False,
    )


def run_auto_mode(home: Path, project: Path) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env["HOME"] = str(home)
    return subprocess.run(
        ["bash", str(AUTO)],
        input=make_payload("git status", project),
        text=True,
        capture_output=True,
        env=env,
        check=False,
    )


def pretool_decision(result: subprocess.CompletedProcess[str]) -> tuple[str, str]:
    assert result.returncode == 0
    assert result.stderr == ""
    payload = json.loads(result.stdout)
    output = payload["hookSpecificOutput"]
    assert output["hookEventName"] == "PreToolUse"
    return output["permissionDecision"], output["permissionDecisionReason"]


@pytest.mark.parametrize(
    ("command", "expected_text"),
    [
        pytest.param("rm -r /tmp/foo", "recursive remove", id="rm-r"),
        pytest.param("rm --recursive /tmp/foo", "recursive remove", id="rm-recursive"),
        pytest.param("rm -rf /tmp/foo", "recursive force remove", id="rm-rf"),
        pytest.param("git reset --hard", "git reset --hard", id="git-reset-hard"),
        pytest.param(
            "cp /tmp/config ~/.codex/config.toml",
            "modify Codex guard or config files",
            id="self-protect-config",
        ),
        pytest.param(
            "obsidian vault=X delete file=Y",
            "Obsidian deletion requires explicit confirmation",
            id="obsidian-delete-without-confirmation",
        ),
    ],
)
def test_destructive_guard_denies_destructive_commands(
    command: str,
    expected_text: str,
    hook_dirs: tuple[Path, Path],
) -> None:
    home, project = hook_dirs

    result = run_guard(home, project, command)

    decision, reason = pretool_decision(result)
    assert decision == "deny"
    assert expected_text in reason


def test_destructive_guard_allows_safe_command_with_no_output(hook_dirs: tuple[Path, Path]) -> None:
    home, project = hook_dirs

    result = run_guard(home, project, "ls -la")

    assert result.returncode == 0
    assert result.stdout == ""
    assert result.stderr == ""


def test_obsidian_delete_with_fresh_confirmation_allows(hook_dirs: tuple[Path, Path]) -> None:
    home, project = hook_dirs
    flag = home / ".codex" / "obsidian-delete-confirmed"
    flag.write_text(f"{int(time.time())}\n")

    result = run_guard(home, project, "obsidian vault=X delete file=Y")

    assert result.returncode == 0
    assert result.stdout == ""
    assert result.stderr == ""
    assert not flag.exists()


def test_auto_mode_disabled_by_default(hook_dirs: tuple[Path, Path]) -> None:
    home, project = hook_dirs

    result = run_auto_mode(home, project)

    assert result.returncode == 0
    assert result.stdout == ""
    assert result.stderr == ""


def test_auto_mode_enabled_grants_permission(hook_dirs: tuple[Path, Path]) -> None:
    home, project = hook_dirs
    (home / ".codex" / ".auto-mode").touch()

    result = run_auto_mode(home, project)

    assert result.returncode == 0
    payload = json.loads(result.stdout)
    output = payload["hookSpecificOutput"]
    assert output["hookEventName"] == "PermissionRequest"
    assert output["decision"] == {"behavior": "allow"}


def test_auto_mode_project_opt_out_suppresses_permission(hook_dirs: tuple[Path, Path]) -> None:
    home, project = hook_dirs
    (home / ".codex" / ".auto-mode").touch()
    (project / ".codex").mkdir()
    (project / ".codex" / "no-auto-mode").touch()

    result = run_auto_mode(home, project)

    assert result.returncode == 0
    assert result.stdout == ""
    assert result.stderr == ""


def test_config_snippet_keeps_guarded_full_access_profile() -> None:
    config = tomllib.loads(CONFIG_SNIPPET.read_text())

    assert config["features"]["codex_hooks"] is True
    auto_profile = config["profiles"]["auto"]
    assert auto_profile["approval_policy"] == "never"
    assert auto_profile["sandbox_mode"] == "danger-full-access"
