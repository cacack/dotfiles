# Override TERM when SSHing from Ghostty/xterm-ghostty to avoid
# 'unknown terminal type' errors on remote hosts without ghostty terminfo.
################################################################################

if [[ "$TERM" == "xterm-ghostty" ]]; then
  ssh() {
    TERM=xterm-256color command ssh "$@"
  }
fi
