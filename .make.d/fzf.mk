FZF_VERSION := 0.42.0

.PHONY: setup-fzf
setup-fzf:
	@echo
	# Installing fzf
ifeq ($(OS),linux)
	#https://github.com/junegunn/fzf/releases/download/0.30.0/fzf-0.30.0-linux_amd64.tar.gz
	curl -Ls -o fzf.tar.gz https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz
	tar -xvzf fzf.tar.gz
	cp fzf ${USER_BIN_DIR}/fzf
	chmod 755 ${USER_BIN_DIR}/fzf
	rm -f fzf fzf.tar.gz
	[ ! -d "${USER_BIN_DIR}/fzf.repo" ] && git clone --depth 1 https://github.com/junegunn/fzf.git ${USER_BIN_DIR}/fzf.repo || cd ${USER_BIN_DIR}/fzf.repo; git pull
endif
ifeq ($(OS),darwin)
	brew install fzf
endif
