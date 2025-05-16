if (( $+commands[bw] )); then
  env="${HOME}/.ssh/bw.env"

  bw_is_unlocked() {
    bw_load_session
    bw unlock --check
    bw sync
  }

  bw_load_session() {
    # shellcheck disable=SC1090
    . "$env" >/dev/null
  }

  bw_unlock() {
    (umask 077; echo "export BW_SESSION=$(bw unlock --raw)" >"$env")
    # shellcheck disable=SC1090
    . "$env" >/dev/null
  }

  if ! bw_is_unlocked; then
    bw_unlock
  fi

  unset env
fi
