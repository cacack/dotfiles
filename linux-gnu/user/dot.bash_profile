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

if [ -x $(which ssh-agent) ]; then
  eval $(ssh-agent)
  ssh-add
fi
