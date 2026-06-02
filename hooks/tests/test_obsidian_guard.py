import subprocess
import sys
from pathlib import Path

import pytest

HOOKS_DIR = Path(__file__).resolve().parents[1]
GUARD = HOOKS_DIR / "lib" / "obsidian-guard.py"


@pytest.mark.parametrize(
    ("command", "expected_code"),
    [
        pytest.param(
            'obsidian vault=agent-vault daily:append content="removed X, deleted Y"',
            0,
            id="append-with-destructive-words-in-content",
        ),
        pytest.param(
            "obsidian vault=agent-vault read file=remove-feature-plan",
            0,
            id="read-file-with-remove-in-filename",
        ),
        pytest.param(
            'obsidian vault=X search query="delete me"',
            0,
            id="search-with-destructive-query",
        ),
        pytest.param("obsidian vault=X daily", 0, id="just-daily"),
        pytest.param("obsidian vault=X delete file=Y", 2, id="delete-file"),
        pytest.param("obsidian vault=X trash file=Y", 2, id="trash-file"),
        pytest.param("obsidian vault=X daily:delete", 2, id="namespace-delete"),
        pytest.param("obsidian vault=X wipe", 2, id="wipe"),
        pytest.param("", 0, id="empty-command"),
        pytest.param("obsidian", 0, id="just-obsidian"),
        pytest.param('obsidian vault=X daily:append content="unclosed', 2, id="malformed-shell"),
    ],
)
def test_obsidian_guard_classifies_subcommand(command: str, expected_code: int) -> None:
    result = subprocess.run(
        [sys.executable, str(GUARD)],
        input=command,
        text=True,
        check=False,
    )

    assert result.returncode == expected_code
