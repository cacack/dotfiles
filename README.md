# README
My various configuration files for Linux, multi-OS apps, and to a lesser extent, Windows.

Includes (but not limited to):
* bash
* geany
* tmux
* vi
* XFCE Terminal

## Layout
/ ${OS} / {user|system}

The _user_ and _system_ directories are treated as root of the _$HOME_ and _/_, respectively, for the named operating system.  Dotfiles will have the dot dropped.  This should allow for programmatic placement via the setup script located in the root of $OS.
