# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A macOS dotfiles and home directory configuration repo. It symlinks dotfiles from `dotfiles/` into `$HOME`, installs Homebrew packages, and sets up tools like kubectl, fzf, and zoxide.

## Key scripts

| Script | Purpose |
|---|---|
| `install.sh` | Entry point — backs up existing dotfiles, symlinks all files from `dotfiles/` to `$HOME`, then runs `macos_setup.sh` and `setup.sh` |
| `setup.sh` | One-time setup: configures git user, installs fzf to `~/bin`, optionally installs kubectl |
| `macos_setup.sh` | macOS-only: installs Homebrew (requires sudo), installs zoxide |
| `uninstall.sh` | Removes symlinks pointing to this repo, restores from backup |
| `brew_cron.sh` | Updates `brew_formulas.txt` and `brew_casks.txt` via `brew list`, commits and pushes changes |
| `setup_envs.sh` | Sourced by other scripts — defines `DOTFILES_DIR`, `BACKUP_DIR`, and `BACKUP_FILES` |

## Dotfiles (in `dotfiles/`, symlinked to `$HOME`)

- `.zshrc` — sources `env.zsh`, `completions.zsh`, `aliases.zsh`, `ps1.zsh`; configures history, zoxide, and sets `EDITOR=code --wait`
- `env.zsh` — adds `~/bin` and `~/.local/bin` to `PATH`
- `aliases.zsh` — `k=kubectl`, `kcd` for namespace switching, `python`/`pip` → `python3`/`pip3`, `sudo` falls back to `doas` if available
- `completions.zsh` — compinit, kubectl completions, fzf key bindings
- `ps1.zsh` — custom prompt: `user@host ➜ ~/dir`
- `iterm/com.googlecode.iterm2.plist` — iTerm2 settings (iTerm must be pointed at `dotfiles/iterm/` manually)

## Brew package lists

`brew_formulas.txt` and `brew_casks.txt` are auto-updated by `brew_cron.sh`. To update manually:
```sh
brew list --formula > brew_formulas.txt
brew list --cask > brew_casks.txt
```

## Known issues (from README)

- `uninstall.sh` does not remove the `.zshrc` symlink
- Restoring from backups is broken
- kubectl completions not working
- `.zshrc` can get a merge conflict after `install.sh` + `git pull` cycles
- Cron script requires SSH key setup to push

## Git commit signing

After install, configure GPG signing:
```bash
git config --global user.signingkey <YOUR_SIGNING_SUBKEY_ID>
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```
