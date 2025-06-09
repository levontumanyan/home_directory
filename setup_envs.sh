DOTFILES_DIR="$HOME/home_directory"
BACKUP_DATE_DIR=$(ls -dt "$HOME"/dotfiles_backup_* 2>/dev/null | head -n 1)
DOTFILES=".zshrc env.zsh completions.zsh aliases.zsh"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%d_%m_%Y_%H:%M:%S)"
