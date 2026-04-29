#!/usr/bin/env bash

set -eu

VERBOSE=0
MACHINE_TYPE=""
brew_reply=""

show_help() {
	echo "Usage: $0 [OPTIONS]"
	echo ""
	echo "Options:"
	echo "  -v          Enable verbose mode (show output in terminal)"
	echo "  -m TYPE     Set machine type (work or personal)"
	echo "  -y          Automatically answer 'yes' to profile brew bundle"
	echo "  -n          Automatically answer 'no' to profile brew bundle"
	echo "  -h          Show this help message"
}

while getopts "vm:ynh" opt 2>/dev/null; do
	case "$opt" in
	v) VERBOSE=1 ;;
	m) MACHINE_TYPE="$OPTARG" ;;
	y) brew_reply="y" ;;
	n) brew_reply="n" ;;
	h)
		show_help
		exit 0
		;;
	*)
		show_help
		exit 1
		;;
	esac
done

if [ -z "$MACHINE_TYPE" ]; then
	# Auto-recognition
	WORK_FILE="$HOME/.work.zsh"
	PERSONAL_FILE="$HOME/.personal.zsh"

	if [ -f "$WORK_FILE" ] && [ -f "$PERSONAL_FILE" ]; then
		echo "Error: Both $WORK_FILE and $PERSONAL_FILE exist. Cannot determine machine type."
		exit 1
	elif [ -f "$WORK_FILE" ]; then
		MACHINE_TYPE="work"
		echo "Auto-detected work machine (found $WORK_FILE)"
	elif [ -f "$PERSONAL_FILE" ]; then
		MACHINE_TYPE="personal"
		echo "Auto-detected personal machine (found $PERSONAL_FILE)"
	else
		printf "Is this a work or personal machine? [work/personal]: "
		read -r MACHINE_TYPE
	fi
fi

case "$MACHINE_TYPE" in
work | personal) ;;
*)
	echo "Invalid choice. Please enter 'work' or 'personal'."
	exit 1
	;;
esac
export MACHINE_TYPE

# cleanup the repo
# rm -rf $DOTFILES_DIR/.git

# source dated backup dir, dotfiles
# shellcheck source=setup_envs.sh
. "$(dirname "$0")/setup_envs.sh"

# set up logging — always write to log; show on terminal only with -v
mkdir -p "$LOG_DIR"
printf "Log: %s\n" "$LOG_FILE" >/dev/tty
if [ "$VERBOSE" = "1" ]; then
	exec > >(tee -a "$LOG_FILE") 2>&1
else
	exec >>"$LOG_FILE" 2>&1
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

# always install essential packages
echo "Installing essential packages..."
brew bundle --verbose --file="$DOTFILES_DIR/brewfile_essentials"

# install profile-specific packages
if [ -z "$brew_reply" ]; then
	printf "Install profile brew packages? [Y/n]: " >/dev/tty
	read -r brew_reply </dev/tty
fi
case "$brew_reply" in
n | N) echo "Skipping profile brew bundle" ;;
*)
	if [ "${MACHINE_TYPE:-personal}" = "work" ]; then
		brew bundle --verbose --file="$DOTFILES_DIR/brewfile_work"
	else
		brew bundle --verbose --file="$DOTFILES_DIR/brewfile_personal"
	fi
	;;
esac

# Cleanup Homebrew
echo "Cleaning up Homebrew..."
brew autoremove
brew cleanup
brew doctor || true

# back up any real files that would conflict with stow, preserving directory structure
backup_conflicts() {
	pkg="$1"
	find "$DOTFILES_DIR/dotfiles/$pkg" -type f | while read -r f; do
		rel="${f#"$DOTFILES_DIR"/dotfiles/"$pkg"/}"
		target="$HOME/$rel"
		if [ -e "$target" ] && [ ! -L "$target" ] && [ ! "$target" -ef "$f" ]; then
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

# stow personal dotfiles (personal machines only)
if [ "$MACHINE_TYPE" = "personal" ]; then
	backup_conflicts personal
	stow --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" --restow personal
fi

echo "Dotfiles installed!"

# do some setup stuff
[ -f "$DOTFILES_DIR/setup.sh" ] && zsh "$DOTFILES_DIR/setup.sh"

if command -v zsh >/dev/null 2>&1; then
	if [ -z "${AUTOMATED_EXECUTION:-}" ]; then
		exec >/dev/tty 2>&1
		exec zsh
	else
		echo "Automated execution detected. Skipping interactive zsh spawn."
	fi
else
	echo "Zsh is not installed. Skipping Zsh-specific setup."
fi
