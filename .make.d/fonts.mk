################################################################################
# Fonts
#
# macOS: Nerd Font casks in Brewfile.gui. Linux has no common package, so
# download the pinned release and check each zip against its SHA-256.txt.
# unzip exits 11 when a zip has no files matching one pattern (no .otf).
################################################################################

# renovate: datasource=github-releases depName=ryanoasis/nerd-fonts extractVersion=^v(?<version>.+)$
NERD_FONT_VERSION := 3.5.1
NERD_FONT_BASE_URL := https://github.com/ryanoasis/nerd-fonts/releases/download/v$(NERD_FONT_VERSION)
NERD_FONTS := 3270 FiraCode Hack JetBrainsMono Meslo Mononoki ProggyClean

.PHONY: fonts
fonts:
ifeq ($(OS),linux)
	@echo
	# Installing Nerd Fonts $(NERD_FONT_VERSION)
	@tmp=$$(mktemp -d) && \
	curl -fsSL -o "$$tmp/SHA-256.txt" "$(NERD_FONT_BASE_URL)/SHA-256.txt" && \
	for font in $(NERD_FONTS); do \
		grep " $$font.zip$$" "$$tmp/SHA-256.txt" > "$$tmp/sum" && \
		curl -fsSL -o "$$tmp/$$font.zip" "$(NERD_FONT_BASE_URL)/$$font.zip" && \
		(cd "$$tmp" && $(SHASUM_CHECK) --quiet sum) && \
		{ unzip -o -q -d $(USER_FONT_DIR) "$$tmp/$$font.zip" '*.ttf' '*.otf' 2>/dev/null || [ $$? -eq 11 ]; } && \
		echo "✓ $$font" || { rm -rf "$$tmp"; echo "ERROR: $$font failed"; exit 1; }; \
	done; \
	rm -rf "$$tmp"
	fc-cache -f $(USER_FONT_DIR)
endif
