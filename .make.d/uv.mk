UV_VERSION := 0.9.3

ifeq ($(UNAME), Darwin)
UV_PLATFORM := apple-darwin
ifeq ($(ARCH), arm64)
UV_ARCH := aarch64
else
UV_ARCH := x86_64
endif
endif
ifeq ($(UNAME), Linux)
UV_PLATFORM := unknown-linux-gnu
ifeq ($(ARCH), arm64)
UV_ARCH := aarch64
else
UV_ARCH := x86_64
endif
endif

.PHONY: setup-uv
setup-uv: install-uv

.PHONY: install-uv
install-uv:
	@echo
	# Installing uv and uvx
	curl -Ls -o uv.tar.gz https://github.com/astral-sh/uv/releases/download/$(UV_VERSION)/uv-$(UV_ARCH)-$(UV_PLATFORM).tar.gz
	tar -xz -C $(USER_BIN_DIR) -f uv.tar.gz --strip-components=1 uv-$(UV_ARCH)-$(UV_PLATFORM)/uv uv-$(UV_ARCH)-$(UV_PLATFORM)/uvx
	rm uv.tar.gz