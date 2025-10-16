GHOSTTY_VERSION := 1.2.0

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
	curl -Ls -o Ghostty.dmg https://release.files.ghostty.org/$(GHOSTTY_VERSION)/Ghostty.dmg
	hdiutil attach Ghostty.dmg
	mkdir -p ${HOME}/Applications
	cp -R /Volumes/Ghostty/Ghostty.app ${HOME}/Applications/
	hdiutil detach /Volumes/Ghostty
	rm Ghostty.dmg
endif

.PHONY: setup-ghostty-config
setup-ghostty-config:
	@echo
	# Symlinking ghostty's config
	mkdir -p ${HOME}/.config/ghostty
	cd packages && stow --target=${HOME} ghostty