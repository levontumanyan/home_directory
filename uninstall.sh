#!/usr/bin/env sh

set -e

# Check if $DOTFILES_DIR is set and not empty
#if [ -n "$DOTFILES_DIR" ]; then
#  rm -r $DOTFILES_DIR
#fi

echo "Removing dotfile symlinks from \$HOME..."
for file in $FILES; do
  if [ -L "$HOME/$file" ] && [ "$(readlink "$HOME/$file")" = "$DOTFILES_DIR/$file" ]; then
    rm "$HOME/$file"
    echo "Removed $HOME/$file"
  fi
done

if [ -n "$BACKUP_DIR" ]; then
  echo "Restoring backups from $BACKUP_DIR..."
  for file in $FILES; do
    if [ -f "$BACKUP_DIR/$file" ]; then
      mv "$BACKUP_DIR/$file" "$HOME/$file"
      echo "Restored $HOME/$file"
    fi
  done
else
  echo "No backup directory found. Nothing to restore."
fi

# uninstall fzf
./.fzf/uninstall

if [ -d "$HOME/.fzf" ]; then
  rm -rf "$HOME/.fzf"
  echo "Removed $HOME/.fzf directory."
fi

echo "Uninstall complete."
