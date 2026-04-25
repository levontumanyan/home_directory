#!/usr/bin/env sh

set -euox

. "$(dirname "$0")/setup_envs.sh"

prompt "Is this a work or personal machine? [work/personal]: " MACHINE_TYPE
case "$MACHINE_TYPE" in
	work|personal) ;;
	*) echo "Invalid choice. Please enter 'work' or 'personal'."; exit 1 ;;
esac

# unstow base dotfiles (all machines)
stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" -D base

# unstow work dotfiles (work machines only)
if [ "$MACHINE_TYPE" = "work" ]; then
	stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" -D work
fi

LATEST_BACKUP=$(ls -td "$HOME/dotfiles_backup"/backup_* 2>/dev/null | head -1)
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
