#!/usr/bin/env zsh

# are we on a macos? exit if not
if [ "$(uname)" != "Darwin" ]; then
  echo "Not macOS. Exiting."
  return 0 2>/dev/null || exit 0
fi

# install homebrew
if ! command -v brew >/dev/null 2>&1; then
	echo "Homebrew not found, installing..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	echo "Homebrew already installed"
fi

if [ "${MACHINE_TYPE:-personal}" = "work" ]; then
  brew bundle --verbose --file="$DOTFILES_DIR/brewfile_work"
else
  brew bundle --verbose --file="$DOTFILES_DIR/brewfile_personal"
fi
