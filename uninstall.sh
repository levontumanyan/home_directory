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
	# move bash related files and .profile out to the backup dir if they exist
	for file in $DOTFILES; do
		if [ -f "$BACKUP_DIR/$file" ]; then
			mv "$BACKUP_DIR/$file" "$HOME/$file"
			echo "Restored $HOME/$file"
		fi
	done

	for file in "$BACKUP_DIR"/.zsh* "$BACKUP_DIR"/.zprofile "$BACKUP_DIR"/.bash* "$BACKUP_DIR"/.profile; do
		[ -e "$file" ] && mv "$file" "$HOME/"
	done
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
