################################################################################
# Vulnerability scans of the pinned tools. One layer of several: mise.lock
# checksums and signed provenance (mise.mk), Renovate's minimumReleaseAge, and
# these scans. The scanners are pinned in config.desktop.toml; accepted
# findings, each with a reason and an expiry, live in .osv-scanner.toml and
# .trivyignore.yaml. CI runs both (.gitlab-ci.yml).
################################################################################

# Run a scanner through mise with the repo's desktop config, so this works
# without shell activation (CI) and always uses the pinned scanner version.
# Naming the tool keeps mise from installing the rest of the desktop set first.
MISE_SCAN = MISE_ENV=desktop MISE_CONFIG_DIR=$(MISE_CONFIG_DIR) $(MISE) exec $(1) --
MISE_INSTALLS ?= ${HOME}/.local/share/mise/installs

.PHONY: security security-deps security-tools
security: security-deps security-tools

# Locked dependency trees of the pypi tools (their uv.lock files); no install needed.
security-deps:
	@echo
	# Scanning locked tool dependencies (osv-scanner)
	$(call MISE_SCAN,aqua:google/osv-scanner) osv-scanner scan source --config $(REPO_DIR)/.osv-scanner.toml -r $(MISE_CONFIG_DIR)/locks

# Everything mise installed: Go modules compiled into binaries and the npm,
# Python and Ruby packages bundled with tools. Fails on HIGH/CRITICAL findings
# that have a fixed version upstream.
security-tools:
	@echo
	# Scanning installed tools (trivy)
	$(call MISE_SCAN,aqua:aquasecurity/trivy) trivy rootfs --quiet --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed \
		--ignorefile $(REPO_DIR)/.trivyignore.yaml --exit-code 1 $(MISE_INSTALLS)
