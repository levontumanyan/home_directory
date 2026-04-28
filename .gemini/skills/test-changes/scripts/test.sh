#!/usr/bin/env bash

# Determine machine type
m_type="personal"
if [ -f ~/.work.zsh ]; then
	m_type="work"
fi

AUTOMATED_EXECUTION=1 ./install.sh -m "$m_type" -n
exit_code=$?

echo "EXIT_STATUS: $exit_code"
exit $exit_code
