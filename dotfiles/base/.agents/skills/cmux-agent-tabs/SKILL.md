---
name: cmux-agent-tabs
description: Open and drive opencode (or other TUI agent) tabs in cmux workspaces — one tab per PR or per unit of parallel work, each with a pasted prompt. Use this skill whenever the user asks to open a new tab, window, or workspace in cmux, spawn agents to review PRs, or run several opencode sessions in parallel. Trigger on "open a tab in cmux", "open opencode in each", "review each of these PRs in tabs", "ask an agent in a new tab", even if cmux or opencode is not named explicitly but multiple parallel agent sessions in terminal tabs are clearly wanted.
---

# cmux agent tabs

Run one opencode TUI per PR/task in cmux terminal tabs, each seeded with a prompt via clipboard paste. Never type prompts into a TUI by hand and never use `--type agent-session`.

## Why terminal surfaces, not agent-session surfaces

`cmux new-surface --type agent-session --provider opencode` looks like the right tool. It is not:

- `cmux read-screen` fails on it ("Surface is not a terminal") — you cannot verify the agent booted or is working.
- `cmux agent message <target>` fails when the running cmux app is older than the bundled CLI ("agent.message.send is not supported by the app... different builds") — you cannot talk to it at all.
- It renders an embedded UI surface with no tty the paste mechanism can reach.

A plain terminal tab running the `opencode` TUI works with every cmux command: `paste`, `read-screen`, `rename-tab`. Use it.

## Creating a workspace (coordinator move-out)

`cmux new-workspace` (alias `cmux workspace create`) makes a fresh workspace for a coordination run, so worker tabs never crowd the user's existing ones:

```bash
cmux new-workspace --name "COORD · <topic>" --cwd <dir> --focus false
# OK workspace:27  → capture the ref
cmux workspace rename workspace:27 --title "<final name>"   # renaming works after the fact
```

When the coordinator moves itself out, `move-surface` carries an existing tab (its own included) into the new workspace without killing the process inside:

```bash
cmux move-surface --surface <coordinator-surface> --workspace workspace:27
```

After the move, `cmux identify` (run by anything in that tab) reports the new workspace as caller — but safer to pass `--workspace <new ref>` explicitly on every subsequent command. Verify with `cmux tree --workspace <ref>` after every structural step: create, move, reorder.

Closing a workspace (`cmux close-workspace --workspace <ref>`) closes its tabs with it — same "only on explicit request" rule as closing a tab.

## Discovery (always first)

```bash
cmux identify          # shows caller workspace/window/surface refs and socket path
cmux tree --workspace workspace:NN   # tabs in a workspace
```

Workspace refs look like `workspace:26`; windows like `window:2`. The `--workspace`/`--window` flags on the commands below take these refs. If the user says "this workspace", it's the caller's workspace from `cmux identify`.

**New tabs always go in the caller's workspace.** Run `cmux identify` first and use its `caller.workspace_ref` for every `--workspace` flag below — or omit the flag, `new-surface` then defaults to the caller's workspace too (verified: a bare `new-surface` lands in the calling session's workspace). Never pick a workspace ref from `cmux workspace list` output: the first entry is not the caller's, and `[selected]` marks the app's focused workspace, which drifts from the caller's the moment the user switches tabs. `cmux workspace list` is for *reporting* on other workspaces, never for choosing where to spawn.

## Recipe per tab

1. Prepare the working directory. For PR reviews use a git worktree per PR (never the user's main checkout — see the `worktree` skill):
   ```bash
   git fetch origin <head-branch>
   git worktree add <path> --track -b pr/<number> origin/<head-branch>
   ```
2. Write the prompt to a file under the approved temp dir (`/private/var/folders/.../T/opencode`), never a heredoc inline — `cmux paste` reads it with `- < file`.
3. Open the tab:
   ```bash
   cmux new-surface --type terminal \
     --working-directory <worktree> \
     --command opencode \
     --workspace <ref> --window <ref> --focus false
   # <ref> = the caller's workspace_ref from `cmux identify` — never from `workspace list`
   # OK surface:240 pane:48 workspace:26  → capture the surface ref
   ```
   `--focus false` keeps the user's current tab focused while a batch opens.
4. Wait for the TUI to boot (~`sleep 9`). opencode shows an MCP-auth banner and an input box; pasting before boot drops the prompt.
5. Seed the prompt:
   ```bash
   cmux paste --workspace <ref> --surface <surface-ref> --submit - < prompt.md
   ```
   `--submit` presses enter so the agent starts immediately.
6. Name the tab — format `action | number | summary` (pipe-separated):
   ```bash
   cmux rename-tab --workspace <ref> --surface <surface-ref> "REVIEW | 4305 | FRS ConMon key"
   ```
   Keep every field short — tabs are narrow, long names clump into truncated blobs in the sidebar. Action: one scannable verb (`REVIEW`, `VERIFY`, `WORK`, `REPLY`, `DEEP`). Number: the PR/issue number bare (`4305`, not `PR 4305`). Summary: 2-3 words, aggressively brief — hover shows the full name, so the summary never needs to carry detail. Names survive restarts — refs do not. The full descriptive name goes in the run dir (see "Report hand-off and coord file"), never in the tab title.
7. Verify it landed (do not skip):
   ```bash
   sleep 5
   cmux read-screen --workspace <ref> --surface <surface-ref> --lines 10
   ```
   Signs the prompt landed: a shell indicator (`esc interrupt`, `↓ 1 shell`), a token/cost counter climbing (`21.1K (2%) · $0.01`), tool output scrolling. If you still see the empty "Ask anything…" input box, the paste missed — re-run step 5 and check again.

When opening many tabs, loop steps 3–7 per PR sequentially (each needs its boot sleep and verification before the next).

## Pitfalls hit in practice

- **`cmux paste` can time out** even when it succeeded, and can also silently not deliver. Always verify with `read-screen`; on a missed paste just re-paste.
- **`new-surface` can return OK without creating the tab** — the reply says `OK surface:NNN ...` but `paste` then fails with `Missing or invalid terminal_id` and the surface never appears in `cmux tree`. After `new-surface`, confirm the surface exists in `cmux tree` (with a tty attached) before pasting; if it is missing, just run `new-surface` again.
- **zsh `path` is special** — it is tied to `PATH`. Using `path` as a variable name in a loop silently destroys PATH mid-script (`git`, `tail` suddenly "command not found"). Use `wt`, `ref`, `out`.
- **zsh `prompt` is special too** — `declare -A prompt` fails with "can't assign array value to non-array special". Same class of footgun as `path`: one-word lowercase names collide with zsh specials. Use `pfile`, `name2`, anything not special.
- **Unquoted `===`/`**` as echo separators get glob-expanded** in zsh ("zsh:1: == not found"). Use `---` or quote them.
- **`read-screen` works on terminal surfaces only** — with `--workspace` and `--surface` refs, both required.
- **PR branches may come from forks**: `gh pr view <n> --json headRepositoryOwner` first. If the head repo is not the target repo, `git remote add <owner> https://github.com/<owner>/<repo>.git`, then fetch and worktree from `<remote>/<branch>`.
- **Worktree layout on this machine**: `~/repos/<repo>` is often a *container directory* of worktrees with the main checkout inside it (e.g. `~/repos/platform-security-terraform/pst`). Discover with `git worktree list` from the main checkout before creating new ones, and follow the existing naming convention (`<repo>--<slug>`).

## Review prompt template

For "review each of these PRs" requests, seed each tab with a tailored prompt (not one generic text): PR title + link, the worktree/branch context, what to read (`gh pr view`/`gh pr diff` + existing review comments), the repo-convention checks (AGENTS.md, naming, tab indentation, minimal comments), the specific technical focus for that PR, an explicit **read-only** constraint (no push, no GitHub comments, no applies), and the required report shape: verdict (approve-ready / needs changes), findings by severity with file:line references. Then report to the user in what order to check the tabs — grouped so findings from one PR carry to its twins (same change across envs) — and note which agents are still running.

## Status checks

To report progress on live tabs: `cmux tree --workspace <ref>` (tab list) and `cmux read-screen` per tab (agent working vs idle vs missed prompt). `read-screen` shows only the last screenful — use it for *status*, never as the harvest channel for a finished report. The harvest channel is the worker's report file (see "Report hand-off and coord file"); the worker's final on-screen verdict is a done signal and the operator-facing summary.

## Report hand-off and coord file

`read-screen` is viewport-only: it can never return a full report (they run 5-10KB+). So every coordinator run gets a run dir under the approved temp dir, and the run dir — not the screen — is the communication channel:

```
/private/var/folders/.../T/opencode/<run-slug>/
├── shared.md              # roster + constraints + append-only message log
└── w-<name>-report.md      # one per worker: the full final report
```

**Two layers of naming, both assigned by the coordinator at spawn:**

- **Worker name** (`w-4404`, `w9-remote`) — the machine key: roster row, report filename, log prefix. Short and stable. `COORDINATOR` is the coordinator's reserved name.
- **Tab name** — `action | number | summary` (see step 6 of the recipe). For the human sidebar only.

**`shared.md` structure** — the coordinator's one bounded read per poll:

```markdown
# Run: <topic>
Dir: <abs path>. Coordinator: COORDINATOR. Workers use their roster name.

## Roster
| name | task | workdir | report file | status |
|------|------|---------|-------------|--------|
| w-4404 | REVIEW PR 4404 | <worktree> | w-4404-report.md | running |

## Hard constraints
READ-ONLY on GitHub and infra — no push, no comments, no apply, no merge, no VPN changes.

## Termination protocol
When done: write your report file, log one entry, write the on-screen verdict, stop. Never close/exit this tab.

## Message log — append only, newest last
- [COORDINATOR] 07:28 spawned w-4404
- [w-4404] 07:51 report ready → w-4404-report.md, verdict: approve-ready
```

**Rules:**

1. **Message log entries start with the name in brackets** — `[COORDINATOR]` or `[<worker-name>]` — so anyone can `grep '\[w-4404\]'` and get that one agent's whole trail. The coordinator logs only when needed (addenda, decisions, cross-carried findings, spawn/harvest events) — the log is an index, not a diary.
2. **Context budget:** max 3 lines per log entry, no slop — the log is the coordinator's bulk read on every poll. Full detail lives in the report file; the coordinator reads a report file only when it acts on that worker's verdict, not on every pass.
3. **Channels are fixed:** into a worker = `cmux paste --submit`; out of a worker = its report file; status = `read-screen` only.
4. **The screen is for the operator:** every worker ends with a short on-screen verdict (verdict + top findings, one paragraph). The user scrolls tabs at any moment and must get the answer without opening files. Screen = operator summary; file = coordinator harvest; log = pollable index.
5. **Done contract:** a worker is finished when *both* hold — its report file exists, and its screen shows a fresh `Build · <model> · <duration> · <tok/s>` line with nothing after it. Check both; the screen alone proves nothing about the file and vice versa.
6. **Dead-worker fallback:** worker tabs are opencode sessions, so a worker that died before writing its report is still recoverable via the `sessions` MCP (`grep_sessions` / session digest) — harvest the transcript from there.

## Coordinator pattern

When one session (this one) owns a batch of worker tabs and drives them to completion:

1. **Plan before spawning** — list the tasks first, one tab per task, and write every prompt file before opening any tab. Spawning before planning produces orphan tabs nobody owns.
2. **Coordinator move-out** — for a run bigger than a couple of one-off tabs, create a dedicated workspace ("Creating a workspace"), move the coordinator tab into it, rename the workspace to the run's topic (`COORD · <topic>`), and spawn all workers there. The run then owns its whole sidebar entry; workers and coordinator stay together through restarts because workspace names survive.
3. **Set up the run dir first** — create the run dir and `shared.md` ("Report hand-off and coord file") *before* spawning: assign every worker its name, write the roster, constraints, and termination protocol, then seed each prompt with its name, the `shared.md` path, and its report filename. The registry lives in `shared.md` — do not duplicate it in working memory.
4. **Spawn** — the recipe above, sequential, each tab verified before the next.
5. **Poll, don't watch** — between user asks, run a status pass: `cmux tree` for the roster, then `read-screen` per tab. Read the screen signs the same way as the boot check: climbing token counter = working; a `Build · <model> · <duration> · <tok/s>` line with nothing after it = finished (confirm the report file exists too — "Report hand-off" rule 5); a bare "Ask anything…" input box = prompt missed → re-paste.
6. **Harvest and drive** — when a worker finishes, read its report *file*, act on it (summarize for the user, open follow-up work), and if the task needs more rounds, paste the next prompt into that tab with `--submit` and log the addendum `[COORDINATOR]`. A worker is done with its task when its output is consumed, not when its prompt runs out.
7. **Report after every pass** — after each poll round tell the user: which workers are running, which finished (with one-line results), which are stuck or missed their prompt, and what you did about the stuck ones. Never close a tab on your own initiative — see "Closing a tab".
8. **Seed a termination protocol into every worker prompt** — "When your task is done: write your full report to <run-dir>/w-<name>-report.md, append one entry to the shared.md message log, write a short on-screen verdict for the operator, then stop. Do not close this tab, do not run /exit, do not ask anyone to close it — the coordinator and user own tab lifecycle." Workers *can* self-close (verified live: `cmux identify` reveals the worker's own `caller.surface_ref`, and `cmux close-surface --surface <own> --workspace <own> --force true` really closes the tab — the CLI delivers the close over the socket before the session dies), but a self-closed worker cannot confirm or report anything afterward — its report dies with the tab, and the coordinator loses its output. That is why tab lifecycle stays with the coordinator, not a capability gap. A worker attempting a self-close may also stall at its own permission gate asking for confirmation — if you see that question on `read-screen`, answer it via `cmux send` + `cmux send-key ... enter`.

When the workers live in a coordinator-created workspace, the coordinator tab sits first (`--index 0`) and workers follow in the order the user will read them — `reorder-surface` inside that workspace, same as the "Reordering tabs" rules.

## Reordering tabs

When presenting a batch of tabs, order them in cmux to match the reading order the user works through — the tabs then *are* the to-do list:

```bash
cmux reorder-surface --surface <surface-ref> --index <n> --workspace <ref>
```

The coordinator session stays first (`--index 0` is its usual position), then the reading order: answers someone is waiting on first, then review-gated merges by urgency (audit/security first), then finished-work housekeeping. Reorder one surface per command; existing tabs shift to make room. Pair it with a table in your reply: order, tab name, status, why it's in that position.

## Refs survive only as long as the app

Workspace/surface refs (`workspace:26`, `surface:241`) are runtime IDs — **a cmux or machine restart rotates every one of them** (`workspace:26` → `workspace:1000000011`). After any restart: re-run `cmux identify` (caller's workspace) and `cmux workspace list` / `cmux tree`, then re-map tabs by *name* — names survive restarts, refs do not. If tabs came back empty (bare shell instead of the opencode TUI), that is the `cmux-session-restore` skill's territory.

## Closing a tab — only on explicit request

Never close a tab or end an agent session on your own initiative — not when the agent reports it is done, not when the PR it reviewed merges, not to "clean up" a busy workspace. Tabs are cheap; the user decides when one dies. The report in a finished tab is still readable (its report file in the run dir, `read-screen` for the on-screen verdict, or the user scrolls it), and a merged PR can still need follow-ups, so a premature close destroys work the user has not seen yet.

Close only when the user explicitly asks ("close the tab for PR 4302", "this tab is done, close it", "shut down the agent that reviewed X"). A vague "clean this up" is not explicit — ask which tabs first.

When the user does ask:

1. **Verify the tab is actually done** before closing, so you never kill a running agent:
   ```bash
   cmux read-screen --workspace <ref> --surface <surface-ref> --lines 12
   ```
   Done looks like: a final report/verdict in the transcript, a fresh `Build · <model> · <duration> · <tok/s>` line with nothing after it, and no `esc interrupt`/`↓ N shells` activity indicator. Still-working looks like: a spinner or climbing token counter (`K (N%) · $X.XX` with a shell indicator).
   If the user asks to close a tab whose agent is still running, say so and ask whether to interrupt it anyway.
2. **Close it**:
   ```bash
   cmux close-surface --surface <surface-ref> --workspace <ref>
   # → Error: confirmation_required: Surface has a running process; retry with force=true
   # An idle opencode TUI still counts as a running process — after step 1's verification,
   # close with force:
   cmux close-surface --surface <surface-ref> --workspace <ref> --force true
   # → OK surface:NNN workspace:NN
   ```
3. **Confirm with `cmux tree`** that the tab is gone from the workspace.

Leave the tab's worktree in place unless the user asks for its removal too — the PR it reviewed may still be open, and re-creating a worktree costs more than leaving it.
