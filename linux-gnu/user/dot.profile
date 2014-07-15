#~/.profile
# Sourced for *ALL* interactive login shells and non-interactive shells with the 
# --login option.

# Add my paths ahead of the system's
PATH=$HOME/.local/bin:$HOME/bin:$PATH
export PATH

if [ -d ~/.profile.d ]; then
  for i in ~/.profile.d/*.sh; do
    if [ "${-#*i}" != "$-" ]; then
      source "$i"
    else
      source "$i" >/dev/null 2>&1
    fi
  done
fi
