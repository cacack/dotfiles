################################################################################
# Fonts
# kitty +list-fonts
NERD_FONT_VERSION := 3.2.1

.PHONY: fonts
fonts: nerdfont-3270 nerdfont-firacode nerdfont-hack font-jetbrains nerdfont-meslo nerdfont-mononoki nerdfont-proggy

.PHONY: nerdfont-symbols-only
nerdfont-symbols-only:
	@echo
	curl -fLo nerdfont-symbols.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v$(NERD_FONT_VERSION)/NerdFontsSymbolsOnly.zip
	unzip nerdfont-symbols.zip '*.ttf'
	mv *.ttf $(USER_FONT_DIR)/
	rm -f nerdfont-symbols.zip

.PHONY: font-jetbrains
font-jetbrains:
	@echo
	curl -fLo jetbrains.zip https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip
	unzip jetbrains.zip 'fonts/ttf/*.ttf'
	mv fonts/ttf/*.ttf $(USER_FONT_DIR)/
	rm -rf fonts
	rm -rf jetbrains.zip

.PHONY: nerdfont-3270
nerdfont-3270:
	@echo
	curl -fLo "$(USER_FONT_DIR)/3270 Medium Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/3270/Regular/complete/IBM%203270%20Nerd%20Font%20Complete.otf
	curl -fLo "$(USER_FONT_DIR)/3270 Medium Nerd Font Complete Mono.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/3270/Regular/complete/IBM%203270%20Nerd%20Font%20Complete%20Mono.otf

.PHONY: nerdfont-firacode
nerdfont-firacode:
	@echo
	curl -fLo "$(USER_FONT_DIR)/Fira Code Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/Fira Code Regular Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete%20Mono.ttf

.PHONY: nerdfont-hack
nerdfont-hack:
	@echo
	curl -fLo "$(USER_FONT_DIR)/Hack Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/Hack Regular Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/Hack Bold Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Bold/complete/Hack%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/Hack Italic Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Italic/complete/Hack%20Italic%20Nerd%20Font%20Complete%20Mono.ttf

.PHONY: nerdfont-jetbrains
nerdfont-jetbrains:
	@echo
	curl -fLo "$(USER_FONT_DIR)/JetBrains Mono Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/JetBrains Mono Regular Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/JetBrains Mono Bold Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Bold/complete/JetBrains%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/JetBrains Mono Italic Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Italic/complete/JetBrains%20Mono%20Italic%20Nerd%20Font%20Complete%20Mono.ttf

.PHONY: nerdfont-meslo
nerdfont-meslo:
	@echo
	curl -fLo "$(USER_FONT_DIR)/Meslo LG M DZ Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M-DZ/Regular/complete/Meslo%20LG%20M%20DZ%20Regular%20Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/Meslo LG M DZ Regular Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M-DZ/Regular/complete/Meslo%20LG%20M%20DZ%20Regular%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/Meslo LG M DZ Bold Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M-DZ/Bold/complete/Meslo%20LG%20M%20DZ%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/Meslo LG M DZ Bold Italic Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M-DZ/Bold-Italic/complete/Meslo%20LG%20M%20DZ%20Bold%20Italic%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/Meslo LG M DZ Italic Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M-DZ/Italic/complete/Meslo%20LG%20M%20DZ%20Italic%20Nerd%20Font%20Complete%20Mono.ttf

.PHONY: nerdfont-mplus
nerdfont-mplus:
	@echo
	curl -fLo font.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v$(NERD_FONT_VERSION)/MPlus.zip
	unzip -o -d ${USER_FONT_DIR} font.zip
	rm font.zip

.PHONY: nerdfont-mononoki
nerdfont-mononoki:
	@echo
	curl -fLo "$(USER_FONT_DIR)/mononoki Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Regular/complete/mononoki-Regular%20Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/mononoki Regular Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Regular/complete/mononoki-Regular%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/mononoki Bold Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Bold/complete/mononoki%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/mononoki Bold Italic Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Bold-Italic/complete/mononoki%20Bold%20Italic%20Nerd%20Font%20Complete%20Mono.ttf
	curl -fLo "$(USER_FONT_DIR)/mononoki Italic Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Italic/complete/mononoki%20Italic%20Nerd%20Font%20Complete%20Mono.ttf

.PHONY: nerdfont-proggy
nerdfont-proggy:
	@echo
	curl -fLo "$(USER_FONT_DIR)/ProggyClean Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/ProggyClean/Regular/complete/ProggyCleanTT%20Nerd%20Font%20Complete.ttf
	curl -fLo "$(USER_FONT_DIR)/ProggyClean Nerd Font Complete Mono.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/ProggyClean/Regular/complete/ProggyCleanTT%20Nerd%20Font%20Complete%20Mono.ttf
