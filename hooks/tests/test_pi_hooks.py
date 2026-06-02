import json
import os
import shutil
import subprocess
from pathlib import Path
from typing import Any

import pytest

HOOKS_DIR = Path(__file__).resolve().parents[1]
EXTENSION = HOOKS_DIR / "pi" / "destructive-guard.ts"

pytestmark = pytest.mark.skipif(shutil.which("node") is None, reason="Pi extension tests require node")

NODE_HARNESS = r'''
import { mkdir } from "node:fs/promises";
import { pathToFileURL } from "node:url";

const extensionPath = process.argv[2];
const scenario = JSON.parse(process.argv[3]);
const agentDir = process.env.PI_AGENT_DIR;

await mkdir(agentDir, { recursive: true });

const { default: registerExtension } = await import(pathToFileURL(extensionPath).href);
const handlers = new Map();
registerExtension({
  on(eventName, handler) {
    handlers.set(eventName, handler);
  },
});

const prompts = [];
const ctx = {
  hasUI: scenario.hasUI ?? true,
  ui: {
    async confirm(title, message, options) {
      prompts.push({ title, message, options });
      if (scenario.promptError) throw new Error(scenario.promptError);
      return Boolean(scenario.confirm);
    },
  },
};

let result;
if (scenario.kind === "user_bash") {
  result = await handlers.get("user_bash")(
    { type: "user_bash", command: scenario.command, cwd: process.cwd(), excludeFromContext: false },
    ctx,
  );
} else {
  result = await handlers.get("tool_call")(
    {
      type: "tool_call",
      toolCallId: "test-call",
      toolName: scenario.toolName ?? "bash",
      input: scenario.input ?? { command: scenario.command },
    },
    ctx,
  );
}

console.log(JSON.stringify({
  registered: {
    tool_call: typeof handlers.get("tool_call") === "function",
    user_bash: typeof handlers.get("user_bash") === "function",
  },
  result: result ?? null,
  prompts,
}));
'''


@pytest.fixture
def pi_env(tmp_path: Path) -> dict[str, str]:
    home = tmp_path / "home"
    agent_dir = home / ".pi" / "agent"
    (agent_dir / "extensions").mkdir(parents=True)
    env = os.environ.copy()
    env.update({"HOME": str(home), "PI_AGENT_DIR": str(agent_dir)})
    return env


def run_scenario(pi_env: dict[str, str], scenario: dict[str, Any]) -> dict[str, Any]:
    result = subprocess.run(
        ["node", "--input-type=module", "-", str(EXTENSION), json.dumps(scenario)],
        input=NODE_HARNESS,
        text=True,
        capture_output=True,
        env=pi_env,
        check=False,
    )

    assert result.returncode == 0, result.stderr or result.stdout
    return json.loads(result.stdout)


def assert_allowed(response: dict[str, Any], *, prompts: int = 0) -> None:
    assert response["result"] is None
    assert len(response["prompts"]) == prompts


def assert_blocked(response: dict[str, Any], expected_reason: str, *, prompts: int) -> None:
    result = response["result"]
    assert result["block"] is True
    assert expected_reason in result["reason"]
    assert len(response["prompts"]) == prompts


def test_extension_registers_expected_handlers(pi_env: dict[str, str]) -> None:
    response = run_scenario(pi_env, {"command": "ls -la"})

    assert response["registered"] == {"tool_call": True, "user_bash": True}


def test_safe_bash_allows_without_prompt(pi_env: dict[str, str]) -> None:
    response = run_scenario(pi_env, {"command": "ls -la"})

    assert_allowed(response)


def test_non_bash_tool_is_ignored(pi_env: dict[str, str]) -> None:
    response = run_scenario(
        pi_env,
        {"toolName": "read", "input": {"path": "README.md"}},
    )

    assert_allowed(response)


def test_rm_r_prompts_then_blocks_when_denied(pi_env: dict[str, str]) -> None:
    response = run_scenario(pi_env, {"command": "rm -r /tmp/foo", "confirm": False})

    assert_blocked(response, "recursive remove", prompts=1)


def test_rm_rf_prompts_then_allows_when_approved(pi_env: dict[str, str]) -> None:
    response = run_scenario(pi_env, {"command": "rm -rf /tmp/foo", "confirm": True})

    assert_allowed(response, prompts=1)


def test_git_reset_blocks_without_ui(pi_env: dict[str, str]) -> None:
    response = run_scenario(pi_env, {"command": "git reset --hard", "hasUI": False})

    assert_blocked(response, "No interactive pi UI", prompts=0)


def test_pi_extension_self_protection_blocks_without_ui(pi_env: dict[str, str]) -> None:
    response = run_scenario(
        pi_env,
        {"command": "cp /tmp/x $HOME/.pi/agent/extensions/destructive-guard.ts", "hasUI": False},
    )

    assert_blocked(response, "pi guard or config files", prompts=0)


@pytest.mark.parametrize(
    "command",
    [
        pytest.param("echo '{}' > $HOME/.pi/agent/settings.json", id="settings-json"),
        pytest.param("echo '{}' > $HOME/.pi/agent/auth.json", id="auth-json"),
    ],
)
def test_pi_config_redirect_blocks_without_ui(pi_env: dict[str, str], command: str) -> None:
    response = run_scenario(pi_env, {"command": command, "hasUI": False})

    assert_blocked(response, "truncating redirect", prompts=0)


def test_user_bash_prompts_then_returns_blocked_result_when_denied(pi_env: dict[str, str]) -> None:
    response = run_scenario(
        pi_env,
        {"kind": "user_bash", "command": "rm -rf /tmp/foo", "confirm": False},
    )

    result = response["result"]["result"]
    assert result["exitCode"] == 1
    assert result["cancelled"] is False
    assert result["truncated"] is False
    assert "recursive force remove" in result["output"]
    assert len(response["prompts"]) == 1


def test_user_bash_prompts_then_allows_when_approved(pi_env: dict[str, str]) -> None:
    response = run_scenario(
        pi_env,
        {"kind": "user_bash", "command": "rm -rf /tmp/foo", "confirm": True},
    )

    assert_allowed(response, prompts=1)
