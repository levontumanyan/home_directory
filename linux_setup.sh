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

