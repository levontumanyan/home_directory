#!/bin/sh

# setup usually once

# setup fuzzy finder
command -v fzf >/dev/null 2>&1 || {
	echo "fzf not found, installing..."
	git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
	"$HOME/.fzf/install" --all
}
