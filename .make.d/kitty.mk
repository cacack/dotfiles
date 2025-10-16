KITTY_VERSION := 0.42.2

.PHONY: setup-kitty
setup-kitty: install-kitty setup-kitty-config

.PHONY: install-kitty
install-kitty:
	@echo
	# Installing kitty
ifeq ($(OS),linux)
	@echo
	curl -Ls -o kitty.txz https://github.com/kovidgoyal/kitty/releases/download/v$(KITTY_VERSION)/kitty-$(KITTY_VERSION)-x86_64.txz
	mkdir -p ${USER_BIN_DIR}/kitty.app
	tar -xv -C ${USER_BIN_DIR}/kitty.app -f kitty.txz
	ln -nsf ${USER_BIN_DIR}/kitty.app/bin/kitty ${USER_BIN_DIR}/kitty
	rsync -rav ${USER_BIN_DIR}/kitty.app/share/ ${SHARE_DIR}/
	rm kitty.txz
endif
ifeq ($(OS),darwin)
	@echo
	brew install kitty
endif

.PHONY: setup-kitty-config
setup-kitty-config:
	@echo
	# Symlinking kitty's config
	mkdir -p ${HOME}/.config/kitty
	cd packages && stow --target=${HOME} kitty
