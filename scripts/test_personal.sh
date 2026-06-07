#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck source=test_lib.sh

set -eu

export AUTOMATED_EXECUTION=1

# shellcheck disable=SC1091
. "$(dirname "$0")/test_lib.sh"

printf '%bdotfiles · personal profile%b %b(Linux/%s)%b\n' \
	"$BOLD" "$NC" "$DIM" "$(uname -m)" "$NC"

# ── 1. Conflict Handling ──────────────────────────────────────────────────────
section "1. Conflict Handling"
mkdir -p "$HOME/.gemini/antigravity-cli"
printf 'pre-existing-file\n' >"$HOME/.gemini/antigravity-cli/settings.json"
printf 'pre-existing-zshrc\n' >"$HOME/.zshrc"

run_install -m personal -t

BACKUP_BASE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups"
LOG_BASE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/logs"

if ls "$BACKUP_BASE"/backup_*/.zshrc >/dev/null 2>&1; then
	pass ".zshrc conflict backed up"
else
	die ".zshrc conflict backup not found under $BACKUP_BASE"
fi

if ls "$BACKUP_BASE"/backup_*/.gemini/antigravity-cli/settings.json >/dev/null 2>&1; then
	pass ".gemini/antigravity-cli/settings.json conflict backed up"
else
	die "nested settings.json conflict backup not found"
fi

if ls "$LOG_BASE"/install_*.log >/dev/null 2>&1; then
	pass "install log created"
else
	die "install log not found under $LOG_BASE"
fi

# ── 2. Base Layer Symlinks ────────────────────────────────────────────────────
section "2. Base Layer Symlinks"
assert_base_symlinks

# ── 3. OS Layer Symlinks (Linux) ──────────────────────────────────────────────
section "3. OS Layer Symlinks (Linux)"
assert_os_linux_symlinks

# ── 4. Personal Profile Symlinks ─────────────────────────────────────────────
section "4. Personal Profile Symlinks"
assert_symlink "$HOME/.personal.zsh" "dotfiles/profile/personal/.personal.zsh"
assert_symlink "$HOME/AGENTS.md" "dotfiles/profile/personal/AGENTS.md"
assert_symlink "$HOME/.claude/CLAUDE.md" "dotfiles/profile/personal/.claude/CLAUDE.md"
assert_realpath "$HOME/.claude/CLAUDE.md" "dotfiles/profile/personal/AGENTS.md"
assert_symlink "$HOME/.gemini/GEMINI.md" "dotfiles/profile/personal/.gemini/GEMINI.md"
assert_realpath "$HOME/.gemini/GEMINI.md" "dotfiles/profile/personal/AGENTS.md"
assert_realpath "$HOME/AGENTS.md" "dotfiles/profile/personal/AGENTS.md"
assert_symlink "$HOME/.claude/skills" "dotfiles/profile/personal/.claude/skills"
assert_symlink "$HOME/.gemini/skills" "dotfiles/profile/personal/.gemini/skills"
assert_symlink "$HOME/.agents/skills/worktree/SKILL.md" "dotfiles/profile/personal/.agents/skills/worktree/SKILL.md"
assert_content "$HOME/.claude/CLAUDE.md" "System Instruction"

# ── 5. Idempotency ───────────────────────────────────────────────────────────
section "5. Idempotency (second run)"
run_install -m personal -t
assert_symlink "$HOME/.zshrc" "dotfiles/base/.zshrc"
assert_symlink "$HOME/.claude/CLAUDE.md" "dotfiles/profile/personal/.claude/CLAUDE.md"
assert_realpath "$HOME/.claude/CLAUDE.md" "dotfiles/profile/personal/AGENTS.md"
pass "second run completed without errors"

# ── 6. Personal Profile Content ───────────────────────────────────────────────
section "6. Personal Profile Content"
assert_file_exists "$HOME/.personal.zsh"
assert_file_absent "$HOME/.work.zsh"
assert_content "$HOME/AGENTS.md" "System Instruction"
assert_no_content "$HOME/AGENTS.md" "WORK"

summary
