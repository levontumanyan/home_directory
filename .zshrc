# source env
source "$HOME/env.zsh"

# do some setup stuff
[ -f "$HOME/setup.sh" ] && sh "$HOME/setup.sh"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# how words are deleted with option
autoload -U select-word-style
select-word-style bash

source "$HOME/completions.zsh"
source "$HOME/aliases.zsh"

# source "$ZSH_DIR/functions.zsh"

# Load plugins or theme
# source "$ZSH_DIR/plugins/myplugin.zsh"
# source "$ZSH_DIR/themes/mytheme.zsh"

# fortune | cowsay
