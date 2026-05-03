# shellcheck shell=bash
# shellcheck disable=SC1091
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
