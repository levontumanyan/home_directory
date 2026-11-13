---
name: cmux-session-restore
description: Restore opencode sessions in cmux tabs after a cmux/browser restart when some tabs come back empty. Use this skill whenever the user restarts cmux or their browser and reports tabs that "didn't restore", are "empty", "lost their session", show a bare shell instead of the opencode TUI, or when asked to check/fix/recover/restore agent tabs, bind checkpoints so tabs survive restarts, or figure out which session a tab was running. Also use proactively when resuming work after a gap if agent tabs may have died. Not for opening new tabs (see cmux-agent-tabs).
---

# cmux session restore

After a cmux or browser restart, cmux replays each terminal tab from a persisted
"checkpoint" record. Tabs whose checkpoint is missing, stale, or whose replay
failed come back as a bare shell — the opencode session still exists on disk,
only the tab lost its link to it. This skill rebuilds that link.

For opening/verifying/closing tabs in general, see the cmux-agent-tabs skill —
its Discovery, read-screen and paste mechanics apply here too.

## 1. Survey the damage

`cmux tree` shows only the **current window**. Other windows exist — probe refs
like `cmux tree --window window:1000000001` (there is no `cmux windows` command;
`cmux identify` shows the caller's window ref). For each surface, classify with:

```bash
cmux read-screen --workspace <ws> --surface <sf> --lines 20
```

- **Restored**: an opencode status bar (`Build · <model> · …`, a token/cost
  counter like `351.1K (33%) · $7.54`). Context counters well above zero mean
  the transcript loaded.
- **Failed**: `Last login: …` + a bare prompt. Sometimes the failed restore
  command is visible in the scrollback (`cmux restore opencode ses_…` followed
  by an error).
- **Crashed restore**: `Error: Standalone server exited before reporting
  readiness` — a boot race when many opencodes start at once. Just retry; it is
  transient, not corruption.

## 2. Find which session a tab should get

Three sources, in this order:

1. **cmux's own checkpoint records** — `cmux sessions list` prints
   `opencode <ses_id> workspace=<uuid> surface=<uuid> cwd=… updated=…`.
   Cross-reference the surface UUID against `cmux tree --id-format both`
   (per window). A tab whose UUID has a record here failed only its replay.
2. **tty → running process** — `cmux tree` lists `tty=ttysNNN` per surface.
   `ps -axo tty,command | grep opencode` shows `ttysNNN … --session ses_…`
   for tabs that are already running something, including freshly restored ones.
3. **opencode's own database** — session ids and titles live in
   `~/.local/share/opencode/opencode.db`, table **`session_v2`**:

   ```bash
   sqlite3 ~/.local/share/opencode/opencode.db \
     "select id, title, datetime(time_updated/1000,'unixepoch') from session_v2
      where time_updated > <epoch_ms> order by time_updated desc"
   ```

   The project dir comes from joining `project` (`s.project_id = p.id`,
   `p.worktree`). **Do not** query the legacy `session` table or the sessions
   MCP index for recent sessions — both are stale after the opencode v2
   migration (only pre-migration sessions appear there). Search by session
   title; tab names are often user renames, so confirm a fuzzy match with the
   user before restoring a wrong session into a tab.

## 3. Restore a tab

Paste the command into the tab (see cmux-agent-tabs for the paste pattern), or
type it if the user is at the keyboard:

```bash
# Path A — cmux has a checkpoint record for this surface:
cmux restore opencode <ses_id>

# Path B — no cmux record (errors with "this session has nothing to restore"):
# run from the session's project dir (tabs in the wrong cwd must cd first):
opencode --session <ses_id>
```

Then verify: `sleep 8` and `read-screen` — a loaded session shows a context
counter well above zero. On the standalone-server boot-race error, retry.

## 4. Bind checkpoints so the next restart restores cleanly

For every tab running an opencode session without a checkpoint record:

```bash
cmux surface resume set --kind opencode --name "<tab title>" \
  --checkpoint <ses_id> --cwd <session project dir> \
  -- opencode --session <ses_id>
```

Get `<ses_id>` and `<cwd>` from the live process on that tab's tty (step 2.2
plus `session_v2`), not from memory. Verify with
`cmux surface resume show --workspace <ws> --surface <sf>` — it must show a
`restore_record` with the checkpoint id, launch command, and working directory.

Caveat: CLI-set records have `auto_resume: false`; whether cmux auto-replays
them on restart is unverified — if a bound tab still comes back empty, restore
it with Path A/B (it will now have a record), and say so to the user rather
than promising the binding alone is enough.

## Pitfalls hit in practice

- **Never run `cmux restore-session` bare to "see what it does"** — it silently
  restores a saved window manifest and opens duplicate windows of everything.
  If run by mistake: find the duplicate windows with `cmux tree --window
  window:10000000NN`, salvage any tabs unique to the duplicates
  (`cmux move-surface --surface <sf> --workspace <live ws> --window <live win>`),
  then `cmux close-window --window <dup> --force` (`--force` is required once
  tabs have running processes — confirm the content is duplicated or salvaged
  first).
- **`--workspace workspace:1000000000` fails if you also pass `--window
  window:1000000000`** — omit `--window` for the first window; pass it only for
  others.
- **Plain-shell tabs have nothing to restore** — nvim tabs and bare shells
  don't carry opencode sessions; don't invent one for them.
- **Windows are the unit of duplication, tabs the unit of salvage** — a
  restored duplicate window may contain one tab the live window lost (e.g. a
  review finished during the outage); check titles before closing anything.
