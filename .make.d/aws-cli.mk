.PHONY: install-aws-cli
install-aws-cli:
	@echo
	# Installing AWS CLI
	curl -Ls -o awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
	unzip awscliv2.zip
	./aws/install --install-dir $(SHARE_DIR)/aws-cli --bin-dir $(BIN_DIR) --update
	rm -rf awscliv2.zip aws

