GLAB_VERSION := 1.74.0

ifeq ($(UNAME), Darwin)
GLAB_PLATFORM := darwin
GLAB_ARCH := $(ARCH_ALT)
endif
ifeq ($(UNAME), Linux)
GLAB_PLATFORM := linux
GLAB_ARCH := $(ARCH_ALT)
endif

.PHONY: setup-glab
setup-glab: install-glab

.PHONY: install-glab
install-glab:
	@echo
	# Installing GitLab CLI (glab)
	curl -Ls -o glab.tar.gz https://gitlab.com/gitlab-org/cli/-/releases/v$(GLAB_VERSION)/downloads/glab_$(GLAB_VERSION)_$(GLAB_PLATFORM)_$(GLAB_ARCH).tar.gz
	tar -xzf glab.tar.gz
	mv bin/glab $(USER_BIN_DIR)/glab
	chmod 0755 $(USER_BIN_DIR)/glab
	rm -rf glab.tar.gz bin/
ifeq ($(UNAME), Darwin)
	xattr -dr com.apple.quarantine $(USER_BIN_DIR)/glab
endif
	@echo
	# GitLab CLI installation complete
	@echo "Run 'glab auth login' to authenticate with your GitLab account"