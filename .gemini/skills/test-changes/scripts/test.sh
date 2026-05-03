#!/usr/bin/env zsh
# shellcheck shell=bash

set -e

export AUTOMATED_EXECUTION=1

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🚀 Starting Automated Validation..."

# 1. Run installation for PERSONAL
echo "--- Testing PERSONAL profile ---"
./install.sh -m personal -t

# Validation
if [[ -L "$HOME/AGENTS.md" ]]; then
	echo -e "${GREEN}✓ ~/AGENTS.md is a symlink${NC}"
else
	echo -e "${RED}✗ ~/AGENTS.md is NOT a symlink${NC}"
	exit 1
fi

if grep -q "Personal" "$HOME/AGENTS.md" || grep -q "Agent Instructions" "$HOME/AGENTS.md"; then
	echo -e "${GREEN}✓ ~/AGENTS.md has correct content${NC}"
else
	echo -e "${RED}✗ ~/AGENTS.md has incorrect content${NC}"
	exit 1
fi

if [[ -L "$HOME/.gemini/GEMINI.md" ]]; then
	echo -e "${GREEN}✓ ~/.gemini/GEMINI.md is a symlink${NC}"
else
	echo -e "${RED}✗ ~/.gemini/GEMINI.md is NOT a symlink${NC}"
	exit 1
fi

# Cleanup personal before testing work
echo "--- Cleaning up PERSONAL ---"
stow -D --dir="dotfiles" --target="$HOME" base personal

# 2. Run installation for WORK
echo "--- Testing WORK profile ---"
./install.sh -m work -t

# Validation
if grep -q "WORK" "$HOME/AGENTS.md"; then
	echo -e "${GREEN}✓ ~/AGENTS.md switched to WORK content${NC}"
else
	echo -e "${RED}✗ ~/AGENTS.md failed to switch to WORK content${NC}"
	exit 1
fi

echo -e "\n${GREEN}⭐ All validations passed!${NC}"
