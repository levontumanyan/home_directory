# Get the directory of this script (~/.zshrc)
ZSH_DIR=${0:A:h}

# do some setup stuff
[ -f ~/setup.sh ] && sh ~/setup.sh

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# how words are deleted with option
autoload -U select-word-style
select-word-style bash

source "$ZSH_DIR/completions.zsh"
source "$ZSH_DIR/env.zsh"
source "$ZSH_DIR/aliases.zsh"

# source "$ZSH_DIR/functions.zsh"

# Load plugins or theme
# source "$ZSH_DIR/plugins/myplugin.zsh"
# source "$ZSH_DIR/themes/mytheme.zsh"

# fortune | cowsay
