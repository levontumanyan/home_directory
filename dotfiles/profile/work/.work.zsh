# AWS Config Bootstrap - auto-clones repo and sources helpers
_aws_config_bootstrap() {
	local repo="${XDG_DATA_HOME:-$HOME/.local/share}/platform-cli-auth"
	if [[ ! -d "$repo" ]]; then
		echo "Setting up AWS config helpers..." >&2
		git clone --quiet https://github.com/elastic/platform-cli-auth.git "$repo" >&2 || return 1
		echo "Done! Run 'aws-config set <role>' to configure your AWS profiles." >&2
	fi
	source "$repo/aws-config/shell-helper.sh" 2>/dev/null
	source "$repo/aws-config/mfa" 2>/dev/null
}
_aws_config_bootstrap
unset -f _aws_config_bootstrap

opencode-auth-mcps() {
	local mcps
	mcps=(${(f)"$(jq -r '.mcp | keys[]' ~/.config/opencode/opencode.jsonc)"})
	for mcp in "${mcps[@]}"; do
		opencode mcp auth "$mcp"
	done
}

eck-workspace() {
	local worktree="${1:?Usage: eck-workspace <worktree-name>}"
	local base="$HOME/eck.code-workspace"
	local out_dir="$HOME/.local/share/workspaces"
	local out="${out_dir}/eck-${worktree}.code-workspace"
	mkdir -p "$out_dir"
	sed "s|/pst/|/${worktree}/|g" "$base" > "$out"
	echo "Created: $out"
	code "$out"
}

_eck-workspace() {
	local -a worktrees
	local pst_dir="$HOME/repos/platform-security-terraform/pst"
	local wt_path wt_branch wt_name
	while IFS= read -r line; do
		wt_path="${line%% *}"
		wt_branch="${line##*\[}"
		wt_branch="${wt_branch%%]*}"
		wt_name="${wt_path##*/}"
		[[ "$wt_name" == "pst" ]] && continue
		worktrees+=("${wt_name}:${wt_branch}")
	done < <(git -C "$pst_dir" worktree list 2>/dev/null)
	_describe 'worktree' worktrees
}
compdef _eck-workspace eck-workspace

[ -f "$HOME/repos/cloud/tools/vault-helper" ] && source "$HOME/repos/cloud/tools/vault-helper"

# elastic CLI completions
eval "$(elastic completion zsh)"

export ARGO_CONFIGFILE=~/.config/argo/config

alias pi='nono run --profile pi -- pi'
alias llm='claude --model claude-sonnet-4-6'
