# shellcheck shell=bash

# iTerm2 project setups
alias eq='open "iterm2://runscript?name=equiquant.py"'

# gpg signing — play a sound while waiting for YubiKey
gpg() {
	afplay /System/Library/Sounds/Tink.aiff &
	command gpg "$@"
}

# Send clipboard contents to a Tailscale device (defaults to iphone)
tcopy() {
	local target="${1:-iphone}"
	local tmpfile
	tmpfile="/tmp/clip_$(date +%H%M%S).txt"
	pbpaste > "$tmpfile"
	tailscale file cp "$tmpfile" "${target}:"
	rm "$tmpfile"
	echo "Sent clipboard to $target"
}
