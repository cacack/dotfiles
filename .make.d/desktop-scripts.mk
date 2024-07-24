desktop-scripts:
	[ -d ${HOME}/devel/home/desktop-scripts ] && (cd ${HOME}/devel/home/desktop-scripts; git fetch; git merge --ff-only origin/main) || git clone git@gitlab.com:cacack/desktop-scripts.git ${HOME}/devel/home/desktop-scripts
	cd ${HOME}/devel/home/desktop-scripts; make install

clean-desktop-scripts:
	cd ${HOME}/devel/home/desktop-scripts; make clean
