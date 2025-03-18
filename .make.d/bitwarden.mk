ifeq ($(UNAME), Darwin)
BW_PLATFORM := macos
endif
ifeq ($(UNAME), Linux)
BW_PLATFORM := linux
endif

setup-bitwarden: install-bitwarden-cli

install-bitwarden-cli:
	curl -Ls -o bitwarden-cli.zip "https://vault.bitwarden.com/download/?app=cli&platform=$(BW_PLATFORM)"
	unzip -d ${USER_BIN_DIR} bitwarden-cli.zip bw
	chmod 0755 ${USER_BIN_DIR}/bw
	rm -f bitwarden-cli.zip
ifeq ($(UNAME), Darwin)
	xattr -dr com.apple.quarantine ${USER_BIN_DIR}/bw
endif
