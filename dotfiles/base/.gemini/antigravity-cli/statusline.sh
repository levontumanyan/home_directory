#!/bin/bash
set -eu

# Read JSON payload from stdin
input=$(cat)

if [ -z "$input" ]; then
	exit 0
fi

# Extract fields using jq
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "Unknown Model"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# Format context percentage (remove decimal part if any)
pct=$(printf "%.0f" "$used_pct")

# Determine color for context usage
if [ "$pct" -ge 80 ]; then
	ctx_color="\033[1;31m" # Bold Red
elif [ "$pct" -ge 50 ]; then
	ctx_color="\033[1;33m" # Bold Yellow
else
	ctx_color="\033[1;32m" # Bold Green
fi

# Get current workspace directory and Git branch if available
git_info=""
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // ""')
if [ -n "$current_dir" ] && [ -d "$current_dir/.git" ]; then
	branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
	if [ -n "$branch" ]; then
		# Check if dirty
		if [ -n "$(git -C "$current_dir" status --porcelain 2>/dev/null)" ]; then
			git_info=" \033[31m(git:$branch*)\033[0m"
		else
			git_info=" \033[32m(git:$branch)\033[0m"
		fi
	fi
fi

# Build status line
# Format: [Model] | Context: XX% | (git:branch)
printf "\033[1;36m[%s]\033[0m | Context: %b%s%%\033[0m%b\n" "$model" "$ctx_color" "$pct" "$git_info"
