# shellcheck shell=bash
# say <message> — prints to tty if available, otherwise stderr, even when stdout is redirected to log
say() {
	if [ -c /dev/tty ] && [ -w /dev/tty ] && tty -s; then
		printf "%s\n" "$1" >/dev/tty
	else
		printf "%s\n" "$1" >&2
	fi
}

# prompt <message> <varname> — prints to tty if available, otherwise stderr, even when stdout is redirected to log
prompt() {
	if [ -c /dev/tty ] && [ -w /dev/tty ] && tty -s; then
		printf "%s " "$1" >/dev/tty
		read -r "$2" </dev/tty
	else
		printf "%s " "$1" >&2
		read -r "$2"
	fi
}

DOTFILES_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
BACKUP_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/backup_$(date +%Y%m%d_%H%M%S)"
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/logs"
LOG_FILE="$LOG_DIR/install_$(date +%Y%m%d_%H%M%S).log"
export DOTFILES_DIR BACKUP_DIR MACHINE_TYPE LOG_DIR LOG_FILE
