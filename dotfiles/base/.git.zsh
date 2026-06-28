autoload -Uz add-zsh-hook

_auto_git_pull() {
	[[ "$PWD" != "$HOME/repos"* ]] && return
	git rev-parse --is-inside-work-tree &>/dev/null || return

	local branch
	branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return

	git rev-parse --verify "@{u}" &>/dev/null || return

	(git pull --ff-only 2>&1 | grep -Ev "^Already up to date\.$|^$" | while IFS= read -r line; do
		print "[git] $line"
	done) &
}

add-zsh-hook chpwd _auto_git_pull
