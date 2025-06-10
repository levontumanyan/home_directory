DOTFILES_DIR="$HOME/home_directory"
BACKUP_GENERAL_DIR="$HOME/dotfiles_backup"
LAST_BACKUP=$(ls -dt "$BACKUP_GENERAL_DIR/*" 2>/dev/null | head -n 1)
BACKUP_DIR="$BACKUP_GENERAL_DIR/$(date +%d_%m_%Y_%H:%M:%S)"
DOTFILES=".zshrc env.zsh completions.zsh aliases.zsh"
