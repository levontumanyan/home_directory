#!/usr/bin/env sh

set -euox

# shellcheck source=setup_envs.sh
. "$(dirname "$0")/setup_envs.sh"

if [ -z "${MACHINE_TYPE:-}" ]; then
	# Auto-recognition
	WORK_FILE="$HOME/.work.zsh"
	PERSONAL_FILE="$HOME/.personal.zsh"

	if [ -f "$WORK_FILE" ] && [ -f "$PERSONAL_FILE" ]; then
		echo "Error: Both $WORK_FILE and $PERSONAL_FILE exist. Cannot determine machine type."
		exit 1
	elif [ -f "$WORK_FILE" ]; then
		MACHINE_TYPE="work"
		echo "Auto-detected work machine (found $WORK_FILE)"
	elif [ -f "$PERSONAL_FILE" ]; then
		MACHINE_TYPE="personal"
		echo "Auto-detected personal machine (found $PERSONAL_FILE)"
	else
		prompt "Is this a work or personal machine? [work/personal]: " MACHINE_TYPE
	fi
fi

case "$MACHINE_TYPE" in
work | personal) ;;
*)
	echo "Invalid choice. Please enter 'work' or 'personal'."
	exit 1
	;;
esac

# unstow base dotfiles (all machines)
stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" -D base

# unstow work dotfiles (work machines only)
if [ "$MACHINE_TYPE" = "work" ]; then
	stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" -D work
fi

# unstow personal dotfiles (personal machines only)
if [ "$MACHINE_TYPE" = "personal" ]; then
	stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" -D personal
fi

LATEST_BACKUP=$(find "$HOME/dotfiles_backup" -maxdepth 1 -name 'backup_*' -type d 2>/dev/null | sort -r | head -1)
if [ -d "$LATEST_BACKUP" ]; then
	echo "Restoring from $LATEST_BACKUP..."
	find "$LATEST_BACKUP" -mindepth 1 -maxdepth 1 -exec mv {} "$HOME"/ \;
else
	echo "No backup found. Nothing to restore."
fi

# uninstall fzf
if [ -f "$HOME/bin/fzf" ]; then
	rm -v "$HOME/bin/fzf"
	echo "Removed $HOME/fzf."
fi

echo "Uninstall complete."

# add as part of uninstall to source back the original profile
