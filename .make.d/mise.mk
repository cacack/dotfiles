################################################################################
# mise: installs every CLI tool and language runtime
#
# Tool pins live in configs/.config/mise/config.toml, locked with checksums in
# mise.lock beside it. mise itself is pinned here; its tarball is verified
# against the release's SHASUMS256.txt so Renovate can bump MISE_VERSION alone.
#
# Profiles: config.toml is the base (CLI) tool set. A desktop install adds
# config.desktop.toml by setting MISE_ENV=desktop, recorded per machine in
# MISE_ENV_FILE (written by `make desktop`, read here and by 10_mise.zsh).
################################################################################

UPDATE += tools

# renovate: datasource=github-releases depName=jdx/mise
MISE_VERSION := 2026.11.9

MISE := $(BIN_DIR)/mise
MISE_CONFIG_DIR := $(REPO_DIR)/configs/.config/mise
MISE_ENV_FILE := ${HOME}/.config/dotfiles/mise-env
MISE_ENV ?= $(shell cat $(MISE_ENV_FILE) 2>/dev/null)
export MISE_ENV

ifeq ($(OS),darwin)
MISE_PLATFORM := macos-arm64
endif
ifeq ($(OS),linux)
ifeq ($(ARCH),x86_64)
MISE_PLATFORM := linux-x64
else
MISE_PLATFORM := linux-arm64
endif
endif

MISE_TARBALL := mise-v$(MISE_VERSION)-$(MISE_PLATFORM).tar.gz
MISE_RELEASE_URL := https://github.com/jdx/mise/releases/download/v$(MISE_VERSION)

.PHONY: install-mise
install-mise:
	@echo
	# Installing mise $(MISE_VERSION)
	@if [ "$$($(MISE) --version 2>/dev/null | awk '{print $$1}')" = "$(MISE_VERSION)" ]; then \
		echo "mise $(MISE_VERSION) already installed"; \
	else \
		tmp=$$(mktemp -d) && \
		curl -fsSL -o "$$tmp/$(MISE_TARBALL)" "$(MISE_RELEASE_URL)/$(MISE_TARBALL)" && \
		curl -fsSL "$(MISE_RELEASE_URL)/SHASUMS256.txt" | grep " ./$(MISE_TARBALL)$$" | sed 's| ./| |' > "$$tmp/SHASUMS256.txt" && \
		[ -s "$$tmp/SHASUMS256.txt" ] && \
		(cd "$$tmp" && $(SHASUM_CHECK) SHASUMS256.txt) && \
		tar -xzf "$$tmp/$(MISE_TARBALL)" -C "$$tmp" && \
		mkdir -p $(BIN_DIR) && \
		install -m 0755 "$$tmp/mise/bin/mise" $(MISE) && \
		rm -rf "$$tmp" || { rm -rf "$$tmp"; echo "ERROR: mise install failed"; exit 1; }; \
	fi

# Install exactly what the lockfile pins, then drop versions no longer pinned.
.PHONY: tools
tools: install-mise
	@echo
	# Installing locked tool versions
	$(MISE) install
	$(MISE) prune --yes

# Record this machine as a desktop so mise adds config.desktop.toml.
.PHONY: mise-env-desktop
mise-env-desktop:
	mkdir -p $(dir $(MISE_ENV_FILE))
	echo desktop > $(MISE_ENV_FILE)

# Regenerate both lockfiles (mise.lock, mise.desktop.lock) after editing a config.
.PHONY: mise-lock
mise-lock: install-mise
	MISE_ENV=desktop MISE_CONFIG_DIR=$(MISE_CONFIG_DIR) $(MISE) lock --global

# Fail if mise.lock is out of step with config.toml.
.PHONY: mise-lock-check
mise-lock-check: mise-lock
	git -C $(REPO_DIR) diff --exit-code -- configs/.config/mise
