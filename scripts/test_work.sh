#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck source=test_lib.sh

set -eu

export AUTOMATED_EXECUTION=1

# shellcheck disable=SC1091
. "$(dirname "$0")/test_lib.sh"

printf '%bdotfiles · work profile%b %b(Linux/%s)%b\n' \
	"$BOLD" "$NC" "$DIM" "$(uname -m)" "$NC"

run_install -m work -t

# ── 1. Base Layer Symlinks ────────────────────────────────────────────────────
section "1. Base Layer Symlinks"
assert_base_symlinks

# ── 2. OS Layer Symlinks (Linux) ──────────────────────────────────────────────
section "2. OS Layer Symlinks (Linux)"
assert_os_linux_symlinks

# ── 3. Work Profile Symlinks ──────────────────────────────────────────────────
section "3. Work Profile Symlinks"
assert_symlink "$HOME/.work.zsh" "dotfiles/profile/work/.work.zsh"
assert_symlink "$HOME/AGENTS.md" "dotfiles/profile/work/AGENTS.md"
assert_symlink "$HOME/.claude/CLAUDE.md" "dotfiles/profile/work/.claude/CLAUDE.md"
assert_realpath "$HOME/.claude/CLAUDE.md" "dotfiles/profile/work/AGENTS.md"
assert_symlink "$HOME/.gemini/GEMINI.md" "dotfiles/profile/work/.gemini/GEMINI.md"
assert_realpath "$HOME/.gemini/GEMINI.md" "dotfiles/profile/work/AGENTS.md"
assert_realpath "$HOME/AGENTS.md" "dotfiles/profile/work/AGENTS.md"
assert_symlink "$HOME/.claude/skills" "dotfiles/profile/work/.claude/skills"
assert_symlink "$HOME/.gemini/skills" "dotfiles/profile/work/.gemini/skills"
assert_symlink "$HOME/.agents/skills/gh/SKILL.md" "dotfiles/profile/work/.agents/skills/gh/SKILL.md"
assert_symlink "$HOME/.agents/skills/github-cli/SKILL.md" "dotfiles/profile/work/.agents/skills/github-cli/SKILL.md"
assert_symlink "$HOME/.agents/skills/worktree/SKILL.md" "dotfiles/profile/work/.agents/skills/worktree/SKILL.md"
assert_symlink "$HOME/.config/opencode/opencode.jsonc" "dotfiles/profile/work/.config/opencode/opencode.jsonc"

# ── 4. Work Profile Content ───────────────────────────────────────────────────
section "4. Work Profile Content"
assert_file_exists "$HOME/.work.zsh"
assert_file_absent "$HOME/.personal.zsh"
assert_not_symlink "$HOME/.personal.zsh"
assert_content "$HOME/AGENTS.md" "WORK"
assert_no_content "$HOME/AGENTS.md" "System Instruction"

summary
