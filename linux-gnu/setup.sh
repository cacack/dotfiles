#!/usr/bin/env bash
# Setup script for my dotfiles.
# Note: makes use of sexxxy bash string manipulation, see http://linuxgazette.net/18/bash.html.

# Borrowed some stuff from:
# * https://github.com/cowboy/dotfiles/blob/master/bin/dotfiles


###############################################################################
# Init

# Default to "user" if first arg is unset/null.
set=${1:-"user"}

# My directories to setup.
xdgdirs='desktop documents downloads music pictures public templates videos'
mydirs='bin devel etc tmp'

# Path configuration..
srcdirbase="${HOME}/.dotfiles/${OSTYPE}/${set}"
[[ ${set} -eq "user" ]] && destdirbase="${HOME}" || destdirbase="/etc"

# Relative to $destdir and is laid out relative to $HOME minus the dot
cfgs='abcde.conf bashrc bash_aliases bash_profile dir_colors profile tmux.conf vimrc vim config/Terminal/terminalrc'

###############################################################################
# Directories

for dir in ${mydirs} ${xdgdirs}; do
  if [[ ! -d ${destdirbase}/${dir} ]]; then
    mkdir ${destdirbase}/${dir}
  fi
done

# xdg-user-dirs does not use a user config file so we're left using a tool to
# set the dirs.
xdg-user-dirs-update --set DESKTOP ${destdirbase}/desktop
xdg-user-dirs-update --set DOWNLOAD ${destdirbase}/downloads
xdg-user-dirs-update --set TEMPLATES ${destdirbase}/templates
xdg-user-dirs-update --set PUBLICSHARE ${destdirbase}/public
xdg-user-dirs-update --set DOCUMENTS ${destdirbase}/documents
xdg-user-dirs-update --set MUSIC ${destdirbase}/music
xdg-user-dirs-update --set PICTURES ${destdirbase}/pictures
xdg-user-dirs-update --set VIDEOS ${destdirbase}/video

###############################################################################
# Configuration Files

for cfg in ${cfgs}; do
  # First backup any existing files or remove old symlinks
  [ -L ${destdirbase}/.${cfg} ] && rm ${destdirbase}/.${cfg}
  if [[ -f ${destdirbase}/.${cfg} || -d ${destdirbase}/.${cfg} ]]; then
	  mv ${destdirbase}/.${cfg} ${destdirbase}/.${cfg}.prev_$(date '+%F_%R')
  fi
  ln -s ${srcdirbase}/${cfg} ${destdirbase}/.${cfg}
done

# Run the private dotfiles if it exists and is excutable.
[ -x ${HOME}/.dotfiles.priv/${OSTYPE}/setup.sh ] && ${HOME}/.dotfiles.priv/${OSTYPE}/setup.sh

###############################################################################
# Fonts
mkdir ~/.fonts
ln -s ~/.dotfiles/multi/fonts/* ~/.fonts/
