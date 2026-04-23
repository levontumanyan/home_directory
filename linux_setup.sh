#!/usr/bin/env sh

# are we on linux? exit if not
if [ "$(uname)" != "Linux" ]; then
	echo "Not Linux. Exiting."
	return 0 2>/dev/null || exit 0
fi

# install zoxide
if ! command -v zoxide >/dev/null 2>&1; then
	echo "Installing zoxide..."
	curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
	echo "zoxide already installed"
fi

# 2. Install Homebrew (if not found)
if ! command -v brew >/dev/null 2>&1; then
	echo "Installing Homebrew..."
	# Non-interactive install for Linux
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

fi

# ensure brew is in PATH (needed whether just installed or already present)
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

if [ "${MACHINE_TYPE:-personal}" = "work" ]; then
  brew bundle --file="$DOTFILES_DIR/brewfile_work"
else
  brew bundle --file="$DOTFILES_DIR/brewfile_personal"
fi
