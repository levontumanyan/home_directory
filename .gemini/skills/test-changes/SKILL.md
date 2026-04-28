---
name: test-changes
description: Lint modified scripts and execute non-interactive installation.
---

# Test Changes

Execute this protocol when the user requests to test changes:

1. **Lint**
	Run shellcheck on modified scripts.
	```bash
	make lint
	```

2. **Execute Installation**
	Determine machine type dynamically and execute with isolated I/O to prevent CLI hangs.
	```bash
	m_type=$([ -f ~/.work.zsh ] && echo "work" || echo "personal")
	AUTOMATED_EXECUTION=1 ./install.sh -m "$m_type" -n
	```

3. **Validate**
	Verify exit code 0 and successful symlink creation from the log. Report errors.
