#!/usr/bin/env bash
# Setup script for my dotfiles.
# Note: makes use of sexxxy bash string manipulation, see http://linuxgazette.net/18/bash.html.

# Borrowed some stuff from:
# * https://github.com/cowboy/dotfiles/blob/master/bin/dotfiles


###############################################################################
# Init

# Set $mode to $1 or default to "user" if unset/null.
mode=${1:-"user"}

# Set $environ to $2 or default to 'minimal" if unset/null.
environ=${2:-"minimal"}

# My directories to setup.
dirs='bin devel etc tmp'
# Include XDG desktop dirs if needed.
[[ ${environ} -eq 'desktop' ]] && dirs="$dirs $dirs_xdg"

# Key=Value pairs used to set XDG desktop directory names.
xdgkv='DESKTOP=desktop DOCUMENTS=documents DOWNLOAD=downloads MUSIC=music PICTURES=pictures PUBLICSHARE=public TEMPLATES=templates VIDEOS=videos'

# Path configuration..
srcdirbase="${HOME}/.dotfiles/${OSTYPE}/${mode}"
[[ ${mode} -eq "user" ]] && destdirbase="${HOME}" || destdirbase="/etc"

# Relative to $destdir and is laid out relative to $HOME minus the dot
cfgs='bashrc bash_aliases bash_profile dir_colors profile tmux.conf vimrc vim'
cfgs_desktop='abcde.conf config/Terminal/terminalrc'
# Include desktop configs if needed.
[[ ${environ} -eq 'desktop' ]] && cfgs="$cfgs $cfgs_desktop"


###############################################################################
# Directories
for dir in ${dirs}; do
   # Create directories if not exists
   if [[ ! -d ${destdirbase}/${dir} ]]; then
      mkdir ${destdirbase}/${dir}
   fi
done

if [[ ${environ} -eq 'desktop' ]]; then
   # xdg-user-dirs does not use a user config file so we're left using a tool to
   # set the dirs.
   for pairs in ${xdgkv}; do
      # Split the Key=Value pairs
      set -- `echo ${pairs} | tr '=' ' '`
      key=${1}
      value=${2}
      xdg-user-dirs-update --set ${key} ${destdirbase}/${value}
   done
fi


###############################################################################
# Configuration Files

for cfg in ${cfgs}; do
  # Remove old symlink
  [ -L ${destdirbase}/.${cfg} ] && rm ${destdirbase}/.${cfg}
  # Or backup file/directory if real
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
