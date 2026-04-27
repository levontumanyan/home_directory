# tmux + sesh

## What is this

[tmux](https://github.com/tmux/tmux) is a terminal multiplexer: it lets you run persistent terminal sessions that survive disconnects, split panes, and switch between named windows — all without leaving the terminal.

[sesh](https://github.com/joshmedeski/sesh) is a session manager built on top of tmux. It manages named project sessions defined in `sesh.toml`, integrates with zoxide (frecency-based directory history) and fzf (fuzzy finder), and provides a picker UI for quickly jumping between sessions.

In this setup the two work together:
- sesh owns the concept of "projects" — each session is a named workspace tied to a repo path
- tmux owns the runtime — panes, windows, keybindings, status bar
- fzf provides the interactive picker that bridges shell navigation and tmux session switching

---

## Config files

| File | Purpose |
|---|---|
| `dotfiles/base/.config/tmux/tmux.conf` | All tmux settings and keybindings |
| `dotfiles/base/.config/sesh/sesh.toml` | Named project sessions and window templates |
| `dotfiles/base/.zshrc` (lines 50–52) | Auto-connects to sesh on shell startup |
| `dotfiles/base/.aliases.zsh` (line 51) | Quick `s` alias for session picker |

---

## How sessions are defined (`sesh.toml`)

Four named project sessions, all following the same pattern:

```toml
[[session]]
name = "home_dir"
path = "~/repos/home_directory"
startup_command = "git pull"
preview_command = "ls ~/repos/home_directory"
windows = [ "claude", "vscode" ]
```

Each session gets two pre-configured windows (defined once at the bottom of the file):

| Window | startup_script | Effect |
|---|---|---|
| `claude` | `claude` | Opens Claude Code CLI |
| `vscode` | `code . && exit` | Opens VS Code in project root; window closes after launch |

The `startup_command = "git pull"` runs once when the session is first created, not on every attach.

---

## How the picker works

### `⌘J` (iTerm2 shortcut)

This is the primary way to open the sesh picker. It is an **iTerm2-level** keybinding (defined in iTerm2 GlobalKeyMap, not in tmux.conf). It sends the hex sequence `0x01 0x54` to the terminal, which tmux interprets as `Ctrl-A T`.

**Important:** this binding only works in iTerm2 and is not stored in the dotfiles repo. It must be re-configured manually after a fresh iTerm2 install.

### `Ctrl-A T` (tmux native)

The actual tmux binding. Opens an fzf-tmux popup (80×70% of the terminal) listing all known sessions. Inside the picker:

| Key | Action |
|---|---|
| `Ctrl-A` | Show all sources (default) |
| `Ctrl-T` | Show only active tmux sessions |
| `Ctrl-G` | Show only sesh config sessions |
| `Ctrl-X` | Show zoxide directory history |
| `Ctrl-F` | Find directories under `~` (up to depth 2) |
| `Ctrl-D` | Kill the selected session (no confirmation) |
| `Tab / Shift-Tab` | Move down/up |
| `Enter` | Connect to selected session |

### `s` alias (shell)

```zsh
alias s='sesh connect $(sesh list | fzf)'
```

A lightweight alternative when you are already at the shell prompt. Opens a plain fzf list (no popup, no preview, no icons).

---

## Auto-connect on shell startup (`.zshrc`)

```zsh
if [ -z "$TMUX" ] && command -v sesh >/dev/null 2>&1; then
    sesh connect $(pwd)
fi
```

When a new terminal window opens and you are not already inside tmux, this automatically connects to a sesh session matched to the current directory. Because new terminal windows typically open at `$HOME`, this usually creates or attaches to an ad-hoc session for `~` rather than a named project session.

---

## Relevant brew packages (`brewfile_essentials`)

| Package | Role |
|---|---|
| `tmux` | The multiplexer |
| `sesh` | Session manager |
| `fzf` | Fuzzy picker used by both the `C-a T` binding and the `s` alias |
| `zoxide` | Frecency-based dir history; powers the `Ctrl-X` filter in the picker |
| `fd` | Fast file finder; powers the `Ctrl-F` filter in the picker |

---

## Status bar

Two-line, dark background, yellow text. Shows the current session name and a quick-reference cheat sheet:

```
[session-name]  ⌘J picker  │  C-a c new window  │  C-a , rename  │  C-a s sessions  │  C-a x kill pane
               C-a 1/2/3 switch window  │  C-a n/p next/prev  │  C-a d detach  │  C-a L last session
```

Note: `⌘J picker` in the status bar refers to the iTerm2-level shortcut, not a native tmux binding.

---

## Full keybinding reference

| Key | Action |
|---|---|
| `C-a` | Prefix (replaces default `C-b`) |
| `C-a a` | Send literal prefix to nested session |
| `C-a c` | New window |
| `C-a ,` | Rename window |
| `C-a x` | Kill pane (no confirmation) |
| `C-a T` | Open sesh picker |
| `C-a s` | Built-in tmux session list |
| `C-a 1/2/3` | Switch to window by number |
| `C-a n / p` | Next / previous window |
| `C-a d` | Detach |
| `C-a L` | Switch to last session |

---

## Known issues

### 1. Auto-connect picks up `$HOME` instead of a project session

`sesh connect $(pwd)` runs at shell startup, but new terminal windows open at `~`. Since `~` is not a named session in `sesh.toml`, sesh creates an ad-hoc session named after the home directory path rather than connecting to a project. The result is a stray session that accumulates over time.

**Fix:** Either remove the auto-connect entirely and use `⌘J` / `C-a T` manually, or change the logic so it only auto-connects when `pwd` is a known project directory:

```zsh
if [ -z "$TMUX" ] && command -v sesh >/dev/null 2>&1; then
    if sesh list | grep -qF "$(basename $(pwd))"; then
        sesh connect "$(pwd)"
    fi
fi
```

Or just open the picker unconditionally so the user always chooses:

```zsh
if [ -z "$TMUX" ] && command -v sesh >/dev/null 2>&1; then
    exec sesh connect "$(sesh list | fzf --prompt 'session: ')"
fi
```

### 2. `⌘J` binding is not in the dotfiles repo

The iTerm2 keybinding that makes `⌘J` work lives in iTerm2's preferences, not in any tracked dotfile. After a fresh install the status bar hint `⌘J picker` will appear but the shortcut will not work.

**Fix:** Export the iTerm2 plist and add it back to `dotfiles/iterm/` so it gets stowed/restored automatically. The binding to recreate manually in the meantime: GlobalKeyMap → add `⌘J` → action "Send Hex Codes" → value `0x01 0x54`.

### 3. The `s` alias is inconsistent with `C-a T`

`alias s='sesh connect $(sesh list | fzf)'` lacks `--icons`, has no preview, and opens a full-screen fzf instead of a popup. It also doesn't support the filter modes (`Ctrl-T`, `Ctrl-X`, etc.).

**Fix:** Align the alias with the tmux binding or make it a thin wrapper:

```zsh
alias s='sesh connect "$(sesh list --icons | fzf --ansi --prompt "session: ")"'
```

### 4. `Ctrl-D` in picker kills sessions without confirmation

A single accidental `Ctrl-D` destroys the selected tmux session immediately. This is destructive with no undo.

**Fix:** Wrap with a confirmation prompt or map to a less collision-prone key:

```
--bind 'ctrl-d:execute(tmux kill-session -t {2..} && echo "killed {2..}")+reload(sesh list --icons)'
```

### 5. Dead config lines: `status-left` and `status-left-length`

When `set -g status 2` is active, tmux uses `status-format[N]` for the entire status line content. The `status-left` and `status-left-length` settings are not rendered.

Lines `set -g status-left-length 40` (line 9) and `set -g status-left "[#S] "` (line 15) in `tmux.conf` are dead code.

**Fix:** Remove both lines.

### 6. sesh completions not wired up in `completions.zsh`

`completions.zsh` configures completions for kubectl, fzf, gh, and uv — but not for sesh. The `sesh` CLI provides completions via `sesh completion zsh`.

**Fix:** Add to `completions.zsh`:

```zsh
command -v sesh >/dev/null 2>&1 && eval "$(sesh completion zsh)"
```
