#!/usr/bin/env sh

set -euox

# download the repo
# rm -rf $DOTFILES_DIR/.git

# source dated backup dir, dotfiles
. "$(dirname "$0")/setup_envs.sh"

# create general backup dir
[ ! -d "$BACKUP_GENERAL_DIR" ] && mkdir -pv "$BACKUP_GENERAL_DIR"

# create dated backup dir
mkdir -pv "$BACKUP_DIR"

echo "Backing up existing dotfiles to $BACKUP_DIR"
for file in $DOTFILES; do
  if [ -f "$HOME/$file" ]; then
    mv -v "$HOME/$file" "$BACKUP_DIR/"
  fi

  # also move some other files that could be there
  for file in .zsh* .zprofile .bash* .profile; do
    if [ -f "$HOME/$file" ]; then
      mv "$HOME/$file" "$BACKUP_DIR/"
    fi
  done

  ln -sfnv "$DOTFILES_DIR/$file" "$HOME/$file"
done

# move bash related files and .profile out to the backup dir if they exist 
for file in .zsh* .zprofile .bash* .profile; do
  if [ -f "$HOME/$file" ]; then
    mv "$HOME/$file" "$BACKUP_DIR/"
  fi
done

echo "Dotfiles installed!"

echo "dotfiles dir is: $DOTFILES_DIR"
# do some setup stuff
[ -f "$DOTFILES_DIR/setup.sh" ] && zsh "$DOTFILES_DIR/setup.sh"

if command -v zsh >/dev/null 2>&1; then
  exec zsh
else
  echo "Zsh is not installed. Skipping Zsh-specific setup."
fi
