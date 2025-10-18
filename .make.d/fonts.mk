################################################################################
# Fonts
# kitty +list-fonts
NERD_FONT_VERSION := 3.4.0
NERD_FONT_BASE_URL := https://github.com/ryanoasis/nerd-fonts/releases/download/v$(NERD_FONT_VERSION)

.PHONY: fonts
fonts: nerdfont-3270 nerdfont-firacode nerdfont-hack nerdfont-jetbrains nerdfont-meslo nerdfont-mononoki nerdfont-proggy

.PHONY: nerdfont-symbols-only
nerdfont-symbols-only:
	@echo "Installing Nerd Fonts Symbols Only..."
	@curl -fLo /tmp/nerdfont-symbols.zip $(NERD_FONT_BASE_URL)/NerdFontsSymbolsOnly.zip
	@unzip -o -q -d $(USER_FONT_DIR) /tmp/nerdfont-symbols.zip '*.ttf' '*.otf' 2>/dev/null || true
	@rm -f /tmp/nerdfont-symbols.zip
	@echo "✓ Nerd Fonts Symbols installed"

.PHONY: font-jetbrains
font-jetbrains:
	@echo "Installing JetBrains Mono (official)..."
	@curl -fLo /tmp/jetbrains.zip https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip
	@unzip -o -q /tmp/jetbrains.zip 'fonts/ttf/*.ttf' -d /tmp/jetbrains
	@mv /tmp/jetbrains/fonts/ttf/*.ttf $(USER_FONT_DIR)/
	@rm -rf /tmp/jetbrains /tmp/jetbrains.zip
	@echo "✓ JetBrains Mono installed"

.PHONY: nerdfont-3270
nerdfont-3270:
	@echo "Installing IBM 3270 Nerd Font..."
	@curl -fLo /tmp/3270.zip $(NERD_FONT_BASE_URL)/3270.zip
	@unzip -o -q -d $(USER_FONT_DIR) /tmp/3270.zip '*.ttf' '*.otf' 2>/dev/null || true
	@rm -f /tmp/3270.zip
	@echo "✓ IBM 3270 Nerd Font installed"

.PHONY: nerdfont-firacode
nerdfont-firacode:
	@echo "Installing Fira Code Nerd Font..."
	@curl -fLo /tmp/firacode.zip $(NERD_FONT_BASE_URL)/FiraCode.zip
	@unzip -o -q -d $(USER_FONT_DIR) /tmp/firacode.zip '*.ttf' '*.otf' 2>/dev/null || true
	@rm -f /tmp/firacode.zip
	@echo "✓ Fira Code Nerd Font installed"

.PHONY: nerdfont-hack
nerdfont-hack:
	@echo "Installing Hack Nerd Font..."
	@curl -fLo /tmp/hack.zip $(NERD_FONT_BASE_URL)/Hack.zip
	@unzip -o -q -d $(USER_FONT_DIR) /tmp/hack.zip '*.ttf' '*.otf' 2>/dev/null || true
	@rm -f /tmp/hack.zip
	@echo "✓ Hack Nerd Font installed"

.PHONY: nerdfont-jetbrains
nerdfont-jetbrains:
	@echo "Installing JetBrains Mono Nerd Font..."
	@curl -fLo /tmp/jetbrainsmono.zip $(NERD_FONT_BASE_URL)/JetBrainsMono.zip
	@unzip -o -q -d $(USER_FONT_DIR) /tmp/jetbrainsmono.zip '*.ttf' '*.otf' 2>/dev/null || true
	@rm -f /tmp/jetbrainsmono.zip
	@echo "✓ JetBrains Mono Nerd Font installed"

.PHONY: nerdfont-meslo
nerdfont-meslo:
	@echo "Installing Meslo Nerd Font..."
	@curl -fLo /tmp/meslo.zip $(NERD_FONT_BASE_URL)/Meslo.zip
	@unzip -o -q -d $(USER_FONT_DIR) /tmp/meslo.zip '*.ttf' '*.otf' 2>/dev/null || true
	@rm -f /tmp/meslo.zip
	@echo "✓ Meslo Nerd Font installed"

.PHONY: nerdfont-mplus
nerdfont-mplus:
	@echo "Installing M+ Nerd Font..."
	@curl -fLo /tmp/mplus.zip $(NERD_FONT_BASE_URL)/MPlus.zip
	@unzip -o -q -d $(USER_FONT_DIR) /tmp/mplus.zip '*.ttf' '*.otf' 2>/dev/null || true
	@rm -f /tmp/mplus.zip
	@echo "✓ M+ Nerd Font installed"

.PHONY: nerdfont-mononoki
nerdfont-mononoki:
	@echo "Installing Mononoki Nerd Font..."
	@curl -fLo /tmp/mononoki.zip $(NERD_FONT_BASE_URL)/Mononoki.zip
	@unzip -o -q -d $(USER_FONT_DIR) /tmp/mononoki.zip '*.ttf' '*.otf' 2>/dev/null || true
	@rm -f /tmp/mononoki.zip
	@echo "✓ Mononoki Nerd Font installed"

.PHONY: nerdfont-proggy
nerdfont-proggy:
	@echo "Installing ProggyClean Nerd Font..."
	@curl -fLo /tmp/proggyclean.zip $(NERD_FONT_BASE_URL)/ProggyClean.zip
	@unzip -o -q -d $(USER_FONT_DIR) /tmp/proggyclean.zip '*.ttf' '*.otf' 2>/dev/null || true
	@rm -f /tmp/proggyclean.zip
	@echo "✓ ProggyClean Nerd Font installed"
