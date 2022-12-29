################################################################################
# Variables that can be overridden

SHELLCHECK_VERSION ?= 0.7.1

# https://github.com/koalaman/shellcheck/releases/download/v0.7.1/shellcheck-v0.7.1.linux.x86_64.tar.xz
SHELLCHECK_URL := https://github.com/koalaman/shellcheck/releases/download/v$(SHELLCHECK_VERSION)/shellcheck-v$(SHELLCHECK_VERSION).linux.x86_64.tar.xz

################################################################################
PRINT_VERSION += print-version-shellcheck

.PHONY: print-version-shellcheck
print-version-shellcheck:
	@echo "Shellcheck: $(SHELLCHECK_VERSION)"


################################################################################
SETUP += setup-shellcheck

.PHONY: setup-shellcheck
setup-shellcheck:
	@echo
	curl -fLo shellcheck.tar.xz $(SHELLCHECK_URL)
	tar -xvf shellcheck.tar.xz --directory=$(BIN_DIR) --strip-components=1 shellcheck-v${SHELLCHECK_VERSION}/shellcheck
	chmod 755 $(BIN_DIR)/shellcheck
	rm shellcheck.tar.xz



################################################################################
UPDATE += update-shellcheck

.PHONY: update-shellcheck
update-shellcheck: setup-shellcheck
	@echo
	sed -i 's/SHELLCHECK_VERSION: .*/SHELLCHECK_VERSION: "$(SHELLCHECK_VERSION)"/g' .gitlab-ci.yml

.PHONY: update-shellcheck-artifactory
update-shellcheck-artifactory: HASH = $(shell sha1sum shellcheck.tar.xz | cut -d' ' -f1)
update-shellcheck-artifactory:
	@echo
	wget -O shellcheck.tar.xz $(SHELLCHECK_URL)
	curl \
		-H 'X-JFrog-Art-Api: $(ARTIFACTORY_API_KEY)' \
		-H 'X-Checksum-Sha1: $(HASH)' \
		-X PUT \
		'https://artifactory.cloud.cas.org/web_other/shellcheck/shellcheck-v$(SHELLCHECK_VERSION).linux.x86_64.tar.xz' \
		-T 'shellcheck.tar.xz'
	rm shellcheck.tar.xz


################################################################################
LINT += lint-shellcheck

.PHONY: lint-shellcheck
lint-shellcheck:
	@echo
	git grep -I --name-only --null -e '' \
    | xargs --null --max-lines=1 file --mime-type \
    | sed --quiet 's,: *text/x-shellscript$$,,p' \
    | xargs --no-run-if-empty shellcheck -x

.PHONY: lint-shellcheck-changed
lint-shellcheck-changed:
	@echo
	git diff --name-only --diff-filter=ACM -z origin/master..HEAD \
    | xargs --null --max-lines=1 file --mime-type \
    | sed --quiet 's,: *text/x-shellscript$$,,p' \
    | xargs --no-run-if-empty shellcheck -x
