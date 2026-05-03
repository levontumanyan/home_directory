SCRIPTS := install.sh setup.sh setup_envs.sh uninstall.sh

.PHONY: lint
lint:
	shellcheck $(SCRIPTS)
	shfmt -d -i 0 $(SCRIPTS)

.PHONY: test
test:
	podman build -t dotfiles-test -f .devcontainer/Dockerfile.alpine .devcontainer/
	podman run -it --rm -v $(shell pwd):/workspace:Z dotfiles-test zsh -c "cd /workspace && ./.gemini/skills/test-changes/scripts/test.sh"
