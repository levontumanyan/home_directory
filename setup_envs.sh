DOTFILES_DIR="$HOME/home_directory"
LAST_BACKUP_DATE_DIR=$(ls -dt "$HOME"/dotfiles_backup_* 2>/dev/null | head -n 1)
BACKUP_GENERAL_DIR="$HOME/dotfiles_backup"
BACKUP_DIR="$BACKUP_GENERAL_DIR/$(date +%d_%m_%Y_%H:%M:%S)"
DOTFILES=".zshrc env.zsh completions.zsh aliases.zsh"
