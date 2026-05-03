IMAGE_NAME := dotfiles-test
SCRIPTS := install.sh setup.sh setup_envs.sh uninstall.sh

.PHONY: lint
lint:
	shellcheck $(SCRIPTS)
	shfmt -d -i 0 $(SCRIPTS)

.PHONY: build-test
build-test:
	podman build -t $(IMAGE_NAME) -f .devcontainer/Dockerfile.ubuntu .devcontainer/

.PHONY: test
test: build-test
	podman run -it --rm -v $(shell pwd):/workspace:Z $(IMAGE_NAME) zsh -c "cd /workspace && ./.gemini/skills/test-changes/scripts/test.sh"

.PHONY: dev
dev: build-test
	podman run -it --rm -v $(shell pwd):/workspace:Z $(IMAGE_NAME) zsh
