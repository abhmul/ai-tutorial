---
name: orchestration
description: Coordinate a large objective through delegated workers. Use when the user asks for an orchestrator, orchestration, workers/subagents, a task queue, serial delegated execution, or context-budgeted multi-pass work. Do not use for ordinary tasks one agent can complete directly.
tags:
  - skill
  - ai-generated
status: draft
---
# Orchestration

You are an orchestrator managing a thin control loop for large delegated work to achieve an objective.
## Concepts

### Objective

The overall goal or directive provided by the user. May not be fully specified. Resolution of lack of specification should be executed as tasks (see below) and most sensible choices should be made.

### Task

A unit of work to be completed by delegated worker. **EVERYTHING IS A TASK**. A task is comprised of
- an ID
- a type
- a priority
- dependencies
- title
- relevant files
	- read_first
	- read if needed
- scope
- goals
- non-goals
- safety
- success_criteria
- worker_token_budget
	- *default*: 150k tokens
	- change only if directed by user.

A completed task should produce whatever artifacts were requested by the task in addition to:
- further tasks that are spawned from this one
- old tasks that are revived (e.g. this task is verification of another task, and verification failed)

An incomplete task (due to blocker or filled token_budget) should update dependencies if necessary and produce
- A handoff to future task worker
- further tasks spawned from this one
- old tasks that are revived

Common task types:
- research
- exploration
- brainstorming
- design
- content complexity assessment
- content complexity reduction
- pre-writing
	- outlining
	- audience research
- writing
- verify assumptions
- verify claims
- verify correctness
- verify simplicity/low complexity
- criticize
- write tests
- write scaffolding
- implement
- verify implementation
- maintenence
- reduce complexity
- radical re-organization
- paradigm shift
- revert task

This list is **NOT** exhaustive. **EVERYTHING IS A TASK**.

### Task Queue

A priority queue that stores all the incomplete tasks. Dependencies are taken into account. The task at the top of the queue should satisfy:

> Highest priority task with no blockers or incomplete dependencies

Tasks generate new tasks, and these tasks should be enqueued onto the task queue. The task queue should be empty if and only if the objective is achieved. The last task run should always be a verification task to verify objective has been achieved. However, many more verification tasks will be needed during intermediate task execution.

### Orchestrator

The agent in charge of
- maintaining the task queue
- invoking workers to complete tasks
- provide worker with task specification and rigorous completion criteria
- monitor worker for errors, issues, hangs
- coordinating handoffs between workers when task is incomplete.

An orchestrator is **NOT** a worker. It should keep its context lean. It delegates everything except orchestration loop management to workers.

The orchestrator has the following default settings:
- `default_token_budget`: 250k
- change default only if directed by user.
## Loop


```pseudocode
Init priority queue TASK_QUEUE
Init empty state `.json` file STATE_FILE with fields:
  1. objective
  2. constranits
  3. queue
  4. artifacts/trust
  5. blockers

Enqueue "Init State File" task to TASK_QUEUE to
  - complete STATE_FILE fields for objective, constraints, queue, artifacts/trust, blockers.
  - determine next tasks if not already known

while TASK_QUEUE is not empty:
  TASK <- TASK_QUEUE.pop()
  while TASK is not complete:
    spawn worker to work on TASK
    update STATE_FILE
  for NEW_TASK in NEW_TASKS returned by TASK
    enqueue NEW_TASK onto TASK_QUEUE
  update STATE_FILE

return
```

Some guidance on loop:
1. Store tasks as `.json` files
2. First task should extract the objective, deliverables, constraints, forbidden reads, and quality gates. It may also do any additional useful setup.
3. It should return the next useful tasks; begin with discovery/planning if the path is unclear.
4. Dispatch ready tasks with explicit context files, boundaries, expected outputs, and a handoff path. Workers must not rely on inherited context.
5. Serialize tasks that write shared files; parallelize only clearly disjoint work.
6. Ingest handoffs, update state, and add follow-up/fix/revival tasks as needed.
7. All verification tasks require **INDEPENDENT WORKERS**; producers do not raise trust on their own work.
8. Repeat until the objective is done, blocked, or needs a fresh orchestrator.

To instantiate a worker, use the watcher script in this skill's `references/` directory. Resolve the path relative to this `SKILL.md`; in a normal `.agents` install:

```bash
bash .agents/skills/orchestration/references/pi-worker-watch.sh "<pointer to task>"
```

The script starts `pi -p -t "read,grep,find,ls,edit,write,bash" "<pointer to task>"` in a detached `tmux` session, returns when the worker finishes or after 30 minutes, and prints the last 25 log lines. If the worker is still running, use the printed `--watch <run-dir>` command for the next check. Do not inline or reconstruct the script. If `tmux` is unavailable, report that the worker mechanism is unavailable.

Workers spawned with `pi-worker-watch.sh` have web access if the `web-discovery` skill is available in `.agents`

Remember **EVERYTHING IS A TASK**. Delegate everything except orchestration loop management.


## Contract
- **DO NOT READ**:
	- `tmp/`
	- `archive/`
- Some cases will require escalation to user for manual work. In these cases, you should provide a detailed explanation of the issue and the precise steps the human needs to execute. Examples include
	- installation of system packages that require sudo access
	- installation of software that requires manual download and installation (e.g. from a website)
- All claims made in user prompt and directions **MUST** be verified using verification tasks.

## Defaults

- Ask only for true blockers or user-reserved decisions; otherwise decide or enqueue assessor tasks.
- Treat new artifacts as untrusted until independent checks accept them.
- Carry user/project safety rules into every worker task.
