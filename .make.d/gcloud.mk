.PHONY: install-gcloud
install-gcloud:
	@echo
	# Installing Google Cloud SDK
ifeq ($(UNAME), Linux)
	curl -Ls -o /tmp/google-cloud-sdk.tar.gz "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-$(ARCH).tar.gz"
	mkdir -p $(BASE_DIR)/opt
	tar -xzf /tmp/google-cloud-sdk.tar.gz -C $(BASE_DIR)/opt/
	$(BASE_DIR)/opt/google-cloud-sdk/install.sh --quiet --path-update=false --command-completion=false
	ln -sf $(BASE_DIR)/opt/google-cloud-sdk/bin/bq $(BIN_DIR)/bq
	ln -sf $(BASE_DIR)/opt/google-cloud-sdk/bin/gcloud $(BIN_DIR)/gcloud
	ln -sf $(BASE_DIR)/opt/google-cloud-sdk/bin/gsutil $(BIN_DIR)/gsutil
	rm -f /tmp/google-cloud-sdk.tar.gz
endif
ifeq ($(UNAME), Darwin)
	brew install --cask google-cloud-sdk
endif
