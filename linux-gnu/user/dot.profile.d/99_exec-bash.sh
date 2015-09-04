# Only execute if at work.
[ -e ~/.at_work ] || return

which git-ls-projects >/dev/null 2>/dev/null || export PATH=$PATH:/home/cac21/.cas-git-tools/bin

# Switch to bash if available.
[ $(which bash) ] && exec $(which bash)
