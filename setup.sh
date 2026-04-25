#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck source=setup_envs.sh
# setup usually once
set -euo xtrace
setopt pipefail

source "$(dirname "$0")/setup_envs.sh"

# Configure git user if not already set
if [ -z "$(git config --global user.name)" ] || [ -z "$(git config --global user.email)" ]; then
	echo "Git user.name and user.email not configured."
	git_name="" git_email=""
	prompt "Please enter your git user name:" git_name
	prompt "Please enter your git email:" git_email

	git config --global user.name "$git_name"
	git config --global user.email "$git_email"
	echo "Git config set to: $git_name <$git_email>"
else
	echo "Git already configured as: $(git config --global user.name) <$(git config --global user.email)>"
fi

# create user bin
mkdir -p ~/bin
