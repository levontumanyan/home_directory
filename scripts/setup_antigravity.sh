#!/usr/bin/env bash
set -euo pipefail

show_help() {
	cat <<'EOF'
Usage: setup_antigravity.sh [OPTIONS]

Merges repo-managed Antigravity CLI settings into ~/.gemini/antigravity-cli/settings.json
while preserving machine-local runtime state (model and trustedWorkspaces).

Options:
  -h, --help    Show this help message
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
	show_help
	exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
	echo "Warning: jq not found. Skipping Antigravity CLI settings sync."
	exit 0
fi

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$DOTFILES_DIR/config/antigravity-cli/settings.json"
TARGET="$HOME/.gemini/antigravity-cli/settings.json"

mkdir -p "$(dirname "$TARGET")"

if [ ! -e "$TARGET" ]; then
	rm -f "$TARGET"
	jq '.' "$SOURCE" >"$TARGET"
	chmod 600 "$TARGET"
	echo "Initialized Antigravity CLI settings at $TARGET"
	exit 0
fi

tmp_file="${TARGET}.tmp.$$"
jq -s '
	.[0] as $live | .[1] as $repo |
	($live * ($repo | del(.model, .trustedWorkspaces))) + {
		model: ($live.model // $repo.model),
		trustedWorkspaces: ((($live.trustedWorkspaces // []) + ($repo.trustedWorkspaces // [])) | unique)
	}
' "$TARGET" "$SOURCE" >"$tmp_file"
chmod 600 "$tmp_file"
mv "$tmp_file" "$TARGET"

echo "Synced Antigravity CLI settings at $TARGET"
