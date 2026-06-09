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

# source opencode completions
command -v opencode >/dev/null 2>&1 && {
	source <(opencode completion zsh)
}

# source gcloud completions
if command -v brew >/dev/null 2>&1; then
	[ -f "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc" ] && {
		source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
	}
fi

# Custom make completion to display descriptions parsed from 'target: ## description'
_make_with_desc() {
	if [[ -f Makefile || -f makefile ]]; then
		local -a targets
		targets=(${(f)"$(grep -E '^[a-zA-Z_-]+:\s*##\s*.*$' [Mm]akefile 2>/dev/null | awk 'BEGIN {FS = ":[ \t]*##[ \t]*"}; {print $1 ":" $2}')"})
		if (( ${#targets} > 0 )); then
			_describe 'make targets' targets
			return
		fi
	fi
	# Fallback to standard zsh make completion
	_make
}
compdef _make_with_desc make
