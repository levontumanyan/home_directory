# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A cross-platform (macOS + Linux) dotfiles and home directory configuration repo. It symlinks dotfiles from `dotfiles/` into `$HOME`, installs Homebrew packages via Brewfiles, and supports separate work and personal machine profiles.

## Key scripts

| Script | Purpose |
|---|---|
| `install.sh` | Entry point — prompts work/personal, backs up existing dotfiles, symlinks `dotfiles/` to `$HOME` (excluding `work.zsh`), symlinks `work.zsh` only on work machines, then runs platform setup scripts |
| `setup_envs.sh` | Sourced by all scripts — defines and exports `DOTFILES_DIR`, `BACKUP_DIR`, `MACHINE_TYPE` |
| `linux_setup.sh` | Linux-only: installs zoxide, installs Homebrew (linuxbrew), loads brew into PATH, runs `brew bundle` with the appropriate Brewfile |
| `setup.sh` | One-time setup: configures git user, installs fzf to `~/bin`, optionally installs kubectl |
| `uninstall.sh` | Removes symlinks pointing to this repo, restores from backup |
| `brew_cron.sh` | Commits and pushes brew list snapshots (`brew_formulas.txt`, `brew_casks.txt`) on a schedule |

## Work vs personal profiles

`install.sh` prompts at the start: `work` or `personal`.

- **Both**: all dotfiles in `dotfiles/` are symlinked except `work.zsh`
- **Work only**: `dotfiles/work.zsh` is symlinked to `~/work.zsh`; `.zshrc` sources it automatically if present
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

## Guarding rules

All commands that may not be present on every machine must be guarded:
- Brew-dependent: wrap with `command -v brew >/dev/null 2>&1`
- Optional tools (kubectl, fzf, sesh, zoxide, etc.): use `command -v <tool> >/dev/null 2>&1 &&`
- Optional files (`.fzf.zsh`, `.local/bin/env`, `work.zsh`): use `[ -f <path> ] &&`

## Known issues

- `uninstall.sh` does not remove the `.zshrc` symlink
- Restoring from backups is broken
- `.zshrc` can get a merge conflict after `install.sh` + `git pull` cycles
- `brew_cron.sh` requires SSH key setup to push

## Git commit signing

After install, configure GPG signing:
```bash
git config --global user.signingkey <YOUR_SIGNING_SUBKEY_ID>
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```
