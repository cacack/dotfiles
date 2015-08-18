# Only execute if at work.
[ -e ~/.at_work ] || return

# Switch to bash if available.
[ $(which bash) ] && exec $(which bash)
