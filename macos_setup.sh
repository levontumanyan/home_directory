#!/usr/bin/env zsh

# are we on a macos? exit if not
if [ "$(uname)" != "Darwin" ]; then
  echo "Not macOS. Exiting."
  return 0 2>/dev/null || exit 0
fi

