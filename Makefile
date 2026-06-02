IMAGE_NAME := dotfiles-test
SCRIPTS := install.sh setup.sh setup_envs.sh scripts/dump_brewfile.sh scripts/test.sh

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

.PHONY: system-stop
system-stop:
	container system stop

.PHONY: test
test: build-test
	container run --rm -e IN_CONTAINER=1 -v $(shell pwd):/workspace $(IMAGE_NAME) zsh -c "cd /workspace && ./scripts/test.sh"; \
	EXIT=$$?; container system stop; exit $$EXIT

.PHONY: dev
dev: build-test
	container run -it --rm -v $(shell pwd):/workspace $(IMAGE_NAME) zsh
