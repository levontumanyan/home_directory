#!/usr/bin/env bash

set -eu

VERBOSE=0
while getopts "v" opt 2>/dev/null; do
	case "$opt" in v) VERBOSE=1 ;; esac
done

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

# set up logging — always write to log; show on terminal only with -v
mkdir -p "$LOG_DIR"
printf "Log: %s\n" "$LOG_FILE" >/dev/tty
if [ "$VERBOSE" = "1" ]; then
	exec > >(tee -a "$LOG_FILE") 2>&1
else
	exec >> "$LOG_FILE" 2>&1
fi

set -x

echo "=== install started: $(date) ==="

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

# on Linux, ensure linuxbrew is in PATH before using brew
if [ "$(uname)" = "Linux" ]; then
	test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
	test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
	echo "Homebrew not found, installing..."
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	echo "Homebrew already installed"
fi

# install packages
printf "Install brew packages? [Y/n]: " >/dev/tty
read -r brew_reply </dev/tty
case "$brew_reply" in
  n|N) echo "Skipping brew bundle" ;;
  *)
    if [ "${MACHINE_TYPE:-personal}" = "work" ]; then
      brew bundle --verbose --file="$DOTFILES_DIR/brewfile_work"
    else
      brew bundle --verbose --file="$DOTFILES_DIR/brewfile_personal"
    fi
    ;;
esac

# do some setup stuff
[ -f "$DOTFILES_DIR/setup.sh" ] && zsh "$DOTFILES_DIR/setup.sh"

if command -v zsh >/dev/null 2>&1; then
	exec zsh
else
	echo "Zsh is not installed. Skipping Zsh-specific setup."
fi
