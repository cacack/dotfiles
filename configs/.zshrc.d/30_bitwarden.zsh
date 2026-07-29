if (( $+commands[bw] )); then
  zmodload zsh/datetime 2>/dev/null
  bw_env="${HOME}/.ssh/bw.env"
  # `bw unlock --check` spawns the (slow) bw CLI every shell start just to
  # confirm what's usually still true from the last check. Trust a recent
  # check instead of re-verifying on every new shell/tmux window.
  bw_check_ttl=900

  bw_load_session() {
    if [[ -f "$bw_env" ]]; then
      # shellcheck disable=SC1090
      . "$bw_env" 2>/dev/null
    fi
  }

  bw_write_session() {
    (
      umask 077
      {
        echo "export BW_SESSION=$1"
        echo "export BW_LAST_CHECK=${EPOCHSECONDS}"
      } >"$bw_env"
    )
  }

  bw_is_unlocked() {
    bw_load_session
    if [[ -n "$BW_LAST_CHECK" ]] && (( EPOCHSECONDS - BW_LAST_CHECK < bw_check_ttl )); then
      return 0
    fi
    bw unlock --check 2>/dev/null || return 1
    bw_write_session "$BW_SESSION"
  }

  bw_unlock() {
    local session
    session="$(bw unlock --raw)"
    bw_write_session "$session"
    bw_load_session
    # Try to sync with 5s timeout, fail gracefully if network is unavailable
    if ! timeout 5s bw sync >/dev/null 2>&1; then
      echo "Warning: Bitwarden sync failed or timed out. Working with cached vault." >&2
    fi
  }

  if ! bw_is_unlocked; then
    bw_unlock
  fi
fi
