# shellcheck shell=zsh
# Must come BEFORE compinit
if command -v brew >/dev/null 2>&1; then
  FPATH="${HOME}/.zsh/completions:$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

autoload -Uz compinit
compinit -i

# Use menu selection for completions
zstyle ':completion:*' menu select

# zsh's tab completion with partial matching
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# source kubectl completions
command -v kubectl >/dev/null 2>&1 && {
	source <(kubectl completion zsh)
}

# Set up fzf key bindings and fuzzy completion
command -v fzf >/dev/null 2>&1 && {
	source <(fzf --zsh)
}

# source gh completions
command -v gh >/dev/null 2>&1 && {
	source <(gh completion -s zsh)
}

# source uv completions
command -v uv >/dev/null 2>&1 && {
  eval "$(uv generate-shell-completion zsh)"
}
