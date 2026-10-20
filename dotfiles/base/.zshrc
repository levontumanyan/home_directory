# shellcheck shell=bash
# shellcheck disable=SC1091,SC2034
# source env
source "$HOME/.env.zsh"

# how words are deleted with option
autoload -U select-word-style
select-word-style bash
# WORDCHARS='*?_-[~=&;!#$%^(){}<>'

# double tab cycle through options
zstyle ':completion:*' menu select

source "$HOME/.completions.zsh"
source "$HOME/.aliases.zsh"
source "$HOME/.git.zsh"

# source the prompt
[ -f "$HOME/.ps1.zsh" ] && source "$HOME/.ps1.zsh"

# source "$ZSH_DIR/functions.zsh"

# Load plugins or theme
# source "$ZSH_DIR/plugins/myplugin.zsh"
# source "$ZSH_DIR/themes/mytheme.zsh"

setopt EXTENDED_HISTORY     # write timestamps to history file
setopt SHARE_HISTORY        # share history across all sessions in real time
setopt HIST_IGNORE_DUPS     # don't record duplicate consecutive entries
setopt HIST_IGNORE_ALL_DUPS # remove older duplicate entries from history
setopt HIST_FIND_NO_DUPS    # don't show dupes when searching
setopt HIST_REDUCE_BLANKS   # strip superfluous blanks

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"


export EDITOR="code --wait"
export VISUAL="code --wait"

# for inline suggestions to complete a command
[ -n "$HOMEBREW_PREFIX" ] && [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
	source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

[ -f "$HOME/.work.zsh" ] && source "$HOME/.work.zsh"
[ -f "$HOME/.personal.zsh" ] && source "$HOME/.personal.zsh"



# Added by Antigravity CLI installer
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# mimocode
[ -d "$HOME/.mimocode/bin" ] && export PATH="$HOME/.mimocode/bin:$PATH"

# Auto-resume saved iTerm2 + agy sessions on terminal restore
if [[ -o interactive ]] && [[ -n "${ITERM_SESSION_ID:-}" ]] && [[ -f "$HOME/.gemini/antigravity-cli/.restore_active" ]]; then
	if command -v agy-sessions >/dev/null 2>&1; then
		_agy_restore_cmd="$(agy-sessions zsh-hook --tty "$(tty 2>/dev/null)" 2>/dev/null)"
		if [[ -n "$_agy_restore_cmd" ]]; then
			eval "$_agy_restore_cmd"
		fi
		unset _agy_restore_cmd
	fi
fi
