# NVM (Node Version Manager), loaded on demand: sourcing nvm.sh costs ~200ms
# per shell and is rarely needed, so the first `nvm` call loads it instead.
export NVM_DIR="$HOME/.nvm"

if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
  _nvm_script="/opt/homebrew/opt/nvm/nvm.sh"  # macOS Homebrew installation
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
  _nvm_script="$NVM_DIR/nvm.sh"               # Standard installation (Linux)
fi

if [[ -n "$_nvm_script" ]]; then
  _nvm_load() {
    unfunction nvm node npm npx 2>/dev/null
    source "$_nvm_script"
  }
  nvm() { _nvm_load && nvm "$@"; }

  # Without another node on PATH (e.g. Linux, where node comes only from nvm),
  # load nvm on first use of node tooling too.
  if (( ! $+commands[node] )); then
    node() { _nvm_load && node "$@"; }
    npm()  { _nvm_load && npm "$@"; }
    npx()  { _nvm_load && npx "$@"; }
  fi
fi
