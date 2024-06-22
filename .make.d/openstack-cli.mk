setup-openstack: install-openstack-cli

install-openstack-cli:
	@echo
	# Installing OpenStack CLI
	pipx install python-openstackclient
	pipx inject python-openstackclient python-designateclient
	pipx inject python-openstackclient python-octaviaclient
