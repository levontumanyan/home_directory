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

if [ -n "$LAST_BACKUP" ]; then
	echo "Restoring backups from $LAST_BACKUP..."
	# move bash related files and .profile out to the backup dir if they exist
	for file in $DOTFILES; do
		if [ -f "$LAST_BACKUP/$file" ]; then
			mv "$LAST_BACKUP/$file" "$HOME/$file"
			echo "Restored $HOME/$file"
		fi
	done

	for file in "$DOTFILES_DIR"/.zsh* "$DOTFILES_DIR"/.zprofile "$DOTFILES_DIR"/.bash* "$DOTFILES_DIR"/.profile; do
		if [ -f "$HOME/$file" ]; then
			mv "$HOME/$file" "$BACKUP_DIR/"
		fi
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
