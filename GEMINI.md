# GEMINI.md

This file provides foundational mandates and guidance for Gemini CLI when working in the `home_directory` repository.

## Repository Overview

A personal dotfiles and macOS/Linux environment configuration repository. It manages dotfiles, Homebrew packages, and tool installations (kubectl, fzf, zoxide) through symlinking and automated scripts.

## Core Development Lifecycle

### Research & Strategy
- **Reproduce Issues:** Before fixing bugs (e.g., broken `uninstall.sh` or `restore`), reproduce them with a minimal script or manual test.
- **Dependency Awareness:** Always check `setup_envs.sh` for global variables (`DOTFILES_DIR`, `BACKUP_DIR`).
- **OS Specifics:** Distinguish between `macos_setup.sh` and `linux_setup.sh`.

### Execution
- **Surgical Edits:** When modifying dotfiles (e.g., `.zshrc`, `aliases.zsh`), avoid rewriting the entire file. Use the `replace` tool for targeted changes.
- **Idempotency:** Ensure that installation and setup scripts are idempotent. They should be safe to run multiple times without causing duplicate entries or errors.
- **Shell Scripting Standards:**
  - Use `set -euox` for debuggability and safety where appropriate (consistent with `install.sh`).
  - Prefer `sh` or `zsh` as used in existing scripts.
  - Follow existing conventions for path handling and symlinking (`ln -sfnv`).
- **Brew Management:** Use `brew_cron.sh` logic for updating package lists. Do not manually edit `brew_formulas.txt` or `brew_casks.txt` unless necessary for a specific installation task.

## Key Components

| Component | Purpose |
|---|---|
| `install.sh` | Entry point: backs up existing dotfiles, symlinks files from `dotfiles/` to `$HOME`, runs OS-specific setup. |
| `dotfiles/` | Source of truth for dotfiles (symlinked to `$HOME`). |
| `macos_setup.sh` | macOS-specific logic: Homebrew installation (requires sudo), zoxide setup. |
| `linux_setup.sh` | Linux-specific setup logic. |
| `setup.sh` | Post-installation tasks: git config, fzf installation, kubectl setup. |
| `uninstall.sh` | Cleanup: removes symlinks, attempts to restore from backup. |
| `setup_envs.sh` | Shared environment variables. |

## Important Conventions

- **Sudo Usage:** macOS setup steps (like Homebrew) often require `sudo`. Always warn or explain before running commands that use `sudo`.
- **iTerm2:** Settings are stored in `dotfiles/iterm/com.googlecode.iterm2.plist`. Users must manually point iTerm2 to this directory.
- **Git Signing:** Post-install requires manual GPG configuration (see `README.md`).

## Known Issues & Priorities

1. **Restoration:** `uninstall.sh` and general restoration from backups are currently broken.
2. **Idempotency:** Many scripts are not fully idempotent (e.g., duplicate entries in config files).
3. **Shell Completions:** `kubectl` completions may not be working correctly.
4. **Backup Management:** Backups should be consolidated into one directory and cleaned up after several iterations.
