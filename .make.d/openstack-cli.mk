setup-openstack: install-openstack-cli

install-openstack-cli:
	@echo
	# Installing OpenStack CLI
	# Not in mise: its plugins (--with) bypass mise's dependency lock.
	uv tool install python-openstackclient --with python-designateclient --with python-octaviaclient
