#!/usr/bin/env sh

set -euox

# cleanup the repo
# rm -rf $DOTFILES_DIR/.git

# source dated backup dir, dotfiles
. "$(dirname "$0")/setup_envs.sh"

# create general backup dir
[ ! -d "$BACKUP_DIR" ] && mkdir -pv "$BACKUP_DIR"

# backup ohmyzsh
if [ -d "$HOME/.oh-my-zsh" ] && [ ! -d "$BACKUP_DIR/.oh-my-zsh" ]; then
  mv -v "$HOME/.oh-my-zsh" "$BACKUP_DIR/"
fi

# backup any existing files that will be overwritten by symlinks
echo "Backing up existing dotfiles to $BACKUP_DIR"
find "$DOTFILES_DIR/dotfiles" -type f | while read -r dot_file; do
  target="$HOME/$(basename "$dot_file")"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv -v "$target" "$BACKUP_DIR/"
  fi
done

# find all the dotfiles in the corresponding directory and symlink
find "$DOTFILES_DIR/dotfiles" -type f | while read -r dot_file; do
  echo "linking dotfile: $dot_file"
  ln -sfnv "$dot_file" "$HOME/$(basename "$dot_file")"
done

echo "Dotfiles installed!"

# check for macos and install macos specific things(brew)
[ -f "$DOTFILES_DIR/macos_setup.sh" ] && zsh "$DOTFILES_DIR/macos_setup.sh"

# check for linux and install linux specific things
[ -f "$DOTFILES_DIR/linux_setup.sh" ] && sh "$DOTFILES_DIR/linux_setup.sh"

# do some setup stuff
[ -f "$DOTFILES_DIR/setup.sh" ] && zsh "$DOTFILES_DIR/setup.sh"

if command -v zsh >/dev/null 2>&1; then
  exec zsh
else
  echo "Zsh is not installed. Skipping Zsh-specific setup."
fi
