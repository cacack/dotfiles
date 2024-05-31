STARSHIP_VERSION := 1.16.0

.PHONY: setup-starship
setup-starship: install-starship setup-starship-config

.PHONY: install-starship
install-starship:
	@echo
	# Installing starship
ifeq ($(OS),linux)
	curl -Ls -o starship.tar.gz https://github.com/starship/starship/releases/download/v$(STARSHIP_VERSION)/starship-x86_64-unknown-linux-gnu.tar.gz
	tar -x -C ${USER_BIN_DIR} --overwrite -f starship.tar.gz
	chmod 775 ${USER_BIN_DIR}/starship
	rm starship.tar.gz
endif
ifeq ($(OS),darwin)
	brew install starship
endif

.PHONY: setup-starship-config
setup-starship-config:
	@echo
	# Symlinking starship config
	ln -nsf $(DOTFILES_CONFIG_DIR)/starship.toml ${HOME}/.config/starship.toml
