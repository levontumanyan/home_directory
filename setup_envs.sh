# prompt <message> <varname> — always prints to terminal even when stdout is redirected to log
prompt() {
  printf "%s " "$1" >/dev/tty
  read -r "$2" </dev/tty
}

DOTFILES_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup/backup_$(date +%Y%m%d_%H%M%S)"
LOG_DIR="$HOME/.local/share/dotfiles/logs"
LOG_FILE="$LOG_DIR/install_$(date +%Y%m%d_%H%M%S).log"
export DOTFILES_DIR BACKUP_DIR MACHINE_TYPE LOG_DIR LOG_FILE
