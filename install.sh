#!/usr/bin/env sh

set -euox

# run uninstall just in case to cleanup the environment
#"$(dirname "$0")/uninstall.sh"

# just in case
rm -rf "$HOME/.oh-my-zsh/"

# cleanup the repo
# rm -rf $DOTFILES_DIR/.git

# source dated backup dir, dotfiles
. "$(dirname "$0")/setup_envs.sh"

# create general backup dir
[ ! -d "$BACKUP_DIR" ] && mkdir -pv "$BACKUP_DIR"

# create dated backup dir
mkdir -pv "$BACKUP_DIR"

echo "dotfiles are: $DOTFILES"

# backup some files that could be there
for file in "$HOME"/.zsh* "$HOME"/.zprofile "$HOME"/.bash* "$HOME"/.profile; do
  [ -e "$file" ] && mv -v "$file" "$BACKUP_DIR/"
done

echo "Backing up existing dotfiles to $BACKUP_DIR"
for file in $DOTFILES; do
  if [ -e "$HOME/$file" ]; then
    mv -v "$HOME/$file" "$BACKUP_DIR/"
  fi

  ln -sfnv "$DOTFILES_DIR/$file" "$HOME/$file"
done

# echo "Dotfiles installed!"

# # do some setup stuff
# [ -f "$DOTFILES_DIR/setup.sh" ] && zsh "$DOTFILES_DIR/setup.sh"

# if command -v zsh >/dev/null 2>&1; then
#   exec zsh
# else
#   echo "Zsh is not installed. Skipping Zsh-specific setup."
# fi
