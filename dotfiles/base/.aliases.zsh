# Aliases (Best for Tab Completion)
alias k='kubectl'
alias kcd='kubectl config set-context --current --namespace'
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -w'
alias kgc='kubectl config get-contexts'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
#alias kld='kubectl logs deployments/'
#alias kldf='kubectl logs -f deployments/'
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kgd='kubectl get deployments'
alias kdd='kubectl describe deployment'

kld() { kubectl logs deployments/$1; }
kldf() { kubectl logs -f deployments/$1; }

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

# over engineered history function
h() {
  fc -l -t "%F %T" -50 | awk '{
    printf "\033[36m%s %s\033[0m \033[1m%s\033[0m\n", $2, $3, substr($0, index($0,$4))
  }'
}

# sesh alias
alias s='sesh connect $(sesh list | fzf)'

alias c='claude'

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
