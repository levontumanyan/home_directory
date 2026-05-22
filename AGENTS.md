# AGENTS.md

This file provides guidance to AI coding assistants (like Antigravity and Claude Code) when working with code in this repository.

# Repository Overview

A personal cross-platform (macOS + Linux) dotfiles and home directory configuration repository. It manages dotfiles, Homebrew packages, and tool installations through symlinking and automated scripts using GNU Stow, with separate work and personal machine profiles.

# Key Scripts and Components

+---------------+------------------------------------------------------------+
| Component     | Purpose                                                    |
+---------------+------------------------------------------------------------+
| install.sh    | Entry point: prompts work/personal, backs up conflicting   |
|               | files, stows dotfiles/base (all machines) and dotfiles/work|
|               | (work only), and installs Homebrew packages.               |
+---------------+------------------------------------------------------------+
| setup_envs.sh | Sourced by all scripts: defines and exports DOTFILES_DIR,  |
|               | BACKUP_DIR, MACHINE_TYPE, LOG_DIR, and LOG_FILE, and       |
|               | provides the prompt helper.                                |
+---------------+------------------------------------------------------------+
| setup.sh      | Post-installation tasks: one-time setup (configures git    |
|               | user name and email if not set), fzf setup, kubectl setup. |
+---------------+------------------------------------------------------------+
| uninstall.sh  | Cleanup: unstows dotfiles, restores most-recent backup,    |
|               | and removes fzf from ~/bin.                                |
+---------------+------------------------------------------------------------+
| dotfiles/     | Source of truth for dotfiles (symlinked to $HOME).         |
+---------------+------------------------------------------------------------+

# Work vs Personal Profiles

The install.sh script prompts at start: work or personal.
- Both: dotfiles/base is stowed for all machines.
- Work only: dotfiles/work is also stowed; .zshrc sources work.zsh automatically if present.
- Brewfiles: brewfile_work is installed on work machines, brewfile_personal on personal ones.

To update Brewfiles from currently installed packages, run on the appropriate machine:
```sh
# on a work machine
brew bundle dump --force --file=brewfile_work

# on a personal machine
brew bundle dump --force --file=brewfile_personal
```
The dump overwrites the file with everything currently installed — formulas, casks, taps, and VS Code extensions. Commit and push after dumping.

# Periodic Brewfile Maintenance

Proactively run brew bundle dump and commit the result at the start of sessions where you are working on this repo, or whenever the user mentions installing or removing a brew package. Check whether brewfile_work or brewfile_personal is stale by running:
```sh
brew bundle check --file=brewfile_work
```
If it reports anything not in the file, suggest a dump and commit.

# Dotfiles Layout and Purpose

+---------------------------+------------------------------------------------+
| File / Path               | Purpose                                        |
+---------------------------+------------------------------------------------+
| .zshrc                    | Sources env.zsh, completions.zsh, aliases.zsh, |
|                           | ps1.zsh; configures history, zoxide,           |
|                           | zsh-autosuggestions (brew-guarded), sesh       |
|                           | (existence-guarded), and optionally work.zsh.  |
+---------------------------+------------------------------------------------+
| env.zsh                   | Homebrew PATH setup, adds ~/bin and            |
|                           | ~/.local/bin to PATH.                          |
+---------------------------+------------------------------------------------+
| aliases.zsh               | kubectl aliases, python/pip -> python3/pip3,   |
|                           | history alias, sesh alias, fkill, doas.        |
+---------------------------+------------------------------------------------+
| completions.zsh           | compinit, brew FPATH (brew-guarded), and       |
|                           | kubectl/fzf/gh/uv completions.                 |
+---------------------------+------------------------------------------------+
| ps1.zsh                   | Custom prompt: user@host ➜ ~/dir               |
+---------------------------+------------------------------------------------+
| work.zsh                  | Work-specific configuration: kubectl aliases,  |
|                           | DOCKER_HOST (podman), AWS config bootstrap.    |
+---------------------------+------------------------------------------------+
| iterm/                    | iTerm2 settings plist (manually mapped).       |
+---------------------------+------------------------------------------------+
| .gemini/                  | Settings and policies for Gemini / Antigravity.|
+---------------------------+------------------------------------------------+

# Core Development Lifecycle

## Research and Strategy
- Reproduce Issues: Before fixing bugs (e.g., broken uninstall.sh or restore), reproduce them with a minimal script or manual test. Don't use the stow command directly to test a new symlink working. Run ./install.sh -t -n to test truly e2e.
- Dependency Awareness: Always check setup_envs.sh for global variables (DOTFILES_DIR, BACKUP_DIR).

## Execution and Coding Standards
- Surgical Edits: When modifying dotfiles (e.g., .zshrc, aliases.zsh), avoid rewriting the entire file. Use the replace tool for targeted changes.
- Idempotency: Ensure that installation and setup scripts are idempotent. They should be safe to run multiple times without causing duplicate entries or errors.
- Shell Scripting Standards: Use set -euox for debuggability and safety where appropriate (consistent with install.sh). Prefer sh or zsh as used in existing scripts.
- Tailscale: Linux uses the native installation script instead of Homebrew to ensure proper systemd integration.
- Sudo Usage: Prefer not to use sudo as much as possible.
- Git Signing: Post-install requires manual GPG configuration.

# Script Prompting Conventions

install.sh redirects stdout/stderr to a log file. Any script that needs user input must use the prompt helper defined in setup_envs.sh, which always writes to the terminal regardless of log redirection:
```sh
prompt "Please enter a value:" varname
```
Never use plain echo + read for interactive prompts in scripts called from install.sh.

# Code Style

Use tabs for indentation in all files — shell scripts, Makefiles, config files, etc. The only exception is YAML, which requires spaces by spec. Never use spaces for indentation elsewhere.

# Guarding Rules

All commands that may not be present on every machine must be guarded:
- Brew-dependent: wrap with `command -v brew >/dev/null 2>&1`
- Optional tools (kubectl, fzf, sesh, zoxide, etc.): use `command -v <tool> >/dev/null 2>&1 &&`
- Optional files (`.fzf.zsh`, `.local/bin/env`, `work.zsh`): use `[ -f <path> ] &&`

# Committing Changes

Before staging and committing, always run `make lint` first. Only proceed with the commit if lint passes cleanly.

# Git Commit Signing Configuration

After install, configure GPG signing:
```bash
git config --global user.signingkey <YOUR_SIGNING_SUBKEY_ID>
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

# Known Issues and Priorities

- Restoring from backups is currently broken.
- uninstall.sh does not remove the .zshrc symlink.
- Many scripts are not fully idempotent (e.g., duplicate entries in config files).
- Backups should be consolidated into one directory and cleaned up after several iterations.
