# Strip Linux /home/ubuntu path on macOS so non-interactive shells never trigger automountd
if [[ "$OSTYPE" == darwin* && "$PATH" == *"/home/ubuntu/"* ]]; then
	PATH="${PATH//\/home\/ubuntu\/.local\/bin:/}"
	export PATH="${PATH%:}"
fi
