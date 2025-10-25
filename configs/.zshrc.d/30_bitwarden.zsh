if (( $+commands[bw] )); then
  bw_env="${HOME}/.ssh/bw.env"

  bw_is_unlocked() {
    bw_load_session
    bw unlock --check 2>/dev/null
  }

  bw_load_session() {
    if [[ -f "$bw_env" ]]; then
      # shellcheck disable=SC1090
      . "$bw_env" 2>/dev/null
    fi
  }

  bw_unlock() {
    (umask 077; echo "export BW_SESSION=$(bw unlock --raw)" >"$bw_env")
    # shellcheck disable=SC1090
    . "$bw_env" 2>/dev/null
    bw sync
  }

  if ! bw_is_unlocked; then
    bw_unlock
  fi

  # unset env
fi
