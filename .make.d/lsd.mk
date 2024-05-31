LSD_VERSION := 1.0.0

.PHONY: setup-lsd
setup-lsd:
	@echo
	# Installing lsd
ifeq ($(OS),linux)
	#curl -Ls -o lsd.tar.gz https://github.com/Peltoche/lsd/releases/download/$(LSD_VERSION)/lsd-$(LSD_VERSION)-x86_64-unknown-linux-gnu.tar.gz
	# https://github.com/lsd-rs/lsd/releases/download/v1.0.0/lsd-v1.0.0-x86_64-unknown-linux-gnu.tar.gz
	curl -Ls -o lsd.tar.gz https://github.com/lsd-rs/lsd/releases/download/v$(LSD_VERSION)/lsd-v$(LSD_VERSION)-x86_64-unknown-linux-gnu.tar.gz
	tar -x -C ${USER_BIN_DIR} --overwrite --strip-components=1 -f lsd.tar.gz lsd-v$(LSD_VERSION)-x86_64-unknown-linux-gnu/lsd
	chmod 775 ${USER_BIN_DIR}/lsd
	rm lsd.tar.gz
endif
ifeq ($(OS),darwin)
	brew install lsd
endif

setup-lsd-config:
	@echo
	# Symlinking lsd config
	ln -nsf ${DOTFILES_CONFIG_DIR}/dot.config/lsd ${HOME}/.config/lsd
