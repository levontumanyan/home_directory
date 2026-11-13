#!/usr/bin/env bash
set -euo pipefail

show_help() {
	cat <<'EOF'
Usage: setup_cmux.sh [OPTIONS]

Applies cmux terminal settings that live outside cmux.json
(Ghostty-generated config.ghostty) so they sync across machines.

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

if ! command -v cmux >/dev/null 2>&1; then
	echo "cmux not found, skipping."
	exit 0
fi

echo "Applying cmux terminal settings..."

# surface-tab-bar-font-size lives in config.ghostty, not cmux.json.
# Set via the CLI so cmux owns the file format; idempotent and reloads the app.
cmux config surface-tab-bar-font-size 14

echo "cmux settings applied successfully."
