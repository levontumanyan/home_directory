SCRIPTS := install.sh setup.sh setup_envs.sh uninstall.sh

.PHONY: lint
lint:
	shellcheck $(SCRIPTS)
	shfmt -d -i 0 $(SCRIPTS)
