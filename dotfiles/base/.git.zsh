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

gwt() {
	git rev-parse --is-inside-work-tree &>/dev/null || { print "Not in a git repo"; return 1; }

	local selected
	selected=$(git worktree list | fzf --prompt="worktree> " \
		--preview='git -C {1} log --oneline --color=always -10' \
		--preview-window=right:60% | awk '{print $1}')

	[[ -n "$selected" ]] && cd "$selected"
}
