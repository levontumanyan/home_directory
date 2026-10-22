# Homebrew environment (pure shell, zero subshells/Ruby forks)
typeset -U path PATH fpath FPATH

local _brew_prefix=""
if [[ -d "/opt/homebrew" ]]; then
	_brew_prefix="/opt/homebrew"
elif [[ -d "/usr/local/Homebrew" || -x "/usr/local/bin/brew" ]]; then
	_brew_prefix="/usr/local"
elif [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
	_brew_prefix="/home/linuxbrew/.linuxbrew"
elif [[ -d "$HOME/.linuxbrew" ]]; then
	_brew_prefix="$HOME/.linuxbrew"
fi

if [[ -n "$_brew_prefix" ]]; then
	export HOMEBREW_PREFIX="$_brew_prefix"
	export HOMEBREW_CELLAR="$_brew_prefix/Cellar"
	if [[ -d "$_brew_prefix/Homebrew" ]]; then
		export HOMEBREW_REPOSITORY="$_brew_prefix/Homebrew"
	else
		export HOMEBREW_REPOSITORY="$_brew_prefix"
	fi
	export PATH="$_brew_prefix/bin:$_brew_prefix/sbin${PATH+:$PATH}"
	export MANPATH="$_brew_prefix/share/man${MANPATH+:$MANPATH}:"
	export INFOPATH="$_brew_prefix/share/info:${INFOPATH:-}"

	if [[ -d "$_brew_prefix/share/zsh/site-functions" ]]; then
		fpath=("$_brew_prefix/share/zsh/site-functions" $fpath)
	fi
	unset _brew_prefix
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
	PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
	PATH="$HOME/.local/bin:$PATH"
fi

# agent-tools
if [ -d "$HOME/repos/agent-tools/bin" ] ; then
	PATH="$HOME/repos/agent-tools/bin:$PATH"
fi

# Rust/Cargo (rustup sets ~/.cargo/env; brew install only creates the bin dir)
if [ -f "$HOME/.cargo/env" ]; then
	source "$HOME/.cargo/env"
elif [ -d "$HOME/.cargo/bin" ]; then
	PATH="$HOME/.cargo/bin:$PATH"
fi

# Java (openjdk is keg-only, not auto-linked by brew)
[[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/opt/openjdk/bin" ]] && PATH="$HOMEBREW_PREFIX/opt/openjdk/bin:$PATH"

# Podman as Docker drop-in — check socket existence instead of spawning podman machine inspect
if [[ "$OSTYPE" == darwin* ]]; then
	_pdm_sock="${TMPDIR%/}/podman/podman-machine-default-api.sock"
	[[ -S "$_pdm_sock" ]] && export DOCKER_HOST="unix://$_pdm_sock"
	unset _pdm_sock
fi
