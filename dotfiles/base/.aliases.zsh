# shellcheck shell=bash
# shellcheck disable=SC2034,SC2207
# Aliases (Best for Tab Completion)
alias k='kubectl'
alias kcd='kubectl config set-context --current --namespace'
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -w'
alias kgcm='kubectl get cm'
alias kgcmw='kubectl get cm -w'
alias kgc='kubectl config get-contexts'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kgd='kubectl get deployments'
alias kdd='kubectl describe deployment'

kld() { kubectl logs deployments/"$1"; }
kldf() { kubectl logs -f deployments/"$1"; }

_kld_deployments() {
	local -a deployments
	deployments=($(kubectl get deployments -o jsonpath='{.items[*].metadata.name}' 2>/dev/null))
	compadd -a deployments
}

compdef _kld_deployments kld
compdef _kld_deployments kldf

# exec - defaults to sh, pass bash if needed
kex()  { kubectl exec -it "$1" -- "${2:-sh}"; }

_kex_pods() {
	# This only runs when you actually hit TAB
	local -a pods
	pods=($(kubectl get pods -o jsonpath='{.items[*].metadata.name}' 2>/dev/null))
	compadd -a pods
}

compdef _kex_pods kex

alias python="python3"
alias pip="pip3"
alias tree='tree --gitignore -I ".git"'

# gpg signing makes a sound
gpg() {
	afplay /System/Library/Sounds/Tink.aiff &
	command gpg "$@"
}

# over engineered history function
h() {
	fc -l -t "%F %T" -50 | awk '{
		printf "\033[36m%s %s\033[0m \033[1m%s\033[0m\n", $2, $3, substr($0, index($0,$4))
	}'
}

# iTerm2 project setups
alias eq='open "iterm2://runscript?name=equiquant.py"'

# Dynamic LLM alias based on environment
if [ -f "$HOME/.work.zsh" ]; then
	alias llm='claude'
else
	alias llm='agy'
fi

# on machines that have only doas
sudo() {
	if command -v doas >/dev/null 2>&1; then
		doas "$@"
	else
		command sudo "$@"
	fi
}

fkill() {
	selection=$(ps -eo pid,ppid,%cpu,%mem,etime,cmd 2>/dev/null \
	|| ps -axww -o pid,ppid,%cpu,%mem,etime,command)

	selection=$(echo "$selection" | sed 1d | sort -k3 -nr \
	| fzf -m --header="Kill process")

	[ -z "$selection" ] && return

	pids=$(echo "$selection" | awk '{print $1}')

	for pid in $pids; do
		if kill -15 "$pid" 2>/dev/null; then
			echo "Killed: $pid"
		fi
	done
}

fif() {
	# {q} is the query string you type into fzf
	# {1} is the filename, {2} is the line number, {3} is the column
	fzf --ansi --disabled --query "$*" \
		--bind "start:reload(rg --column --line-number --no-heading --color=always --smart-case {q} || :)" \
		--bind "change:reload(rg --column --line-number --no-heading --color=always --smart-case {q} || :)" \
		--delimiter : \
		--preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
		--preview-window 'up,60%,border-bottom,+{2}+3/3' \
		--bind 'enter:become(code --goto {1}:{2}:{3})'
}
# In .zshrc
alias g='fif'

ff() {
	local file
	# Use fd to find files, fzf to select, and bat for the preview
	file=$(fd --type f --hidden --exclude .git | fzf --preview 'bat --color=always --style=numbers --line-range=:50 {}')

	# If a selection was made, open it in VS Code
	if [[ -n "$file" ]]; then
		code "$file"
	fi
}

alias f='ff'

# 1. The Function
ff_buffer() {
	local file
	file=$(fd --type f --hidden --exclude .git | fzf --preview 'bat --color=always --style=numbers --line-range=:50 {}')
	if [[ -n "$file" ]]; then
		LBUFFER="${LBUFFER}${file}"
	fi
	zle redisplay
}

# 2. The Widget
zle -N ff_buffer
# 3. The Keybind (CTRL-F)
bindkey '^f' ff_buffer

# Tailscale / Taildrop
alias tsend="tailscale file cp"
alias tget="tailscale file get"

# Send clipboard to a device (defaults to iphone)
tcopy() {
	local target="${1:-iphone}"
	local tmpfile
	tmpfile="/tmp/clip_$(date +%H%M%S).txt"
	pbpaste > "$tmpfile"
	tailscale file cp "$tmpfile" "${target}:"
	rm "$tmpfile"
	echo "Sent clipboard to $target"
}
