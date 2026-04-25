autoload -Uz colors && colors
setopt PROMPT_SUBST

# ── kube context (mtime-cached) ───────────────────────────────────────────────
_kube_ps1=""
_kube_ps1_mtime=""

_ps1_update_kube() {
	command -v kubectl >/dev/null 2>&1 || { _kube_ps1=""; return; }

	local cfg="${KUBECONFIG:-$HOME/.kube/config}"
	[[ ! -f "$cfg" ]] && { _kube_ps1=""; return; }

	local mtime
	mtime=$(stat -f %m "$cfg" 2>/dev/null || stat -c %Y "$cfg" 2>/dev/null)
	[[ "$mtime" == "$_kube_ps1_mtime" ]] && return
	_kube_ps1_mtime="$mtime"

	local ctx ns
	ctx=$(kubectl config current-context 2>/dev/null) || { _kube_ps1=""; return; }
	ctx="${ctx##*/}"
	ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
	[[ -z "$ns" ]] && ns="default"

	_kube_ps1="%{$fg_bold[cyan]%}[$ctx:$ns]%{$reset_color%}"
}

precmd_functions+=(_ps1_update_kube)

# ── git branch (pure shell, zero forks) ───────────────────────────────────────
_git_ps1=""

_ps1_update_git() {
	local dir="$PWD" head
	while [[ "$dir" != "/" ]]; do
		if [[ -f "$dir/.git/HEAD" ]]; then
			IFS= read -r head <"$dir/.git/HEAD"
			if [[ "$head" == ref:\ refs/heads/* ]]; then
				_git_ps1=" %{$fg_bold[magenta]%}(${head#ref: refs/heads/})%{$reset_color%}"
			else
				_git_ps1=" %{$fg_bold[magenta]%}(${head:0:7})%{$reset_color%}"
			fi
			return
		fi
		dir="${dir:h}"
	done
	_git_ps1=""
}

precmd_functions+=(_ps1_update_git)

# ── prompt ────────────────────────────────────────────────────────────────────
PROMPT='%{$fg_bold[red]%}➜%{$reset_color%} %{$fg_bold[yellow]%}%~%{$reset_color%}${_git_ps1}
${_kube_ps1:+${_kube_ps1} }$ '
