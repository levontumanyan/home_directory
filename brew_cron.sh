#!/usr/bin/env zsh

set -e

BREW_FORMULAS="./brew_formulas.txt"
BREW_CASKS="./brew_casks.txt"

# Update the list
brew list --formula > "$BREW_FORMULAS"
brew list --cask >> "$BREW_CASKS"

# Commit and push if there are changes
git add $BREW_FORMULAS $BREW_CASKS
if ! git diff --cached --quiet; then
    git commit -m "Update brew list $(date +'%Y-%m-%d')"
    git push origin main
fi
