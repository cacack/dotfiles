desktop-scripts:
	[ -d ${HOME}/devel/home/desktop-scripts ] || git clone git@gitlab.com:cacack/desktop-scripts.git ${HOME}/devel/home/desktop-scripts
	cd ${HOME}/devel/home/desktop-scripts; stow --target=${HOME}/.local/bin bin
