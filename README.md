# DotFiles

My various configuration files for Linux, multi-OS apps, and to a lesser extent,
Windows.

Includes (but not limited to):

* bash
* geany
* tmux
* vi
* XFCE Terminal

These are mine; they may not work for you as-is.  But read on and feel free to
fork 'em.

## Purpose

I wanted a way to track changes and simplify bootstrapping new boxes.  Github
and a setup script allow me to accomplish this making home feel like home.  This
is a work in progress, specially the bootstrap method.

## Layout

/ ${OSTYPE} / {user|system}

The _user_ and _system_ directories are treated as root of the _$HOME_ and _/_,
respectively, for the named operating system.  Dotfiles will have the word "dot"
prepended.  This should allow for programmatic placement via the setup script
located in the root of $OSTYPE.

## Installation

### With Git

```
git clone git@github.com:cacack/dotfiles.git ~/.dotfiles
cd ~/.dotfiles/$OSTYPE
./setup.sh
```

You can then git fetch/merge and rerun setup.sh to refresh a box.

### Without Git

```
mkdir ~/.dotfiles
cd ~/.dotfiles
curl -#L https://github.com/cacack/dotfiles/archive/master.tar.gz \
  | tar -xzv --strip-components 1
$OSTYPE/setup.sh
```

Just re-run the last two commands to refresh a box.

## Inspiration

I've borrowed/learned a thing or two from the following folks:

* [cowboy/dotfiles](https://github.com/cowboy/dotfiles)
* [rtomayko/dotfiles](https://github.com/rtomayko/dotfiles)

More attributions may be found throughout the files contained within this
repository..

## License

Copyright (c) [Chris Clonch][1]. Distributed under an [MIT License][2].

[1]: http://www.theclonchs.com/chris/
[2]: http://www.opensource.org/licenses/MIT
