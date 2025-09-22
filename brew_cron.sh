#!/usr/bin/env zsh

# add brew, git into path otherwise cron fails
export PATH="/opt/homebrew/bin:$PATH"
set -e

# cd into the directory where the script lives
cd "$(dirname "$0")"

BREW_FORMULAS="./brew_formulas.txt"
BREW_CASKS="./brew_casks.txt"

# Update the list
brew list --formula > "$BREW_FORMULAS"
brew list --cask > "$BREW_CASKS"

# Commit and push if there are changes
git add $BREW_FORMULAS $BREW_CASKS
if ! git diff --cached --quiet; then
    git commit -m "Update brew list $(date +'%Y-%m-%d')"
    git push origin main
    echo "Pushed updates at $(date)" >> /tmp/brew_cron.log
else
    echo "No changes to commit at $(date)" >> /tmp/brew_cron.log
fi
