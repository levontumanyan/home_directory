#!/usr/bin/env bash
# shellcheck source=setup_envs.sh
# shellcheck disable=SC1091

set -eu

VERBOSE=0
MACHINE_TYPE=""
brew_reply=""
MINIMAL=0

show_help() {
	echo "Usage: $0 [OPTIONS]"
	echo ""
	echo "Options:"
	echo "  -v          Enable verbose mode (show output in terminal)"
	echo "  -m TYPE     Set machine type (work or personal)"
	echo "  -y          Automatically answer 'yes' to profile brew bundle"
	echo "  -n          Automatically answer 'no' to profile brew bundle"
	echo "  -t          Testing mode (skip heavy essentials, minimal stow-only)"
	echo "  -c          Container mode (stow base only, skip OS layer and profile)"
	echo "  -h          Show this help message"
}

SKIP_ESSENTIALS=0

while getopts "vm:ynthc" opt 2>/dev/null; do
	case "$opt" in
	v) VERBOSE=1 ;;
	m) MACHINE_TYPE="$OPTARG" ;;
	y) brew_reply="y" ;;
	n) brew_reply="n" ;;
	t) SKIP_ESSENTIALS=1 ;;
	c) MINIMAL=1 ;;
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

OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')

setup_linuxbrew_path() {
	test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
	test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	return 0
}

if [ "$MINIMAL" = "0" ]; then
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
fi

# source dated backup dir, dotfiles
. "$(dirname "$0")/setup_envs.sh"

# set up logging — always write to log; show on terminal only with -v
mkdir -p "$LOG_DIR"
say "Log: $LOG_FILE"
if [ "$VERBOSE" = "1" ]; then
	exec > >(tee -a "$LOG_FILE") 2>&1
	set -x
else
	exec >>"$LOG_FILE" 2>&1
fi

echo "=== install started: $(date) ==="

# on Linux, ensure linuxbrew is in PATH before using brew
if [ "$OS_TYPE" = "linux" ]; then
	setup_linuxbrew_path
fi

# install Homebrew if missing
if [ "$SKIP_ESSENTIALS" = "0" ] && ! command -v brew >/dev/null 2>&1; then
	echo "Homebrew not found, installing..."
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
elif [ "$SKIP_ESSENTIALS" = "0" ]; then
	echo "Homebrew already installed"
fi

# ensure brew is in PATH after a fresh Linux install (the pre-install eval above was a no-op)
if [ "$OS_TYPE" = "linux" ] && ! command -v brew >/dev/null 2>&1; then
	setup_linuxbrew_path
fi

# always install essential packages
if [ "$SKIP_ESSENTIALS" = "1" ]; then
	echo "Testing mode: Skipping heavy essentials..."
	export AUTOMATED_EXECUTION=1
	if ! command -v stow >/dev/null 2>&1; then
		echo "Installing stow (required)..."
		if command -v brew >/dev/null 2>&1; then
			brew install stow
		elif command -v apk >/dev/null 2>&1; then
			sudo apk add stow
		elif command -v apt-get >/dev/null 2>&1; then
			sudo apt-get update && sudo apt-get install -y stow
		fi
	fi
elif [ "$MINIMAL" = "0" ]; then
	echo "Installing essential packages..."
	brew bundle --verbose --file="$DOTFILES_DIR/brewfile_essentials"
fi

# Linux-only native installs (skipped in test/minimal mode)
if [ "$SKIP_ESSENTIALS" = "0" ] && [ "$MINIMAL" = "0" ] && [ "$OS_TYPE" = "linux" ]; then
	if ! command -v tailscale >/dev/null 2>&1; then
		echo "Installing Tailscale natively..."
		curl -fsSL https://tailscale.com/install.sh | sh
	fi
	if ! command -v agy >/dev/null 2>&1; then
		echo "Installing Antigravity CLI..."
		curl -fsSL https://antigravity.google/cli/install.sh | bash
	fi
	# pinentry-tty: GPG passphrase entry over SSH/terminal
	if ! command -v pinentry-tty >/dev/null 2>&1; then
		echo "Installing pinentry-tty..."
		sudo apt-get install -y pinentry-tty
	fi
fi

# install profile-specific packages
if [ "$SKIP_ESSENTIALS" = "1" ] || [ "$MINIMAL" = "1" ]; then
	brew_reply="n"
fi
if [ -z "$brew_reply" ]; then
	prompt "Install profile brew packages? [Y/n]:" brew_reply
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
if [ "$SKIP_ESSENTIALS" = "0" ] && [ "$MINIMAL" = "0" ]; then
	echo "Cleaning up Homebrew..."
	brew autoremove
	brew cleanup
	brew doctor || true
fi

# back up any real files that would conflict with stow, preserving directory structure
backup_conflicts() {
	pkg="$1"
	find "$DOTFILES_DIR/dotfiles/$pkg" -type f | while read -r f; do
		rel="${f#"$DOTFILES_DIR"/dotfiles/"$pkg"/}"
		target="$HOME/$rel"
		# Only back up if it is a real file (not a symlink)
		if [ -f "$target" ] && [ ! -L "$target" ]; then
			mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
			mv -v "$target" "$BACKUP_DIR/$rel"
		fi
	done
}

# stow base dotfiles (all machines)
if [ ! -f "$HOME/.work.zsh" ] && [ ! -f "$HOME/.personal.zsh" ]; then
	say "First install: backing up any conflicting files to $BACKUP_DIR"
	backup_conflicts base
	if [ "$MINIMAL" = "0" ]; then
		backup_conflicts "os/$OS_TYPE"
		if [ "$MACHINE_TYPE" = "work" ]; then
			backup_conflicts "profile/work"
		else
			backup_conflicts "profile/personal"
		fi
	fi
fi
stow --no-folding --dir="$DOTFILES_DIR/dotfiles" --target="$HOME" --restow base

if [ "$MINIMAL" = "0" ]; then
	# stow OS-specific dotfiles
	if [ -d "$DOTFILES_DIR/dotfiles/os/$OS_TYPE" ]; then
		stow --no-folding --dir="$DOTFILES_DIR/dotfiles/os" --target="$HOME" --restow "$OS_TYPE"
	fi

	# stow profile dotfiles
	stow --no-folding --dir="$DOTFILES_DIR/dotfiles/profile" --target="$HOME" --restow "$MACHINE_TYPE"
fi

echo "Dotfiles installed!"

# do some setup stuff
[ -f "$DOTFILES_DIR/setup.sh" ] && zsh "$DOTFILES_DIR/setup.sh"

if [ -t 0 ] && [ -z "${AUTOMATED_EXECUTION:-}" ] && command -v zsh >/dev/null 2>&1; then
	echo "Installation complete! Starting Zsh..."
	# Reset stdout and stderr to the terminal (tty)
	exec >/dev/tty 2>&1
	exec zsh
fi
