# Startup profiling for debugging shell lag (e.g. slow tmux new-window).
# Can also use https://github.com/romkatv/zsh-bench
#
#   ZSHRC_PROFILE=1 zsh -i -c exit   # per-file timing breakdown (this file)
#   ZSH_PROF=1 zsh -i -c exit        # per-function breakdown (zprof)
[[ -n "$ZSH_PROF" ]] && zmodload zsh/zprof
[[ -n "$ZSHRC_PROFILE" ]] && zmodload zsh/datetime && typeset -gA _zshrc_timing

# Source every executable script in a directory (allows toggling configs with
# chmod +x/-x), optionally timing each one when $ZSHRC_PROFILE is set.
_zshrc_source_dir() {
  [[ -d "$1" ]] || return
  local script _start
  for script in "$1"/*; do
    [[ -x "${script}" ]] || continue
    if [[ -n "$ZSHRC_PROFILE" ]]; then
      _start=$EPOCHREALTIME
      source "${script}"
      _zshrc_timing[${script}]=$(( (EPOCHREALTIME - _start) * 1000 ))
    else
      source "${script}"
    fi
  done
}

# Source in external configs.
_zshrc_source_dir "${HOME}/.zshrc.d"

# Source in external work configs if they exist
_zshrc_source_dir "${HOME}/.zshrc_work.d"

# Source in external secrets configs if they exist
_zshrc_source_dir "${HOME}/.zshrc_secrets.d"

unset -f _zshrc_source_dir

if [[ -n "$ZSHRC_PROFILE" ]]; then
  print -P "%F{cyan}--- zsh startup timing (ms) ---%f"
  for script in "${(@k)_zshrc_timing}"; do
    printf '%8.2f  %s\n' "${_zshrc_timing[${script}]}" "${script}"
  done | sort -rn
  unset _zshrc_timing
fi

# Trigger the profiler
[[ -n "$ZSH_PROF" ]] && zprof
