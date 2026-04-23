DOTFILES_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup/backup_$(date +%Y%m%d_%H%M%S)"
export DOTFILES_DIR BACKUP_DIR MACHINE_TYPE
