autoload -Uz colors && colors
setopt PROMPT_SUBST

# Load zsh built-in stat for zero-fork inode lookups
zmodload -F zsh/stat b:zstat 2>/dev/null

# ── kube context (fast awk + disk-cached) ─────────────────────────────────────
_kube_ps1=""
_kube_ps1_cfg=""
_kube_ps1_mtime=""

_ps1_update_kube() {
	local cfg="${KUBECONFIG:-$HOME/.kube/config}"

	# 1. Immediate exit if config does not exist
	if [[ ! -f "$cfg" ]]; then
		_kube_ps1=""
		_kube_ps1_cfg=""
		_kube_ps1_mtime=""
		return
	fi

	# 2. Fast mtime check (built-in zstat takes 0.005ms, no fork)
	local mtime
	if (( $+builtins[zstat] )); then
		mtime=$(zstat +mtime "$cfg" 2>/dev/null)
	else
		mtime=$(stat -f %m "$cfg" 2>/dev/null || stat -c %Y "$cfg" 2>/dev/null)
	fi

	# 3. In-memory hit: exact same file and mtime in current shell session
	[[ "$cfg" == "$_kube_ps1_cfg" && "$mtime" == "$_kube_ps1_mtime" ]] && return

	local ctx="" ns=""

	# 4. Multi-file KUBECONFIG (colon-separated list): delegate to kubectl
	if [[ "$cfg" == *:* ]]; then
		if command -v kubectl >/dev/null 2>&1; then
			ctx=$(kubectl config current-context 2>/dev/null) || { _kube_ps1=""; return; }
			ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
			[[ -z "$ns" ]] && ns="default"
		else
			_kube_ps1=""; return
		fi
	else
		# 5. Shared disk cache lookup (resolves new tabs in <0.1ms with 0 forks)
		local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
		local cache_file="$cache_dir/kube_${cfg//\//_}"
		local c_mtime c_ctx c_ns

		if [[ -f "$cache_file" ]]; then
			IFS=: read -r c_mtime c_ctx c_ns < "$cache_file" 2>/dev/null
			if [[ "$c_mtime" == "$mtime" && -n "$c_ctx" ]]; then
				ctx="$c_ctx"
				ns="$c_ns"
			fi
		fi

		# 6. Cache miss or config updated: parse YAML with fast awk (~1.5ms)
		if [[ -z "$ctx" ]]; then
			local parsed
			parsed=$(awk '
				BEGIN { cur = ""; name = ""; ns = ""; in_ctxs = 0; ext = 0 }
				/^current-context:[ \t]*/ { val = $0; sub(/^current-context:[ \t]*/, "", val); gsub(/["'\''\r]/, "", val); cur = val }
				/^contexts:[ \t]*/ { in_ctxs = 1; next }
				in_ctxs && /^[a-zA-Z0-9_-]+:/ { if (name != "") ns_map[name] = ns; in_ctxs = 0 }
				in_ctxs {
					if ($0 ~ /^[ \t]*- (context|name):/) { if (name != "") ns_map[name] = ns; name = ""; ns = ""; ext = 0 }
					if ($0 ~ /^[ \t]*extensions:[ \t]*/) ext = 1
					if (ext == 1 && $0 ~ /^[ \t]*(context|name|namespace|user|cluster):/) ext = 0
					if (!ext) {
						if ($0 ~ /^[ \t]*(- )?name:[ \t]*/) { val = $0; sub(/^[ \t]*(- )?name:[ \t]*/, "", val); gsub(/["'\''\r]/, "", val); name = val }
						else if ($0 ~ /^[ \t]*namespace:[ \t]*/) { val = $0; sub(/^[ \t]*namespace:[ \t]*/, "", val); gsub(/["'\''\r]/, "", val); ns = val }
					}
				}
				END {
					if (in_ctxs && name != "") ns_map[name] = ns
					if (cur != "") {
						t_ns = ns_map[cur]; if (t_ns == "") t_ns = "default"
						print cur ":" t_ns
					}
				}
			' "$cfg" 2>/dev/null)

			if [[ -n "$parsed" ]]; then
				ctx="${parsed%%:*}"
				ns="${parsed#*:}"
			elif command -v kubectl >/dev/null 2>&1; then
				ctx=$(kubectl config current-context 2>/dev/null) || { _kube_ps1=""; return; }
				ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
				[[ -z "$ns" ]] && ns="default"
			fi

			if [[ -n "$ctx" ]]; then
				[[ ! -d "$cache_dir" ]] && mkdir -p "$cache_dir" 2>/dev/null
				printf '%s:%s:%s\n' "$mtime" "$ctx" "$ns" > "$cache_file" 2>/dev/null
			fi
		fi
	fi

	[[ -z "$ctx" ]] && { _kube_ps1=""; _kube_ps1_cfg=""; _kube_ps1_mtime=""; return; }
	_kube_ps1_cfg="$cfg"
	_kube_ps1_mtime="$mtime"
	ctx="${ctx##*/}"
	_kube_ps1="%{${fg_bold[cyan]}%}[$ctx:$ns]%{${reset_color}%}"
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
				_git_ps1=" %{${fg_bold[magenta]}%}(${head#ref: refs/heads/})%{${reset_color}%}"
			else
				_git_ps1=" %{${fg_bold[magenta]}%}(${head:0:7})%{${reset_color}%}"
			fi
			return
		fi
		dir="${dir:h}"
	done
	_git_ps1=""
}

precmd_functions+=(_ps1_update_git)

# ── iterm title ───────────────────────────────────────────────────────────────
# Function to send title escape sequence to iTerm2
set_iterm_title() {
	# %~ displays the current path, shortening home to ~
	print -Pn "\e]1;%~\a"
}

# Hooks the function into the zsh prompt cycle
precmd_functions+=(set_iterm_title)

# ── prompt ────────────────────────────────────────────────────────────────────
PROMPT='%{${fg_bold[green]}%}[%m]%{${reset_color}%} %{${fg_bold[red]}%}➜%{${reset_color}%} %{${fg_bold[yellow]}%}%~%{${reset_color}%}${_git_ps1}
${_kube_ps1:+${_kube_ps1} }$ '
