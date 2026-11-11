#!/usr/bin/env bash
set -euo pipefail

show_help() {
	cat <<'EOF'
Usage: setup_brave.sh [OPTIONS]

Configures Brave Browser managed enterprise policies on macOS
to disable Crypto Wallet, Rewards, Leo AI, News, and telemetry.

Options:
  -h, --help    Show this help message
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
	show_help
	exit 0
fi

if [ "$(uname)" != "Darwin" ]; then
	exit 0
fi

echo "Configuring Brave Browser debloat policies..."

defaults write com.brave.Browser BraveRewardsDisabled -bool true
defaults write com.brave.Browser BraveWalletDisabled -bool true
defaults write com.brave.Browser BraveVPNDisabled -bool true
defaults write com.brave.Browser BraveAIChatEnabled -bool false
defaults write com.brave.Browser BraveNewsDisabled -bool true
defaults write com.brave.Browser BraveP3AEnabled -bool false
defaults write com.brave.Browser BraveStatsPingEnabled -bool false
defaults write com.brave.Browser TorDisabled -bool true
defaults write com.brave.Browser IPFSEnabled -bool false
defaults write com.brave.Browser BraveTalkDisabled -bool true

echo "Brave Browser policies configured successfully."
