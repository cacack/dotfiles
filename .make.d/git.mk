################################################################################
# Make configuration for git
#
# Adapted from a shared make module.
################################################################################

setup-git-config:
	@echo
	ln -nsf $(DOTFILES_CONFIG_DIR)/dot.config/git ${HOME}/.config/git.d
	ln -nsf $(DOTFILES_CONFIG_DIR)/dot.gitconfig ${HOME}/.gitconfig

################################################################################
#SETUP +=

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



################################################################################
# Misc

.PHONY: check-git-dirty
check-git-dirty:
	@ if [[ -n "$(shell git status -s .)" ]]; then echo "ERROR: working directory contains modified/untracked files.  Please commit or discard changes first." >&2; exit 1; fi

.PHONY: check-git-branch
check-git-branch:
	@ if [[ "$(shell git rev-parse --abbrev-ref HEAD)" != "main" ]]; then echo "ERROR: not on main branch." >&2; exit 1; fi
