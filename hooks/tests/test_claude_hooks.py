import json
import os
import shutil
import subprocess
import time
from pathlib import Path

import pytest

HOOKS_DIR = Path(__file__).resolve().parents[1]
GUARD = HOOKS_DIR / "claude" / "destructive-guard.sh"
AUTO = HOOKS_DIR / "claude" / "auto-mode.sh"

pytestmark = pytest.mark.skipif(shutil.which("jq") is None, reason="Claude hook wrappers require jq")


@pytest.fixture
def hook_dirs(tmp_path: Path) -> tuple[Path, Path]:
    home = tmp_path / "home"
    project = tmp_path / "project"
    (home / ".claude" / "hooks").mkdir(parents=True)
    (project / ".git").mkdir(parents=True)
    return home, project


def make_payload(command: str, cwd: Path) -> str:
    return json.dumps({"tool_input": {"command": command}, "cwd": str(cwd)})


def run_guard(home: Path, project: Path, command: str) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env.update({"HOME": str(home), "CLAUDE_PROJECT_DIR": str(project)})
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
    env.update({"HOME": str(home), "CLAUDE_PROJECT_DIR": str(project)})
    return subprocess.run(
        ["bash", str(AUTO)],
        input=make_payload("git status", project),
        text=True,
        capture_output=True,
        env=env,
        check=False,
    )


def combined_output(result: subprocess.CompletedProcess[str]) -> str:
    return result.stdout + result.stderr


@pytest.mark.parametrize(
    ("command", "expected_code", "expected_text"),
    [
        pytest.param("ls -la", 0, "destructive-guard: no destructive patterns detected", id="safe-ls"),
        pytest.param("rm -r /tmp/foo", 2, "recursive remove", id="rm-r"),
        pytest.param("rm --recursive /tmp/foo", 2, "recursive remove", id="rm-recursive"),
        pytest.param("rm -rf /tmp/foo", 2, "recursive force remove", id="rm-rf"),
        pytest.param("git reset --hard", 2, "git reset --hard", id="git-reset-hard"),
        pytest.param(
            "cp /tmp/settings ~/.claude/settings.json",
            2,
            "modify Claude Code guard or config files",
            id="self-protect-settings",
        ),
        pytest.param(
            "obsidian vault=X delete file=Y",
            2,
            "Obsidian deletion requires explicit confirmation",
            id="obsidian-delete-without-confirmation",
        ),
    ],
)
def test_destructive_guard(command: str, expected_code: int, expected_text: str, hook_dirs: tuple[Path, Path]) -> None:
    home, project = hook_dirs

    result = run_guard(home, project, command)

    assert result.returncode == expected_code
    assert expected_text in combined_output(result)


def test_obsidian_delete_with_fresh_confirmation_allows(hook_dirs: tuple[Path, Path]) -> None:
    home, project = hook_dirs
    flag = home / ".claude" / "obsidian-delete-confirmed"
    flag.write_text(f"{int(time.time())}\n")

    result = run_guard(home, project, "obsidian vault=X delete file=Y")

    assert result.returncode == 0
    assert "destructive-guard: no destructive patterns detected" in result.stdout
    assert not flag.exists()


def test_auto_mode_disabled_by_default(hook_dirs: tuple[Path, Path]) -> None:
    home, project = hook_dirs

    result = run_auto_mode(home, project)

    assert result.returncode == 0
    assert result.stdout == ""
    assert result.stderr == ""


def test_auto_mode_enabled_grants_permission(hook_dirs: tuple[Path, Path]) -> None:
    home, project = hook_dirs
    (home / ".claude" / ".auto-mode").touch()

    result = run_auto_mode(home, project)

    assert result.returncode == 0
    payload = json.loads(result.stdout)
    output = payload["hookSpecificOutput"]
    assert output["hookEventName"] == "PreToolUse"
    assert output["permissionDecision"] == "allow"
    assert output["permissionDecisionReason"] == "auto-mode hook: permission granted"


def test_auto_mode_project_opt_out_suppresses_permission(hook_dirs: tuple[Path, Path]) -> None:
    home, project = hook_dirs
    (home / ".claude" / ".auto-mode").touch()
    (project / ".claude").mkdir()
    (project / ".claude" / "no-auto-mode").touch()

    result = run_auto_mode(home, project)

    assert result.returncode == 0
    assert result.stdout == ""
    assert result.stderr == ""
