---
name: orchestration
description: Coordinate a large objective through delegated workers. Use when the user asks for an orchestrator, orchestration, workers/subagents, a task queue, serial delegated execution, or context-budgeted multi-pass work. Do not use for ordinary tasks one agent can complete directly.
compatibility: Requires manual fresh-session handoffs or a project-configured worker dispatch method; setup guidance lives in SETUP.md.
tags:
  - skill
  - ai-generated
status: draft
---
# Orchestration

You are an orchestrator managing a thin control loop for large delegated work to achieve an objective.

## Setup boundary

This `SKILL.md` defines the orchestration work model, task schema, queue loop, worker contract, and trust rules. It intentionally does not install, choose, or hard-code a worker backend. Use the worker dispatch method already configured for the current project and harness. If no method is configured, if the setup is unclear, or if the user asks to configure orchestration, read `SETUP.md` and guide the user through setup before delegating.

Do not invent harness-specific worker commands from memory. A worker command, subagent feature, tool allowlist, network permission, or path convention must be verified in the current harness setup before use.

## Concepts

### Harness

A harness is the program that gives the model tools, files, permissions, and a user interface. Pi, Codex, and Claude Code are different harnesses. In this skill, Pi means the `pi` coding harness, not Raspberry Pi hardware. Do not assume that a worker command, subagent feature, or permission setting in one harness exists in another.

### Objective

The overall goal or directive provided by the user. It may not be fully specified. Resolve missing specification through tasks where useful, and make sensible choices when they are not user-reserved decisions.

### Task

A task is a unit of work completed by a delegated worker. **EVERYTHING IS A TASK**. A task is comprised of:

- an ID;
- a type;
- a priority;
- dependencies;
- a title;
- relevant files:
  - `read_first`;
  - `read_if_needed`;
- scope;
- goals;
- non-goals;
- safety rules;
- success criteria;
- worker token budget:
  - default: 150k tokens;
  - change only if directed by user.

A completed task should produce the requested artifacts plus:

- further tasks spawned from this one;
- old tasks revived by this one, such as when verification fails.

An incomplete task, whether due to a blocker or filled token budget, should update dependencies if necessary and produce:

- a handoff to a future task worker;
- further tasks spawned from this one;
- old tasks revived by this one.

Common task types include:

- research;
- exploration;
- brainstorming;
- design;
- content complexity assessment;
- content complexity reduction;
- pre-writing:
  - outlining;
  - audience research;
- writing;
- verify assumptions;
- verify claims;
- verify correctness;
- verify simplicity or low complexity;
- criticize;
- write tests;
- write scaffolding;
- implement;
- verify implementation;
- maintenance;
- reduce complexity;
- radical re-organization;
- paradigm shift;
- revert task.

This list is **NOT** exhaustive. **EVERYTHING IS A TASK**.

### Task queue

A priority queue stores all incomplete tasks. Dependencies are taken into account. The task at the top of the queue should satisfy: highest priority task with no blockers or incomplete dependencies.

Tasks generate new tasks, and these tasks should be enqueued onto the task queue. The task queue should be empty if and only if the objective is achieved. The last task run should always be a verification task to verify the objective has been achieved. Intermediate verification tasks are usually also needed.

### Orchestrator

The orchestrator is the agent in charge of:

- maintaining the task queue;
- invoking workers through the configured dispatch method;
- giving workers task specifications and rigorous completion criteria;
- monitoring worker results for errors, issues, hangs, and blockers;
- coordinating handoffs between workers when a task is incomplete.

An orchestrator is **NOT** a worker. Keep orchestration context lean. Delegate everything except orchestration loop management.

The orchestrator has the following default settings:

- `default_token_budget`: 250k;
- change default only if directed by user.

## Loop

```pseudocode
Init priority queue TASK_QUEUE
Init empty state `.json` file STATE_FILE with fields:
  1. objective
  2. constraints
  3. queue
  4. artifacts/trust
  5. blockers

Enqueue "Init State File" task to TASK_QUEUE to:
  - complete STATE_FILE fields for objective, constraints, queue, artifacts/trust, blockers
  - determine next tasks if not already known

while TASK_QUEUE is not empty:
  TASK <- TASK_QUEUE.pop()
  while TASK is not complete:
    dispatch TASK through the configured worker mechanism
    if no configured worker mechanism is available:
      read SETUP.md and either guide setup, use a user-approved manual handoff, or report blocked
    ingest worker handoff
    update STATE_FILE
  for NEW_TASK in NEW_TASKS returned by TASK:
    enqueue NEW_TASK onto TASK_QUEUE
  update STATE_FILE

return
```

Loop guidance:

1. Store tasks as `.json` or `.md` files in a predictable project-local task directory.
2. First task should extract the objective, deliverables, constraints, forbidden reads, and quality gates. It may also initialize state files or task directories.
3. First task should return the next useful tasks; begin with discovery or planning if the path is unclear.
4. Dispatch ready tasks with explicit context files, boundaries, expected outputs, and a handoff path. Workers must not rely on inherited chat context.
5. Serialize tasks that write shared files; parallelize only clearly disjoint work.
6. Ingest handoffs, inspect changed files, update state, and add follow-up, fix, or revival tasks as needed.
7. All verification tasks require **INDEPENDENT WORKERS**; producers do not raise trust on their own work.
8. Repeat until the objective is done, blocked, or needs a fresh orchestrator.

## Worker contract

Every worker dispatch method, whether manual, native subagent, external process, or other harness-specific mechanism, must satisfy this contract:

1. The worker receives a bounded task file with task ID, dependencies, files to read, scope, goals, non-goals, safety rules, success criteria, expected outputs, handoff path, and token budget.
2. The worker receives explicit context pointers and must not rely on inherited chat context.
3. The worker writes a handoff artifact that records what was read, what changed, what was verified, blockers, uncertainty, and follow-up tasks.
4. The orchestrator ingests the handoff, inspects relevant artifacts, updates the queue/state, and independently verifies important claims or implementation work.
5. Project and user safety rules apply to every worker, including forbidden reads and limits on network, writes, installs, and destructive commands.

If a configured worker method cannot satisfy this contract, do not use it for orchestration until setup is revised.

## Contract

- **DO NOT READ**:
  - `tmp/`;
  - `archive/`.
- Some cases require escalation to the user for manual work. In these cases, provide a detailed explanation of the issue and the precise steps the human needs to execute. Examples include:
  - installation of system packages that require sudo access;
  - installation of software that requires manual download and installation.
- All claims made in the user prompt and directions **MUST** be verified using verification tasks.

## Defaults

- Ask only for true blockers or user-reserved decisions; otherwise decide or enqueue assessor tasks.
- Treat new artifacts as untrusted until independent checks accept them.
- Carry user and project safety rules into every worker task.
- Remember **EVERYTHING IS A TASK**. Delegate everything except orchestration loop management.
