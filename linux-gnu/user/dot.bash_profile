# .bash_profile
# Favored by *BASH* shells over .profile.

# Load .profile, containing login, non-bash related initializations.
[ -f ~/.profile ] && source ~/.profile

# Source .bashrc, containing non-login related bash initializations.
[ -f ~/.bashrc ] && source ~/.bashrc
