autoload -Uz colors && colors
setopt PROMPT_SUBST

# ── static parts ──────────────────────────────────────────────────────────────
_PS1_USER="%{$fg_bold[green]%}%n"
_PS1_HOST="%{$fg_bold[blue]%}%m"
_PS1_ARROW="%{$fg_bold[red]%}➜"
_PS1_DIR="%{$fg_bold[yellow]%}%~"
_PS1_RESET="%{$reset_color%}"

# ── kube context (mtime-cached) ───────────────────────────────────────────────
_kube_ps1=""
_kube_ps1_mtime=""

_ps1_update_kube() {
  command -v kubectl >/dev/null 2>&1 || { _kube_ps1=""; return; }

  local cfg="${KUBECONFIG:-$HOME/.kube/config}"
  [[ ! -f "$cfg" ]] && { _kube_ps1=""; return; }

  local mtime
  mtime=$(stat -f %m "$cfg" 2>/dev/null || stat -c %Y "$cfg" 2>/dev/null)
  [[ "$mtime" == "$_kube_ps1_mtime" ]] && return   # cache hit — nothing to do
  _kube_ps1_mtime="$mtime"

  local ctx ns
  ctx=$(kubectl config current-context 2>/dev/null) || { _kube_ps1=""; return; }
  ctx="${ctx##*/}"  # strip ARN prefix (e.g. arn:...:cluster/name → name)
  ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
  [[ -z "$ns" ]] && ns="default"

  _kube_ps1="%{$fg_bold[cyan]%}[$ctx:$ns]%{$reset_color%}"
}

precmd_functions+=(_ps1_update_kube)

# ── prompt ────────────────────────────────────────────────────────────────────
PROMPT='${_PS1_USER}@${_PS1_HOST} ${_PS1_ARROW} ${_PS1_DIR}
${_kube_ps1:+${_kube_ps1} }${_PS1_RESET}$ '
