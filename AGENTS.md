# AGENTS.md

This file provides guidance to AI coding assistants (like Antigravity and Claude Code) when working with code in this repository.

# Repository Overview

A personal cross-platform (macOS + Linux) dotfiles and home directory configuration repository. It manages dotfiles, Homebrew packages, and tool installations through symlinking and automated scripts using GNU Stow, with separate work and personal machine profiles.

# Key Scripts and Components

- **install.sh** — Entry point: detects or prompts for work/personal profile, backs up conflicting files, stows dotfiles/base (all machines) and dotfiles/work or dotfiles/personal, and installs Homebrew packages.
- **setup_envs.sh** — Sourced by all scripts: defines and exports DOTFILES_DIR, BACKUP_DIR, MACHINE_TYPE, LOG_DIR, and LOG_FILE, and provides the `prompt` helper.
- **setup.sh** — Post-installation tasks: one-time setup (git user config if not set), fzf setup, kubectl setup.
- **scripts/test.sh** — End-to-end install tests: runs install.sh twice and asserts symlinks are correct.
- **scripts/dump_brewfile.sh** — Detects machine type and dumps the correct brewfile; runs as a pre-commit hook.
- **dotfiles/** — Source of truth for dotfiles (symlinked to $HOME via stow).

# Work vs Personal Profiles

install.sh determines machine type at start. On a machine that already has `~/.work.zsh` or `~/.personal.zsh`, the type is auto-detected. Otherwise it prompts. Pass `-m work` or `-m personal` to skip the prompt entirely.

- Both profiles: dotfiles/base is stowed for all machines.
- Work only: dotfiles/work is also stowed; .zshrc sources .work.zsh automatically if present.
- Personal only: dotfiles/personal is stowed.
- Brewfiles: brewfile_work is installed on work machines, brewfile_personal on personal ones.

To manually update Brewfiles from currently installed packages:
```sh
# on a work machine
brew bundle dump --file=brewfile_work --no-vscode --force

# on a personal machine
brew bundle dump --file=brewfile_personal --no-vscode --force
```
The dump overwrites the file with everything currently installed — formulas, casks, and taps, excluding VS Code extensions. Commit and push after dumping.

# Periodic Brewfile Maintenance

A pre-commit hook (`scripts/dump_brewfile.sh`) auto-dumps the correct brewfile on every commit. Manual dumps are still needed when working on another machine or when the hook hasn't run. Check staleness with:
```sh
brew bundle check --file=brewfile_work
```
If it reports anything not in the file, run a manual dump and commit.

# Dotfiles Layout and Purpose

All files live under dotfiles/base/ unless noted. dotfiles/work/ and dotfiles/personal/ contain profile-specific files.

- **.zshrc** — Sources .env.zsh, .completions.zsh, .aliases.zsh, .ps1.zsh; configures history, zoxide, zsh-autosuggestions (brew-guarded), sesh (existence-guarded), and optionally .work.zsh or .personal.zsh.
- **.env.zsh** — Homebrew PATH setup, adds ~/bin and ~/.local/bin to PATH.
- **.aliases.zsh** — kubectl aliases, python/pip -> python3/pip3, history alias, sesh alias, fkill, doas.
- **.completions.zsh** — compinit, brew FPATH (brew-guarded), kubectl/fzf/gh/uv completions.
- **.ps1.zsh** — Custom prompt: user@host ➜ ~/dir
- **.gitconfig** — Git identity, GPG signing key, and gpg-touch-sound wrapper (pre-configured, no post-install changes needed).
- **.config/** — App config dirs: iterm/ (iTerm2 profile), sesh/ (session manager), tmux/.
- **.gemini/** — Settings and policies for Gemini / Antigravity.
- **.work.zsh** (dotfiles/work/) — Work-specific configuration: kubectl aliases, DOCKER_HOST (podman), AWS config bootstrap.
- **.personal.zsh** (dotfiles/personal/) — Marker and config file for personal machines.

# Core Development Lifecycle

## Research and Strategy
- Reproduce Issues: Before fixing bugs, reproduce them with a minimal script or manual test. Don't use the stow command directly to test a new symlink working. Run `./install.sh -t -n` to test truly e2e.
- Dependency Awareness: Always check setup_envs.sh for global variables (DOTFILES_DIR, BACKUP_DIR).

## Execution and Coding Standards
- Surgical Edits: When modifying dotfiles (e.g., .zshrc, .aliases.zsh), avoid rewriting the entire file. Use the replace tool for targeted changes.
- Idempotency: Scripts are idempotent — stow uses --restow, all optional tools are guarded, and re-installs skip backup/conflict steps. Keep them that way.
- Shell Scripting Standards: Use `set -eu` for safety where appropriate (consistent with install.sh). Prefer sh or zsh as used in existing scripts.
- Tailscale: Linux uses the native installation script instead of Homebrew to ensure proper systemd integration.
- Sudo Usage: Prefer not to use sudo as much as possible.
- Git Signing: Signing is pre-configured in .gitconfig. After install on a new machine, only import the GPG key — no git config changes needed.

# Script Prompting Conventions

install.sh redirects stdout/stderr to a log file. Any script that needs user input must use the `prompt` helper defined in setup_envs.sh, which always writes to the terminal regardless of log redirection:
```sh
prompt "Please enter a value:" varname
```
Never use plain `echo + read` for interactive prompts in scripts called from install.sh.

# Code Style

Use tabs for indentation in all files — shell scripts, Makefiles, config files, etc. The only exception is YAML, which requires spaces by spec. Never use spaces for indentation elsewhere.

# Guarding Rules

All commands that may not be present on every machine must be guarded:
- Brew-dependent: wrap with `command -v brew >/dev/null 2>&1`
- Optional tools (kubectl, fzf, sesh, zoxide, etc.): use `command -v <tool> >/dev/null 2>&1 &&`
- Optional files (`.fzf.zsh`, `.local/bin/env`, `.work.zsh`): use `[ -f <path> ] &&`

# Committing Changes

Before staging and committing, always run `make lint` first. Only proceed with the commit if lint passes cleanly.

# Git Commit Signing Configuration

GPG signing is pre-configured in `.gitconfig` (committed in dotfiles/base). After install on a new machine, the only required step is importing the GPG key — no git config changes needed.

# Known Issues and Priorities

- Log files (`~/.local/state/dotfiles/logs/`) and backup dirs (`~/.local/state/dotfiles/backups/`) accumulate with no cleanup or retention logic. Old entries must be pruned manually.
