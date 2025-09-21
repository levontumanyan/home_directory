#!/usr/bin/env sh

set -euox

# locate the backup dir
. "$(dirname "$0")/setup_envs.sh"

# find all the symlinks in home_dir that point to dotfiles and delete them
find "$HOME" -maxdepth 1 -type l | while read -r link; do
  target=$(readlink "$link")
  case "$target" in
    "$DOTFILES_DIR"/*)
      rm "$link"
      echo "Removed $link"
      ;;
  esac
done

if [ -n "$BACKUP_DIR" ]; then
	echo "Restoring backups from $BACKUP_DIR..."
	# move files from backup to homedir
	find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -exec mv {} "$HOME"/ \;
else
	echo "No backup directory found. Nothing to restore."
fi

# uninstall fzf
if [ -d "$HOME/.fzf" ]; then
	$HOME/.fzf/uninstall
	rm -rf "$HOME/.fzf"
	echo "Removed $HOME/.fzf directory."
fi

echo "Uninstall complete."

# add as part of uninstall to source back the original profile
