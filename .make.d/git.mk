################################################################################

install-gitlab-runner:
	@echo
	curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
	sudo apt install gitlab-runner


################################################################################

clean-merged-branches:
	git branch --merged | egrep -v "(^\*|master)" | xargs git branch -d


################################################################################
LINT += lint-whitespace

lint-whitespace:
	@echo
	git diff --check HEAD --
