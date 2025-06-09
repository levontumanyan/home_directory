#!/usr/bin/env sh

set -euox

# locate the backup dir
BACKUP_DATE_DIR=$(ls -dt "$HOME"/dotfiles_backup_* 2>/dev/null | head -n 1)
DOTFILES=".zshrc env.zsh completions.zsh aliases.zsh"

echo "Removing dotfile symlinks from \$HOME..."
for file in $DOTFILES; do
	if [ -L "$HOME/$file" ] && [ "$(readlink "$HOME/$file")" = "$DOTFILES_DIR/$file" ]; then
	rm "$HOME/$file"
	echo "Removed $HOME/$file"
	fi
done

if [ -n "$BACKUP_DATE_DIR" ]; then
	echo "Restoring backups from $BACKUP_DATE_DIR..."
	for file in $DOTFILES; do
		if [ -f "$BACKUP_DATE_DIR/$file" ]; then
			mv "$BACKUP_DATE_DIR/$file" "$HOME/$file"
			echo "Restored $HOME/$file"
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
