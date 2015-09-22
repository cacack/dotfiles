# .bash_profile
# Favored by *BASH* shells over .profile.

# Load .profile, containing login, non-bash related initializations.
[ -f ${HOME}/.profile ] && source ${HOME}/.profile

# Source .bashrc, containing non-login related bash initializations.
[ -f ${HOME}/.bashrc ] && source ${HOME}/.bashrc
