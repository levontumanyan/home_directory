# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A cross-platform (macOS + Linux) dotfiles and home directory configuration repo. It uses GNU Stow to symlink dotfiles from `dotfiles/` into `$HOME`, installs Homebrew packages via Brewfiles, and supports separate work and personal machine profiles.

## Key scripts

| Script | Purpose |
|---|---|
| `install.sh` | Entry point — prompts work/personal, backs up conflicting files, stows `dotfiles/base` (all machines) and `dotfiles/work` (work only), installs Homebrew packages |
| `setup_envs.sh` | Sourced by all scripts — defines and exports `DOTFILES_DIR`, `BACKUP_DIR`, `MACHINE_TYPE`, `LOG_DIR`, `LOG_FILE`; defines the `prompt` helper |
| `setup.sh` | One-time setup: configures git user name and email if not set |
| `uninstall.sh` | Unstows dotfiles, restores most-recent backup, removes fzf from `~/bin` |

## Work vs personal profiles

`install.sh` prompts at the start: `work` or `personal`.

- **Both**: `dotfiles/base` is stowed for all machines
- **Work only**: `dotfiles/work` is also stowed; `.zshrc` sources `work.zsh` automatically if present
- **Brewfiles**: `brewfile_work` is installed on work machines, `brewfile_personal` on personal ones

To update Brewfiles from currently installed packages, run on the appropriate machine:
```sh
# on a work machine
brew bundle dump --force --file=brewfile_work

# on a personal machine
brew bundle dump --force --file=brewfile_personal
```

The dump overwrites the file with everything currently installed — formulas, casks, taps, and VS Code extensions. Commit and push after dumping.

## Periodic Brewfile maintenance (instruction for Claude)

Proactively run `brew bundle dump` and commit the result at the start of sessions where the user is working on this repo, or whenever the user mentions installing or removing a brew package. Check whether `brewfile_work` or `brewfile_personal` is stale by running `brew bundle check --file=brewfile_work` — if it reports anything not in the file, suggest a dump and commit.

## Dotfiles (in `dotfiles/`, symlinked to `$HOME`)

- `.zshrc` — sources `env.zsh`, `completions.zsh`, `aliases.zsh`, `ps1.zsh`; configures history, zoxide, zsh-autosuggestions (brew-guarded), sesh (existence-guarded), and optionally `work.zsh`
- `env.zsh` — Homebrew PATH setup, adds `~/bin` and `~/.local/bin` to `PATH`
- `aliases.zsh` — kubectl aliases, `python`/`pip` → `python3`/`pip3`, history alias, sesh alias, `fkill`, `sudo` fallback to `doas`
- `completions.zsh` — compinit, brew FPATH (brew-guarded), kubectl/fzf/gh/uv completions (all existence-guarded)
- `ps1.zsh` — custom prompt: `user@host ➜ ~/dir`
- `work.zsh` — work-specific config: kubectl aliases, `DOCKER_HOST` (podman), AWS config bootstrap; symlinked only on work machines
- `iterm/com.googlecode.iterm2.plist` — iTerm2 settings (iTerm must be pointed at `dotfiles/iterm/` manually)

## Prompting users

`install.sh` redirects stdout/stderr to a log file. Any script that needs user input must use the `prompt` helper defined in `setup_envs.sh`, which always writes to the terminal regardless of log redirection:

```sh
prompt "Please enter a value:" varname
# equivalent to: printf "..." >/dev/tty && read -r varname </dev/tty
```

Never use plain `echo` + `read` for interactive prompts in scripts called from `install.sh`.

## Code style

Use tabs for indentation in all files — shell scripts, Makefiles, config files, etc. The only exception is YAML, which requires spaces by spec. Never use spaces for indentation elsewhere.

## Guarding rules

All commands that may not be present on every machine must be guarded:
- Brew-dependent: wrap with `command -v brew >/dev/null 2>&1`
- Optional tools (kubectl, fzf, sesh, zoxide, etc.): use `command -v <tool> >/dev/null 2>&1 &&`
- Optional files (`.fzf.zsh`, `.local/bin/env`, `work.zsh`): use `[ -f <path> ] &&`

## Committing

Before staging and committing, always run `make lint` first. Only proceed with the commit if lint passes cleanly.

## Known issues

- `uninstall.sh` does not remove the `.zshrc` symlink
- Restoring from backups is broken

## Git commit signing

After install, configure GPG signing:
```bash
git config --global user.signingkey <YOUR_SIGNING_SUBKEY_ID>
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```
