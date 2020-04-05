# ~/.bashrc
# interactive, non-login
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently non-interactive shells such as scp and rcp
# that can't tolerate any output. So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell. There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
[[ $- != *i* ]] && return

#set -x

# Set a few *default* things for use later by the separate configs.

USE_COLORS=''
if [ -t 1 ]; then
  # see if it supports colors...
  ncolors=$(tput colors)
  if test -n "$ncolors" && test $ncolors -ge 8; then
    USE_COLORS=${ncolors}
  fi
fi
export USE_COLORS

# Fix term's to display more color.
[ $TERM == 'xterm' ] && export TERM=xterm-256color

# Source in external configs.
for script in ${HOME}/.bashrc.d/*; do
  # skip non-executable snippets
  [ -x "${script}" ] || continue
  # execute $script in the context of the current shell
  . ${script}
done
