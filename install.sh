#!/usr/bin/env sh

set -e

DOTFILES_DIR="$HOME/home_directory"

# download the repo
# rm -rf $DOTFILES_DIR/.git

BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d%H%M%S)"

# List your dotfiles here
DOTFILES=".zshrc env.zsh setup.sh completions.zsh aliases.zsh"

echo "Backing up existing dotfiles to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

for file in $FILES; do
  if [ -f "$HOME/$file" ]; then
    mv "$HOME/$file" "$BACKUP_DIR/"
  fi
  ln -sfn "$DOTFILES_DIR/$file" "$HOME/$file"
done

echo "Dotfiles installed!"

source $HOME/.zshrc
