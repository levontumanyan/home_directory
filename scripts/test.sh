#!/usr/bin/env zsh
# shellcheck shell=bash

set -e

export AUTOMATED_EXECUTION=1

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

assert_symlink() {
	local link="$1"
	local expected_target_part="$2"
	if [[ -L $link ]]; then
		local actual_target
		actual_target=$(readlink "$link")
		if [[ $actual_target == *"$expected_target_part"* ]]; then
			echo -e "${GREEN}✓ $link is a correct symlink${NC}"
		else
			echo -e "${RED}✗ $link points to $actual_target, expected something containing $expected_target_part${NC}"
			exit 1
		fi
	else
		echo -e "${RED}✗ $link is NOT a symlink${NC}"
		exit 1
	fi
}

assert_file_exists() {
	if [[ -f $1 ]]; then
		echo -e "${GREEN}✓ $1 exists${NC}"
	else
		echo -e "${RED}✗ $1 does NOT exist${NC}"
		exit 1
	fi
}

assert_not_symlink() {
	if [[ -L $1 ]]; then
		echo -e "${RED}✗ $1 should NOT be a symlink (still points to $(readlink "$1"))${NC}"
		exit 1
	else
		echo -e "${GREEN}✓ $1 is correctly NOT a symlink${NC}"
	fi
}

assert_realpath() {
	local link="$1"
	local expected_part="$2"
	local actual
	actual=$(realpath "$link" 2>/dev/null) || {
		echo -e "${RED}✗ realpath $link failed${NC}"
		exit 1
	}
	if [[ $actual == *"$expected_part"* ]]; then
		echo -e "${GREEN}✓ $link resolves to $actual${NC}"
	else
		echo -e "${RED}✗ $link resolves to $actual, expected something containing $expected_part${NC}"
		exit 1
	fi
}

echo "🚀 Starting Comprehensive Automated Validation..."

# 1. Test Conflict Handling
echo "--- Testing Conflict Handling ---"
mkdir -p "$HOME/.gemini/antigravity-cli"
echo "pre-existing-file" >"$HOME/.gemini/antigravity-cli/settings.json"
echo "pre-existing-zshrc" >"$HOME/.zshrc"

./install.sh -m personal -t -v

# Verify backups were created
BACKUP_BASE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups"
if ls "$BACKUP_BASE"/backup_*/.zshrc >/dev/null 2>&1; then
	echo -e "${GREEN}✓ Conflict backup created for .zshrc${NC}"
else
	echo -e "${RED}✗ Conflict backup NOT found for .zshrc${NC}"
	exit 1
fi
if ls "$BACKUP_BASE"/backup_*/.gemini/antigravity-cli/settings.json >/dev/null 2>&1; then
	echo -e "${GREEN}✓ Conflict backup created for nested settings.json${NC}"
else
	echo -e "${RED}✗ Conflict backup NOT found for nested settings.json${NC}"
	exit 1
fi

# 2. Test Base Symlinks
echo "--- Testing Base Symlinks ---"
assert_symlink "$HOME/.zshrc" "dotfiles/base/.zshrc"
assert_symlink "$HOME/.aliases.zsh" "dotfiles/base/.aliases.zsh"
assert_symlink "$HOME/.gitconfig" "dotfiles/base/.gitconfig"

# 3. Test Profile Symlinks
echo "--- Testing Profile Symlinks ---"
assert_symlink "$HOME/.gemini/antigravity-cli/settings.json" "dotfiles/base/.gemini/antigravity-cli/settings.json"
assert_symlink "$HOME/.claude/CLAUDE.md" "dotfiles/profile/personal/.claude/CLAUDE.md"
assert_realpath "$HOME/.claude/CLAUDE.md" "dotfiles/profile/personal/AGENTS.md"
assert_realpath "$HOME/AGENTS.md" "dotfiles/profile/personal/AGENTS.md"
assert_symlink "$HOME/.claude/skills" "dotfiles/profile/personal/.claude/skills"
assert_symlink "$HOME/.gemini/skills" "dotfiles/profile/personal/.gemini/skills"

# Verify chained symlink resolves to real content
if grep -q "System Instruction" "$HOME/.claude/CLAUDE.md"; then
	echo -e "${GREEN}✓ ~/.claude/CLAUDE.md chained symlink resolves to real content${NC}"
else
	echo -e "${RED}✗ ~/.claude/CLAUDE.md chained symlink does not resolve${NC}"
	exit 1
fi

# 4. Test Idempotency
echo "--- Testing Idempotency ---"
./install.sh -m personal -t -v
echo -e "${GREEN}✓ Second run completed successfully${NC}"
assert_symlink "$HOME/.zshrc" "dotfiles/base/.zshrc"
assert_symlink "$HOME/.claude/CLAUDE.md" "dotfiles/profile/personal/.claude/CLAUDE.md"
assert_realpath "$HOME/.claude/CLAUDE.md" "dotfiles/profile/personal/AGENTS.md"

# 6. Test Personal Profile
echo "--- Testing PERSONAL profile ---"
assert_file_exists "$HOME/.personal.zsh"
if [[ ! -f "$HOME/.work.zsh" ]]; then
	echo -e "${GREEN}✓ .work.zsh correctly NOT present${NC}"
else
	echo -e "${RED}✗ .work.zsh should NOT be present in personal profile${NC}"
	exit 1
fi
if grep -q "System Instruction" "$HOME/AGENTS.md" && ! grep -q "WORK" "$HOME/AGENTS.md"; then
	echo -e "${GREEN}✓ ~/AGENTS.md has personal content${NC}"
else
	echo -e "${RED}✗ ~/AGENTS.md content incorrect for personal${NC}"
	exit 1
fi

# Cleanup before switching
stow -D --dir="dotfiles" --target="$HOME" base
stow -D --dir="dotfiles/profile" --target="$HOME" personal
stow -D --dir="dotfiles/os" --target="$HOME" linux

# 7. Test Work Profile
echo "--- Testing WORK profile ---"
./install.sh -m work -t -v
assert_file_exists "$HOME/.work.zsh"
if grep -q "WORK" "$HOME/AGENTS.md"; then
	echo -e "${GREEN}✓ ~/AGENTS.md switched to WORK content${NC}"
else
	echo -e "${RED}✗ ~/AGENTS.md failed to switch to WORK content${NC}"
	exit 1
fi

# Verify work-only symlinks
assert_symlink "$HOME/.claude/CLAUDE.md" "dotfiles/profile/work/.claude/CLAUDE.md"
assert_realpath "$HOME/.claude/CLAUDE.md" "dotfiles/profile/work/AGENTS.md"
assert_realpath "$HOME/AGENTS.md" "dotfiles/profile/work/AGENTS.md"
assert_symlink "$HOME/.agents/skills/gh/SKILL.md" "dotfiles/profile/work/.agents/skills/gh/SKILL.md"
assert_symlink "$HOME/.claude/skills" "dotfiles/profile/work/.claude/skills"
assert_symlink "$HOME/.gemini/skills" "dotfiles/profile/work/.gemini/skills"

# Verify profile-switch cleanup
assert_not_symlink "$HOME/.personal.zsh"
assert_symlink "$HOME/.zshrc" "dotfiles/base/.zshrc"

echo -e "\n${GREEN}⭐ All comprehensive validations passed!${NC}"
