# ~/.profile
#
# Sourced for *ALL* interactive login shells and non-interactive shells with the
# --login option.  This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
#
# Trying to remember where to put things?  Easiest rule is put stuff here not specific to bash, and put things you'd want/expect in an interactive command line session (prompt, editor choices, aliases, etc).
#
# https://superuser.com/questions/789448/choosing-between-bashrc-profile-bash-profile-etc

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
  PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
  PATH="$HOME/.local/bin:$PATH"
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi
