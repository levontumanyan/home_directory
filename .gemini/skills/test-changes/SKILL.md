---
name: test-changes
description: Test changes to install.sh and other shell scripts by running shellcheck and executing the installation non-interactively.
---

# Test Changes

When the user asks to "test the changes", you should follow this testing protocol:

1. **lint**
	Run `shellcheck` on all modified shell scripts to ensure there are no syntax errors or warnings.
	```bash
	make lint
	```

2. **Run the Install Script Non-Interactively**
	Execute `install.sh` bypassing all user prompts. Use the `-m` flag to specify the machine type and the `-n` flag to skip Homebrew package installation (which saves time during testing).
	```bash
	./install.sh -m personal -n
	```

3. **Validate the Output**
	Ensure that the script executes successfully (exit code 0) and that the expected dotfiles are correctly symlinked. Report any errors back to the user.
