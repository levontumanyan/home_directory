# AGENTS.md

This file provides guidance to AI coding assistants (like Antigravity and Claude Code) when working with code in this repository.

# Repository Overview

A personal cross-platform (macOS + Linux) dotfiles and home directory configuration repository. It manages dotfiles, Homebrew packages, and tool installations through symlinking and automated scripts using GNU Stow, with separate work and personal machine profiles.

# Stow Layer Structure

Three layers are stowed in order: `dotfiles/base/` (all machines), `dotfiles/os/<platform>/` (darwin or linux), `dotfiles/profile/<type>/` (work or personal). When adding a new dotfile, place it in the right layer — agents should not assume all dotfiles live under base.

# Work vs Personal Profiles

Profile is auto-detected at install time: if `~/.work.zsh` exists → work, if `~/.personal.zsh` exists → personal, otherwise prompts. Pass `-m work` or `-m personal` to skip. Brewfiles: brewfile_work for work machines, brewfile_personal for personal.

# Testing

Always run tests via `make test` — never run `scripts/test.sh` directly, as it must execute inside the container to avoid stowing into the real `$HOME`.

# Core Development Lifecycle

- Reproduce Issues: Before fixing bugs, run `./install.sh -t -n` to test truly e2e.
- Idempotency: Scripts are idempotent — stow uses --restow, all optional tools are guarded, re-installs skip backup/conflict steps. Keep them that way.
- Shell Scripting Standards: Use `set -eu`. Prefer sh or zsh as used in existing scripts.
- Permissions: Avoid using `chmod +x` because it grants executable permissions to everyone. Instead, grant the minimum permissions necessary (e.g., `chmod u+x` or specific octal modes like `755`/`700`).
- Tailscale: On Linux, installed natively via `curl | sh` if not already present; this runs after brew bundle so it only fires on a truly fresh machine.
- Sudo Usage: Prefer not to use sudo as much as possible.
- Git Signing: Only import the GPG key after install on a new machine — no git config changes needed.

# Script Prompting Conventions

install.sh redirects stdout/stderr to a log file. Use `say()` for informational output to the terminal, `prompt` for interactive input — both write to `/dev/tty` directly and bypass log redirection. Never use plain `echo + read`.

# Guarding Rules

All commands that may not be present on every machine must be guarded:
- Brew-dependent: wrap with `command -v brew >/dev/null 2>&1`
- Optional tools (kubectl, fzf, zoxide, etc.): use `command -v <tool> >/dev/null 2>&1 &&`
- Optional files (`.fzf.zsh`, `.local/bin/env`, `.work.zsh`): use `[ -f <path> ] &&`

# Committing Changes

Before staging and committing, always run `make lint` first. Only proceed if lint passes cleanly.

# Known Issues

- Log files (`~/.local/state/dotfiles/logs/`) and backup dirs (`~/.local/state/dotfiles/backups/`) accumulate with no cleanup or retention logic. Old entries must be pruned manually.
- If `container build` fails with `runc-overlayfs` filesystem errors ("structure needs cleaning") or hostname conflicts, the container environment's builder cache or network state has become corrupted. To resolve this, stop the container system: `container system stop`, kill any lingering system processes (`pkill -f container-network-vmnet` and `pkill -f container-apiserver`), delete the builder instance (`container builder delete`), and then start the container system again (`container system start`).
