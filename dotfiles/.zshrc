# source env
source "$HOME/env.zsh"

[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# how words are deleted with option
autoload -U select-word-style
select-word-style bash
# WORDCHARS='*?_-[~=&;!#$%^(){}<>'

# double tab cycle through options
zstyle ':completion:*' menu select

source "$HOME/completions.zsh"
source "$HOME/aliases.zsh"

# source the prompt
[ -f "$HOME/ps1.zsh" ] && source "$HOME/ps1.zsh"

# source "$ZSH_DIR/functions.zsh"

# Load plugins or theme
# source "$ZSH_DIR/plugins/myplugin.zsh"
# source "$ZSH_DIR/themes/mytheme.zsh"

setopt SHARE_HISTORY        # share history across all sessions in real time
setopt INC_APPEND_HISTORY   # write to history file immediately, not on shell exit
setopt HIST_IGNORE_DUPS     # don't record duplicate consecutive entries
setopt HIST_IGNORE_ALL_DUPS # remove older duplicate entries from history
setopt HIST_FIND_NO_DUPS    # don't show dupes when searching
setopt HIST_REDUCE_BLANKS   # strip superfluous blanks

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

export EDITOR="code --wait"
export VISUAL="code --wait"
