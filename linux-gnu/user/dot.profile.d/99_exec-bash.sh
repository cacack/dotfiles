# Only execute if at work.

which git-ls-projects >/dev/null 2>/dev/null || export PATH=$PATH:/home/cac21/.cas-git-tools/bin
[ -e ~/.cas-home ] || return

# Switch to bash if available.
[ $(which bash) ] && exec $(which bash)
