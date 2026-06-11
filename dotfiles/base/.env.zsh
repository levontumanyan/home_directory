# Homebrew
if [ -x "/opt/homebrew/bin/brew" ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
	eval "$(/usr/local/bin/brew shellenv)"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -d "$HOME/.linuxbrew" ]; then
	eval "$("$HOME"/.linuxbrew/bin/brew shellenv)"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
	PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
	PATH="$HOME/.local/bin:$PATH"
fi

# Rust/Cargo (rustup sets ~/.cargo/env; brew install only creates the bin dir)
if [ -f "$HOME/.cargo/env" ]; then
	source "$HOME/.cargo/env"
elif [ -d "$HOME/.cargo/bin" ]; then
	PATH="$HOME/.cargo/bin:$PATH"
fi

# Java (openjdk is keg-only, not auto-linked by brew)
[ -d "/opt/homebrew/opt/openjdk/bin" ] && PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Podman as Docker drop-in
if [[ "$(uname)" == "Darwin" ]] && command -v podman >/dev/null 2>&1; then
	if podman machine inspect >/dev/null 2>&1; then
		DOCKER_HOST="unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')"
	fi
fi
