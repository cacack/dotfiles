# README
My various configuration files for Linux, multi-OS apps, and to a lesser extent, Windows.

Includes (but not limited to):
* bash
* geany
* tmux
* vi
* XFCE Terminal

## Layout
/ ${OSTYPE} / {user|system}

The _user_ and _system_ directories are treated as root of the _$HOME_ and _/_, respectively, for the named operating system.  Dotfiles will have the word "dot" prepended.  This should allow for programmatic placement via the setup script located in the root of $OSTYPE.

## Installation

### With Git
	git clone git@github.com:cacack/dotfiles.git ~/.dotfiles
	cd ~/.dotfiles/$OSTYPE
	./setup.sh

You can then git fetch/merge and rerun setup.sh to refresh a box.

### Without Git
	mkdir ~/.dotfiles
	cd ~/.dotfiles
	curl -#L https://github.com/cacack/dotfiles/archive/master.tar.gz |tar -xzv --strip-components 1
	$OSTYPE/setup.sh

Just re-run the last two commands to refresh a box.

