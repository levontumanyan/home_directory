#!/usr/bin/env sh

set -euox

printf "Is this a work or personal machine? [work/personal]: "
read -r MACHINE_TYPE
case "$MACHINE_TYPE" in
  work|personal) ;;
  *) echo "Invalid choice. Please enter 'work' or 'personal'."; exit 1 ;;
esac
export MACHINE_TYPE

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
# work.zsh is excluded here and handled separately below
find "$DOTFILES_DIR/dotfiles" -type f ! -name "work.zsh" | while read -r dot_file; do
  echo "linking dotfile: $dot_file"
  ln -sfnv "$dot_file" "$HOME/$(basename "$dot_file")"
done

# symlink work.zsh only on work machines
if [ "$MACHINE_TYPE" = "work" ]; then
  ln -sfnv "$DOTFILES_DIR/dotfiles/work.zsh" "$HOME/work.zsh"
fi

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
