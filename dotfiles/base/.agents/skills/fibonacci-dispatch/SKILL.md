---
name: fibonacci-dispatch
description: Dispatch, monitor, and gate remote agent tasks on fibonacci using `fibonacci-dispatch` MCP tools and `agy-remote` live `cmux` viewport tabs. Use whenever executing code, config, or ops tasks on `fibonacci` repositories, dispatching remote workers, or checking `agy-remote` tasks.
---

# fibonacci-dispatch

Coordinate remote worker tasks on `fibonacci` with live `cmux` visibility and dispatcher-gated live deployments.

## Workflow

1. **List repos:** Call `list_repos` (`fibonacci-dispatch` MCP) to confirm the target repo under `~/repos` on `fibonacci`.
2. **Dispatch worker:** Call `dispatch_task`:
	- Set `no_push: true, no_pr: true` when only host-level changes or local verification are needed.
	- Give a clear `worker_name` and structured `prompt` (including the approval gate below if live repo/service changes are involved).
3. **Open live `cmux` tab (required for every worker):**
	- Run `agy-remote attach <task_id> --cmux` (requires `BypassSandbox: true` for `/Users/levontumanyan/.local/state/cmux/cmux.sock`).
4. **Coordinate & gate live changes:**
	- Workers execute in isolated worktrees (`~/.local/share/agy-dispatch/worktrees/<task_id>`).
	- **Approval gate:** Workers MUST NOT apply changes to the live repo (`/home/ubuntu/repos/<repo>`) or restart host services (`systemctl`, `podman-compose`) until the dispatcher (`coordinator`) reviews the diff/plan and sends explicit approval via `send_message`.
	- Poll/wait with `wait_for_update(target="coordinator")`, validate the worker's proposal/diff, and reply via `send_message(from_agent="coordinator", to_agent="<worker_name>", message=...)`.
5. **Inspect report & verify:**
	- Call `get_task_status(task_id=...)` to read the full `report_md` and diffs.
	- Confirm companion services (`agy-mcp.service` on port `8765`, `tailscale serve`) remain untouched and healthy.

## Worker lifecycle (user-controlled)

- Workers stay **live after reporting**: `submit_report` triggers the runner's gate/push/PR handoff automatically — no exit is needed. The worker sits idle in its tab so the user can inspect it and send follow-ups.
- **Never stop, kill, or send `/exit` to a worker on your own initiative.** When a worker goes idle after its report, report that to the user and wait for their call.
- Only call `stop_task` (or `agy-remote stop`) when the user explicitly asks to end a worker — either telling you to kill it, or telling the worker directly in its tab.

## Host Notes (`fibonacci`)

- **Non-interactive commits:** `git commit` on `fibonacci` may fail on `gpg: cannot open '/dev/tty'`. Use `git commit --no-gpg-sign` when committing non-interactively, and stage only task-specific files.
- **No unrequested pushes:** Do not push or open PRs when `no_push: true, no_pr: true` is set.
