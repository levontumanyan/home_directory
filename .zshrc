# source env
source "$HOME/env.zsh"

[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# how words are deleted with option
autoload -U select-word-style
select-word-style bash
# WORDCHARS='*?_-[~=&;!#$%^(){}<>'

source "$HOME/completions.zsh"
source "$HOME/aliases.zsh"

# source the prompt
[ -f "$HOME/.ps1.zsh" ] && source "$HOME/.ps1.zsh"

# source "$ZSH_DIR/functions.zsh"

# Load plugins or theme
# source "$ZSH_DIR/plugins/myplugin.zsh"
# source "$ZSH_DIR/themes/mytheme.zsh"

# fortune | cowsay
