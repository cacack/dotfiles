# Only execute if at work.
[ -e ~/.cas-home ] || return

# Switch to bash if available.
[ $(which bash) ] && exec $(which bash)
