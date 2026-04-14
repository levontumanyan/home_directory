#!/usr/bin/env sh

set -euox

# locate the backup dir
. "$(dirname "$0")/setup_envs.sh"

# find all the symlinks in home_dir that point to dotfiles and delete them
find "$HOME" -maxdepth 1 -type l | while read -r link; do
  target=$(readlink "$link")
  case "$target" in
    "$DOTFILES_DIR"/*)
      rm "$link"
      echo "Removed $link"
      ;;
  esac
done

LATEST_BACKUP=$(ls -td "$HOME/dotfiles_backup"/backup_* 2>/dev/null | head -1)
if [ -d "$LATEST_BACKUP" ]; then
  echo "Restoring from $LATEST_BACKUP..."
  find "$LATEST_BACKUP" -mindepth 1 -maxdepth 1 -exec mv {} "$HOME"/ \;
else
  echo "No backup found. Nothing to restore."
fi

# uninstall fzf
if [ -f "$HOME/bin/fzf" ]; then
	rm -v "$HOME/bin/fzf"
	echo "Removed $HOME/fzf."
fi

echo "Uninstall complete."

# add as part of uninstall to source back the original profile
