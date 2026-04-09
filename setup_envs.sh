DOTFILES_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup/backup_$(date +%Y%m%d_%H%M%S)"
BACKUP_FILES="~/.bash* ~/.zsh* ~/.*profile ~/.oh-my-zsh"
