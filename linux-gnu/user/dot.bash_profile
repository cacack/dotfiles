# .bash_profile
# Favored by *BASH* shells over .profile.

# Load .profile, containing login, non-bash related initializations.
if [ -f ~/.profile ]; then
  source ~/.profile
fi
  
# Load .bashrc, containing non-login related bash initializations.
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

  
# Unlock SSH keys
if [ -x $(which envoy) ]; then
  # Use envoy first.
  envoy -t ssh-agent -a chris\@home
  envoy -t ssh-agent -a chris-software\@home
  source <(envoy -p)
elif [ -x $(which keychain) ]; then
  # Use keychain second.
  eval $(keychain --eval --agents ssh -Q --quiet chris\@home)
  eval $(keychain --eval --agents ssh -Q --quiet chris-software\@home)
elif [ -x $(which ssh-agent) ]; then
  # Fall back to ssh-agent directly.
  eval $(ssh-agent)
  ssh-add chris\@home
  ssh-add chris-software\@home
fi

if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi
