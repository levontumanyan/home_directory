#!/usr/bin/env sh

set -euox

# cleanup the repo
# rm -rf $DOTFILES_DIR/.git

# source dated backup dir, dotfiles
. "$(dirname "$0")/setup_envs.sh"

# create general backup dir
[ ! -d "$BACKUP_DIR" ] && mkdir -pv "$BACKUP_DIR"

# backup some files that could be there
for file in "$HOME"/.zsh* "$HOME"/.zprofile "$HOME"/.bash* "$HOME"/.profile; do
  [ -e "$file" ] && mv -v "$file" "$BACKUP_DIR/"
done

# backup ohmyzsh
if [ -d "$HOME/.oh-my-zsh" ] && [ ! -d "$BACKUP_DIR/.oh-my-zsh" ]; then
  mv -v "$HOME/.oh-my-zsh" "$BACKUP_DIR/"
fi

echo "Backing up existing dotfiles to $BACKUP_DIR"
for file in $BACKUP_FILES; do
  if [ -e "$HOME/$file" ]; then
    mv -v "$HOME/$file" "$BACKUP_DIR/"
  fi
done

# find all the dotfiles in the corresponding directory and symlink
find $DOTFILES_DIR/dotfiles -type f | while read -r dot_file; do
  echo "linking dotfile: $dot_file"
  ln -sfnv "$dot_file" "$HOME/$(basename "$dot_file")"
done

echo "Dotfiles installed!"

# do some setup stuff
[ -f "$DOTFILES_DIR/setup.sh" ] && zsh "$DOTFILES_DIR/setup.sh"

if command -v zsh >/dev/null 2>&1; then
  exec zsh
else
  echo "Zsh is not installed. Skipping Zsh-specific setup."
fi
