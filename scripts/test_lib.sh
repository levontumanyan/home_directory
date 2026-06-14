#!/usr/bin/env zsh
# shellcheck shell=bash
# Sourced by test_personal.sh and test_work.sh — do not execute directly.

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
# shellcheck disable=SC2034
DIM='\033[2m'
NC='\033[0m'

PASS=0
FAIL=0

section() {
	printf '\n%b▸ %s%b\n' "$BOLD$CYAN" "$1" "$NC"
}

pass() {
	printf '  %b✓%b %s\n' "$GREEN" "$NC" "$1"
	PASS=$((PASS + 1))
}

fail() {
	printf '  %b✗%b %s\n' "$RED" "$NC" "$1"
	FAIL=$((FAIL + 1))
}

die() {
	printf '\n%bFATAL: %s%b\n' "$RED$BOLD" "$1" "$NC"
	exit 1
}

assert_symlink() {
	local link="$1" expected="$2"
	if [[ ! -L $link ]]; then
		fail "$link is not a symlink"
		return
	fi
	local actual
	actual=$(readlink "$link")
	if [[ $actual == *"$expected"* ]]; then
		pass "$link"
	else
		fail "$link → '$actual' (want: *$expected*)"
	fi
}

assert_not_symlink() {
	local path="$1"
	if [[ -L $path ]]; then
		fail "$path should not be a symlink (→ $(readlink "$path"))"
	else
		pass "$path not a symlink"
	fi
}

assert_file_exists() {
	if [[ -f $1 ]]; then
		pass "$1 exists"
	else
		fail "$1 does not exist"
	fi
}

assert_file_absent() {
	if [[ ! -e $1 ]]; then
		pass "$1 absent"
	else
		fail "$1 should not exist"
	fi
}

assert_realpath() {
	local link="$1" expected="$2"
	local actual
	actual=$(realpath "$link" 2>/dev/null) || {
		fail "realpath $link failed"
		return
	}
	if [[ $actual == *"$expected"* ]]; then
		pass "$link chain-resolves → *$expected*"
	else
		fail "$link resolves to '$actual' (want: *$expected*)"
	fi
}

assert_content() {
	local file="$1" pattern="$2"
	if grep -q "$pattern" "$file" 2>/dev/null; then
		pass "$file contains '$pattern'"
	else
		fail "$file missing '$pattern'"
	fi
}

assert_no_content() {
	local file="$1" pattern="$2"
	if ! grep -q "$pattern" "$file" 2>/dev/null; then
		pass "$file does not contain '$pattern'"
	else
		fail "$file should not contain '$pattern'"
	fi
}

run_install() {
	./install.sh "$@" >/dev/null 2>&1 || die "install.sh $* exited non-zero (see log for details)"
}

assert_base_symlinks() {
	assert_symlink "$HOME/.zshrc" "dotfiles/base/.zshrc"
	assert_symlink "$HOME/.aliases.zsh" "dotfiles/base/.aliases.zsh"
	assert_symlink "$HOME/.completions.zsh" "dotfiles/base/.completions.zsh"
	assert_symlink "$HOME/.env.zsh" "dotfiles/base/.env.zsh"
	assert_symlink "$HOME/.ps1.zsh" "dotfiles/base/.ps1.zsh"
	assert_symlink "$HOME/.gitconfig" "dotfiles/base/.gitconfig"
	assert_symlink "$HOME/.claude/settings.json" "dotfiles/base/.claude/settings.json"
	assert_symlink "$HOME/.claude/hooks/buildkite-guard.py" "dotfiles/base/.claude/hooks/buildkite-guard.py"
	assert_symlink "$HOME/.gemini/antigravity-cli/settings.json" "dotfiles/base/.gemini/antigravity-cli/settings.json"
	assert_symlink "$HOME/.gemini/antigravity-cli/keybindings.json" "dotfiles/base/.gemini/antigravity-cli/keybindings.json"
	assert_symlink "$HOME/.gemini/antigravity-cli/mcp_config.json" "dotfiles/base/.gemini/antigravity-cli/mcp_config.json"
	assert_symlink "$HOME/.gnupg/common.conf" "dotfiles/base/.gnupg/common.conf"
	assert_symlink "$HOME/.local/bin/github" "dotfiles/base/.local/bin/github"
	assert_symlink "$HOME/.zsh/completions/_github" "dotfiles/base/.zsh/completions/_github"
}

assert_os_linux_symlinks() {
	assert_symlink "$HOME/.gnupg/gpg-agent.conf" "dotfiles/os/linux/.gnupg/gpg-agent.conf"
	assert_symlink "$HOME/.gnupg/gpg.conf" "dotfiles/os/linux/.gnupg/gpg.conf"
}

summary() {
	printf '\n'
	if ((FAIL == 0)); then
		printf '%b⭐ All %d assertions passed.%b\n' "$GREEN$BOLD" "$PASS" "$NC"
	else
		printf '%b%d failed / %d passed%b\n' "$RED$BOLD" "$FAIL" "$PASS" "$NC"
		exit 1
	fi
}
