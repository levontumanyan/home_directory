#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck source=setup_envs.sh
# shellcheck disable=SC1091
# setup usually once
set -euo xtrace
setopt pipefail

if [ -n "${AUTOMATED_EXECUTION:-}" ]; then
	echo "Automated execution detected. Skipping interactive setup."
	exit 0
fi

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

# install pre-commit hooks for this repo
if command -v pre-commit >/dev/null 2>&1; then
	echo "Installing pre-commit hooks..."
	pre-commit install
fi

# Setup Tailscale service
echo "Setting up Tailscale service..."
if [ "$(uname)" = "Darwin" ]; then
	if command -v brew >/dev/null 2>&1 && brew list tailscale >/dev/null 2>&1; then
		echo "Ensuring Tailscale service is started..."
		brew services start tailscale || true
	fi
elif [ "$(uname)" = "Linux" ]; then
	if command -v systemctl >/dev/null 2>&1 && command -v tailscale >/dev/null 2>&1; then
		echo "Ensuring Tailscale service is enabled and started..."
		sudo systemctl enable --now tailscaled || true
	fi
fi
