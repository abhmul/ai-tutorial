import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type PolicyEvaluation =
  | { decision: "allow" }
  | { decision: "block"; reason: string };

type GuardContext = {
  hasUI: boolean;
  ui: {
    confirm: (title: string, message: string, options?: { timeout?: number }) => Promise<boolean>;
  };
};

const CONFIRM_TIMEOUT_MS = 30_000;
const EXTENSION_DIR = dirname(fileURLToPath(import.meta.url));
const LIB_DIR = process.env.PI_DESTRUCTIVE_GUARD_LIB_DIR
  ? resolve(process.env.PI_DESTRUCTIVE_GUARD_LIB_DIR)
  : resolve(EXTENSION_DIR, "../lib");
const EVALUATOR = resolve(LIB_DIR, "evaluate-destructive-policy.sh");
const PI_AGENT_DIR = process.env.PI_AGENT_DIR
  ? resolve(process.env.PI_AGENT_DIR)
  : join(homedir(), ".pi", "agent");

const POLICY_ENV = {
  HOOK_HOME: PI_AGENT_DIR,
  HOOK_PLATFORM_LABEL: "pi",
  HOOK_PROTECTED_HOME_REGEX: process.env.PI_DESTRUCTIVE_GUARD_HOME_REGEX ?? "\\.pi/agent",
  HOOK_PROTECTED_FILES_REGEX:
    "extensions/|lib/|settings\\.json|keybindings\\.json|auth\\.json|obsidian-delete-confirmed",
};

function formatError(error: unknown, stderr: string): string {
  const message = error instanceof Error ? error.message : String(error);
  const detail = stderr.trim();
  return detail ? `${message}: ${detail}` : message;
}

function evaluateCommand(command: string): Promise<PolicyEvaluation> {
  return new Promise((resolveEvaluation) => {
    execFile(
      "bash",
      [EVALUATOR, command],
      {
        env: { ...process.env, ...POLICY_ENV },
        maxBuffer: 64 * 1024,
        timeout: 5_000,
      },
      (error, stdout, stderr) => {
        if (error) {
          resolveEvaluation({
            decision: "block",
            reason: `BLOCKED: pi destructive-guard evaluator failed: ${formatError(error, stderr)}`,
          });
          return;
        }

        const [decisionLine = "", ...reasonLines] = stdout.replace(/\r\n/g, "\n").split("\n");
        const decision = decisionLine.trim();
        const reason = reasonLines.join("\n").trim();

        if (decision === "allow") {
          resolveEvaluation({ decision: "allow" });
          return;
        }

        if (decision === "block") {
          resolveEvaluation({
            decision: "block",
            reason: reason || "BLOCKED: pi destructive-guard blocked this command.",
          });
          return;
        }

        resolveEvaluation({
          decision: "block",
          reason: `BLOCKED: pi destructive-guard evaluator returned an unknown decision: ${decision || "<empty>"}.`,
        });
      },
    );
  });
}

function formatCommandForPrompt(command: string): string {
  const maxLength = 4_000;
  if (command.length <= maxLength) return command;
  return `${command.slice(0, maxLength)}\n... [command truncated in prompt]`;
}

async function allowOrBlock(command: string, ctx: GuardContext): Promise<PolicyEvaluation> {
  const evaluation = await evaluateCommand(command);
  if (evaluation.decision === "allow") return evaluation;

  if (!ctx.hasUI) {
    return {
      decision: "block",
      reason: `${evaluation.reason}\n\nNo interactive pi UI was available to approve the command.`,
    };
  }

  try {
    const ok = await ctx.ui.confirm(
      "Potentially destructive Bash command",
      `${evaluation.reason}\n\nCommand:\n${formatCommandForPrompt(command)}\n\nAllow this command one time?`,
      { timeout: CONFIRM_TIMEOUT_MS },
    );

    if (ok) return { decision: "allow" };
  } catch (error) {
    return {
      decision: "block",
      reason: `${evaluation.reason}\n\nApproval prompt failed: ${error instanceof Error ? error.message : String(error)}`,
    };
  }

  return evaluation;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return undefined;

    const commandInput = (event.input as { command?: unknown }).command;
    const command = typeof commandInput === "string" ? commandInput : "";
    if (!command) {
      return { block: true, reason: "BLOCKED: pi destructive-guard could not read the Bash command." };
    }

    const evaluation = await allowOrBlock(command, ctx as GuardContext);
    if (evaluation.decision === "allow") return undefined;

    return { block: true, reason: evaluation.reason };
  });

  pi.on("user_bash", async (event, ctx) => {
    const evaluation = await allowOrBlock(event.command, ctx as GuardContext);
    if (evaluation.decision === "allow") return undefined;

    return {
      result: {
        output: `${evaluation.reason}\n`,
        exitCode: 1,
        cancelled: false,
        truncated: false,
      },
    };
  });
}
