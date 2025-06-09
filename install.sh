#!/usr/bin/env sh

set -euox pipefail

# download the repo
# rm -rf $DOTFILES_DIR/.git

# source dated backup dir, dotfiles
source ./setup_envs.sh

# create general backup dir
[ ! -d "$HOME/dotfiles_backup/" ] && mkdir -pv "$HOME/dotfiles_backup/"
# create dated backup dir
mkdir -pv "$BACKUP_DIR"

echo "Backing up existing dotfiles to $BACKUP_DIR"
for file in $DOTFILES; do
  if [ -f "$HOME/$file" ]; then
    mv -v "$HOME/$file" "$BACKUP_DIR/"
  fi
  ln -sfnv "$DOTFILES_DIR/$file" "$HOME/$file"
done

# move bash related files and .profile out to the backup dir if they exist 
for file in .bash* .profile; do
  if [ -f "$HOME/$file" ]; then
    mv "$HOME/$file" "$BACKUP_DIR/"
  fi
done

echo "Dotfiles installed!"

if command -v zsh >/dev/null 2>&1; then
  exec zsh -euox pipefail
else
  echo "Zsh is not installed. Skipping Zsh-specific setup."
fi
