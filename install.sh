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

# ensure brew is in PATH after a fresh Linux install (the pre-install eval above was a no-op)
if [ "$(uname)" = "Linux" ] && ! command -v brew >/dev/null 2>&1; then
	test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
	test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# install packages (stow is included in both Brewfiles)
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

# ensure stow is available (brew bundle above installs it; this catches skipped installs)
brew install stow

# back up any real files that would conflict with stow, preserving directory structure
backup_conflicts() {
	pkg="$1"
	find "$DOTFILES_DIR/dotfiles/$pkg" -type f | while read -r f; do
		rel="${f#$DOTFILES_DIR/dotfiles/$pkg/}"
		target="$HOME/$rel"
		if [ -e "$target" ] && [ ! -L "$target" ]; then
			mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
			mv -v "$target" "$BACKUP_DIR/$rel"
		fi
	done
}

# stow base dotfiles (all machines)
backup_conflicts base
stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" --restow base

# stow work dotfiles (work machines only)
if [ "$MACHINE_TYPE" = "work" ]; then
	backup_conflicts work
	stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" --restow work
fi

echo "Dotfiles installed!"

# do some setup stuff
[ -f "$DOTFILES_DIR/setup.sh" ] && zsh "$DOTFILES_DIR/setup.sh"

if command -v zsh >/dev/null 2>&1; then
	exec >/dev/tty 2>&1
	exec zsh
else
	echo "Zsh is not installed. Skipping Zsh-specific setup."
fi
