#!/usr/bin/env sh

set -euox

# locate the backup dir
. "$(dirname "$0")/setup_envs.sh"

echo "Removing dotfile symlinks from \$HOME..."
for file in $DOTFILES; do
	if [ -L "$HOME/$file" ] && [ "$(readlink "$HOME/$file")" = "$DOTFILES_DIR/$file" ]; then
	rm "$HOME/$file"
	echo "Removed $HOME/$file"
	fi
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
