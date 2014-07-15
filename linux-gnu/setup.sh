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
# Set date = 2014-07-15_12:38
datetime=$(date '+%F_%R')

# Directories 
dir_src="${HOME}/.dotfiles"
dir_src_os="${dir_src}/${OSTYPE}"
dir_src_mode="${dir_src_os}/${mode}"
[[ ${mode} -eq "user" ]] && dir_dest="${HOME}" || dir_dest="/etc"

dirs='bin devel etc tmp'

# Key=Value pairs used to set XDG desktop directory names.
xdgkv='DESKTOP=desktop DOCUMENTS=documents DOWNLOAD=downloads MUSIC=music PICTURES=pictures PUBLICSHARE=public TEMPLATES=templates VIDEOS=videos'

# Relative to $destdir and is laid out relative to $HOME minus the dot
cfgs='bashrc bash_aliases bash_profile dir_colors profile tmux.conf vimrc vim'
cfgs_desktop='abcde.conf config/Terminal/terminalrc'
# Include desktop configs if needed.
[[ ${environ} -eq 'desktop' ]] && cfgs="$cfgs $cfgs_desktop"


###############################################################################
# Directories
echo "Creating directories..."
for dir in ${dirs}; do
   # Create directories if not exists
   if [[ ! -d ${dir_dest}/${dir} ]]; then
      mkdir ${dir_dest}/${dir}
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
      xdg-user-dirs-update --set ${key} ${dir_dest}/${value}
   done
fi


###############################################################################
# Executables
echo "Linking user executables..."
for bin_src in ${dir_src_mode}/bin/*; do
   bin_dest=${dir_dest}/bin/${bin_src##${dir_src_mode}/bin/}
   # Remove old symlink
   [[ -L ${bin_dest} ]] && rm ${bin_dest}
   # Or backup file/directory if real.
   if [[ -f ${bin_dest} ]]; then
      mv ${bin_dest} ${bin_dest}.prev_${datetime}
   fi
   ln -s ${bin_src} ${bin_dest}
done


###############################################################################
# Configuration Files
echo "Linking configuration files..."
for cfg in ${cfgs}; do
  # Remove old symlink
  [[ -L ${dir_dest}/.${cfg} ]] && rm ${dir_dest}/.${cfg}
  # Or backup file/directory if real
  if [[ -f ${dir_dest}/.${cfg} || -d ${dir_dest}/.${cfg} ]]; then
	  mv ${dir_dest}/.${cfg} ${dir_dest}/.${cfg}.prev_${datetime}
  fi
  ln -s ${dir_src_mode}/${cfg} ${dir_dest}/.${cfg} 2>/dev/null
done

# Run the private dotfiles if it exists and is excutable.
[[ -x ${dir_src}.priv/${OSTYPE}/setup.sh ]] && ${dir_src}.priv/${OSTYPE}/setup.sh


###############################################################################
# Fonts
echo "Linking fonts..."
[[ -d ${HOME}/.fonts ]] || mkdir ${HOME}/.fonts
for font_src in ${dir_src}/multi/fonts/*; do
   # Derive destination from src.
   font_dest=${HOME}/.fonts/${font_src##${dir_src}/multi/fonts/}
   # Remove old symlink
   [[ -L ${font_dest} ]] && rm ${font_dest}
   # Or backup file/directory if real.
   if [[ -f ${font_dest} ]]; then
      mv ${font_dest} ${font_dest}.prev_${datetime}
   fi
   ln -s ${font_src} ${font_dest}
done
