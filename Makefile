IMAGE_NAME := dotfiles-test
SCRIPTS := install.sh setup.sh setup_envs.sh uninstall.sh scripts/dump_brewfile.sh

.PHONY: lint
lint:
	shellcheck $(SCRIPTS)
	shfmt -d -i 0 $(SCRIPTS)

.PHONY: system-start
system-start:
	container system start

.PHONY: build-test
build-test: system-start
	container build -t $(IMAGE_NAME) -f .devcontainer/Containerfile .devcontainer/

.PHONY: test
test: build-test
	container run --rm -v $(shell pwd):/workspace $(IMAGE_NAME) zsh -c "cd /workspace && ./.gemini/skills/test-changes/scripts/test.sh"

.PHONY: dev
dev: build-test
	container run -it --rm -v $(shell pwd):/workspace $(IMAGE_NAME) zsh
