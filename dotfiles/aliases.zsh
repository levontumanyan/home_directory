alias k="kubectl"
alias kgp="kubectl get pods"
alias kgpw="kubectl get pods -w"
alias kcd="kubectl config set-context --current --namespace"

alias python="python3"
alias pip="pip3"

# history alias
alias h='fc -l -t "%F %T" 1'

# sesh alias
alias s='sesh connect $(sesh list | fzf)'

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
		if kill -15 $pid 2>/dev/null; then
			echo "Killed: $pid"
		fi
	done
}
