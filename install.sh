#!/usr/bin/env sh

set -e
set -x

DOTFILES_DIR="$HOME/home_directory"

# download the repo
# rm -rf $DOTFILES_DIR/.git

BACKUP_DIR="$HOME/dotfiles_backup_$(date +%d_%m_%Y_%H:%M:%S)"

# List your dotfiles here
DOTFILES=".zshrc env.zsh completions.zsh aliases.zsh"

echo "Backing up existing dotfiles to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

for file in $DOTFILES; do
  if [ -f "$HOME/$file" ]; then
    mv "$HOME/$file" "$BACKUP_DIR/"
  fi
  ln -sfn "$DOTFILES_DIR/$file" "$HOME/$file"
done

# move bash related files and .profile out to the backup dir if they exist 
for file in .bash* .profile; do
  if [ -f "$HOME/$file" ]; then
    mv "$HOME/$file" "$BACKUP_DIR/"
  fi
done

echo "Dotfiles installed!"

if command -v zsh >/dev/null 2>&1; then
  exec zsh "$0" "$@"
else
  echo "Zsh is not installed. Skipping Zsh-specific setup."
fi

source "$HOME/.zshrc"
