autoload -Uz compinit
compinit -i

# Use menu selection for completions
zstyle ':completion:*' menu select

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
