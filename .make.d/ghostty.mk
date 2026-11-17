GHOSTTY_VERSION := 1.2.2

.PHONY: setup-ghostty
setup-ghostty: install-ghostty setup-ghostty-config

.PHONY: install-ghostty
install-ghostty:
	@echo
	# Installing ghostty
ifeq ($(OS),linux)
	@echo
	curl -Ls -o ghostty.tar.xz https://github.com/ghostty-org/ghostty/releases/download/v$(GHOSTTY_VERSION)/ghostty-$(GHOSTTY_VERSION)-x86_64-linux-gnu.tar.xz
	mkdir -p ${USER_BIN_DIR}/ghostty.app
	tar -xv -C ${USER_BIN_DIR}/ghostty.app -f ghostty.tar.xz
	ln -nsf ${USER_BIN_DIR}/ghostty.app/usr/bin/ghostty ${USER_BIN_DIR}/ghostty
	mkdir -p ${SHARE_DIR}/applications
	cp ${USER_BIN_DIR}/ghostty.app/usr/share/applications/com.mitchellh.ghostty.desktop ${SHARE_DIR}/applications/
	mkdir -p ${SHARE_DIR}/icons/hicolor
	rsync -rav ${USER_BIN_DIR}/ghostty.app/usr/share/icons/hicolor/ ${SHARE_DIR}/icons/hicolor/
	rm ghostty.tar.xz
endif
ifeq ($(OS),darwin)
	@echo
	# Ghostty self-updates (Sparkle); the pin only bootstraps a fresh machine.
	# Never copy over an existing (possibly running, newer) bundle.
	@if [ -d ${HOME}/Applications/Ghostty.app ]; then \
		echo "Ghostty already installed; skipping (it updates itself)"; \
		exit 0; \
	fi; \
	curl -Ls -o Ghostty.dmg https://release.files.ghostty.org/$(GHOSTTY_VERSION)/Ghostty.dmg && \
	hdiutil attach -nobrowse Ghostty.dmg && \
	mkdir -p ${HOME}/Applications && \
	cp -R /Volumes/Ghostty/Ghostty.app ${HOME}/Applications/; \
	rc=$$?; \
	hdiutil detach /Volumes/Ghostty 2>/dev/null; \
	rm -f Ghostty.dmg; \
	exit $$rc
endif

.PHONY: setup-ghostty-config
setup-ghostty-config:
	@echo
	# Symlinking ghostty's config
	mkdir -p ${HOME}/.config/ghostty
	cd packages && stow --target=${HOME} ghostty