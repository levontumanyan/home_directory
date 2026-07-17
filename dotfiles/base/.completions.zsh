# Must come BEFORE compinit
if [[ -n $HOMEBREW_PREFIX ]]; then
	FPATH="${HOME}/.zsh/completions:$HOMEBREW_PREFIX/share/zsh/site-functions:${FPATH}"
fi

autoload -Uz compinit
() {
	local dump=${ZDOTDIR:-$HOME}/.zcompdump
	if [[ -f $dump && -n $dump(#qN.mh-24) ]]; then
		compinit -iC
	else
		compinit -i
		zcompile "$dump"
	fi
}

# Use menu selection for completions
zstyle ':completion:*' menu select

# zsh's tab completion with partial matching
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Cache completions from external tools to ~/.zsh/completions/ so compinit picks
# them up via FPATH instead of spawning a subprocess on every shell start.
# Regenerates when the tool binary is newer than the cached file.
_cache_completion() {
	local name="$1" cache="${HOME}/.zsh/completions/_${1}"; shift
	command -v "$name" >/dev/null 2>&1 || return
	local bin
	bin=$(command -v "$name")
	if [[ ! -f "$cache" || "$bin" -nt "$cache" ]]; then
		mkdir -p "${HOME}/.zsh/completions"
		"$@" > "$cache" 2>/dev/null && source "$cache"
		rm -f "${ZDOTDIR:-$HOME}/.zcompdump"
	fi
}
_cache_completion kubectl kubectl completion zsh
_cache_completion gh gh completion -s zsh
_cache_completion uv uv generate-shell-completion zsh
_cache_completion opencode opencode completion zsh

# fzf sets up key bindings in addition to completions — must be sourced each time
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# gcloud completions (large static file shipped with the brew formula)
[ -n "$HOMEBREW_PREFIX" ] && [ -f "$HOMEBREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc" ] && \
	source "$HOMEBREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"

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
