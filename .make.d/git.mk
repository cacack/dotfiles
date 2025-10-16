################################################################################
# Make configuration for git
#
# Source: https://gitlab.cas.org/cloudservices/public/make/.make.d/git.mk
################################################################################

COMMITLINT_VERSION ?= 19.9.1
COMMITLINT_START_REF ?= HEAD~20

setup-git-config:
	@echo
	ln -nsf $(DOTFILES_CONFIG_DIR)/dot.config/git ${HOME}/.config/git.d
	ln -nsf $(DOTFILES_CONFIG_DIR)/dot.gitconfig ${HOME}/.gitconfig

setup-git-filter-repo:
	@echo
	curl -o $(USER_BIN_DIR)/git-filter-repo https://raw.githubusercontent.com/newren/git-filter-repo/main/git-filter-repo
	chmod 755 $(USER_BIN_DIR)/git-filter-repo

################################################################################
#SETUP +=

.PHONY: setup-commitlint
setup-commitlint:
	@echo
	# https://github.com/conventionalcommit/commitlint/releases/download/v19.9.1/commitlint_19.9.1_Darwin_x86_64.tar.gz
	curl -Ls -o commitlint.tar.gz https://github.com/conventionalcommit/commitlint/releases/download/v$(COMMITLINT_VERSION)/commitlint_$(COMMITLINT_VERSION)_$(UNAME)_$(ARCH).tar.gz
	tar -xvzf commitlint.tar.gz -C $(BIN_DIR) commitlint
	rm commitlint.tar.gz

.PHONY: setup-git-hook-commitlint
setup-git-hook-commitlint:
	@echo
	commitlint hook create --replace --hookspath .git/hooks/

################################################################################
#UPDATE +=


################################################################################
CLEAN += clean-merged-branches

.PHONY: clean-merged-branches
clean-merged-branches:
	@echo
	# Delete branches which are merged into the default branch.
	git branch --merged | egrep -v "(^\*|master|main)" | xargs git branch -d


################################################################################
LINT += lint-whitespace

.PHONY: lint-whitespace
lint-whitespace:
	@echo
	# Check for whitespace errors
	git diff --check HEAD --

.PHONY: lint-commit-messages
lint-commit-messages:
	@echo
	# Lint previous 20 commits
	git log --format=%s --no-merges -z $(COMMITLINT_START_REF)..HEAD | xargs -0 -L1 -I {} sh -c "echo {} | commitlint lint"


################################################################################
# Misc

.PHONY: check-git-dirty
check-git-dirty:
	@ if [[ -n "$(shell git status -s .)" ]]; then echo "ERROR: working directory contains modified/untracked files.  Please commit or discard changes first." >&2; exit 1; fi

.PHONY: check-git-branch
check-git-branch:
	@ if [[ "$(shell git rev-parse --abbrev-ref HEAD)" != "main" ]]; then echo "ERROR: not on main branch." >&2; exit 1; fi
