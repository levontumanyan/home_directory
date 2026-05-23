#!/usr/bin/env bash
# shellcheck disable=SC1091

set -eu

# Detect machine type
if [ -f "$HOME/.work.zsh" ]; then
	TYPE="work"
elif [ -f "$HOME/.personal.zsh" ]; then
	TYPE="personal"
else
	exit 0
fi

TARGET_FILE="brewfile_$TYPE"

# Check if brew command is available
if ! command -v brew >/dev/null 2>&1; then
	echo "Homebrew is not installed. Skipping Brewfile dump."
	exit 0
fi

echo "Dumping Homebrew packages to $TARGET_FILE..."
# Dump using the native --no-vscode and --force flags
brew bundle dump --file="$TARGET_FILE" --no-vscode --force

# Stage the updated Brewfile so it is committed
if command -v git >/dev/null 2>&1; then
	git add "$TARGET_FILE"
	echo "Staged $TARGET_FILE"
fi
