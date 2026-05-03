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

echo "🚀 Starting Comprehensive Automated Validation..."

# 1. Test Conflict Handling
echo "--- Testing Conflict Handling ---"
mkdir -p "$HOME/.gemini"
echo "pre-existing-file" >"$HOME/.gemini/settings.json"
echo "pre-existing-zshrc" >"$HOME/.zshrc"

./install.sh -m personal -t

# Verify backups were created
if ls "$HOME"/dotfiles_backup/backup_*/.zshrc >/dev/null 2>&1; then
	echo -e "${GREEN}✓ Conflict backup created for .zshrc${NC}"
else
	echo -e "${RED}✗ Conflict backup NOT found for .zshrc${NC}"
	exit 1
fi

# 2. Test Base Symlinks
echo "--- Testing Base Symlinks ---"
assert_symlink "$HOME/.zshrc" "dotfiles/base/.zshrc"
assert_symlink "$HOME/.aliases.zsh" "dotfiles/base/.aliases.zsh"
assert_symlink "$HOME/.gemini/settings.json" "dotfiles/base/.gemini/settings.json"
assert_symlink "$HOME/.claude/CLAUDE.md" "AGENTS.md"

# 3. Test Directory Nesting
echo "--- Testing Nested Directories ---"
assert_symlink "$HOME/.config/sesh/sesh.toml" "dotfiles/base/.config/sesh/sesh.toml"

# 4. Test Idempotency
echo "--- Testing Idempotency ---"
./install.sh -m personal -t
echo -e "${GREEN}✓ Second run completed successfully${NC}"

# 5. Test Personal Profile
echo "--- Testing PERSONAL profile ---"
assert_file_exists "$HOME/.personal.zsh"
if [[ ! -f "$HOME/.work.zsh" ]]; then
	echo -e "${GREEN}✓ .work.zsh correctly NOT present${NC}"
else
	echo -e "${RED}✗ .work.zsh should NOT be present in personal profile${NC}"
	exit 1
fi
if grep -q "Agent Instructions" "$HOME/AGENTS.md" && ! grep -q "WORK" "$HOME/AGENTS.md"; then
	echo -e "${GREEN}✓ ~/AGENTS.md has personal content${NC}"
else
	echo -e "${RED}✗ ~/AGENTS.md content incorrect for personal${NC}"
	exit 1
fi

# Cleanup before switching
stow -D --dir="dotfiles" --target="$HOME" base personal

# 6. Test Work Profile
echo "--- Testing WORK profile ---"
./install.sh -m work -t
assert_file_exists "$HOME/.work.zsh"
if grep -q "WORK" "$HOME/AGENTS.md"; then
	echo -e "${GREEN}✓ ~/AGENTS.md switched to WORK content${NC}"
else
	echo -e "${RED}✗ ~/AGENTS.md failed to switch to WORK content${NC}"
	exit 1
fi

echo -e "\n${GREEN}⭐ All comprehensive validations passed!${NC}"
