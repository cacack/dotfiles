# NVM (Node Version Manager) initialization
export NVM_DIR="$HOME/.nvm"

# Load NVM based on platform
if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
  # macOS Homebrew installation
  source "/opt/homebrew/opt/nvm/nvm.sh"
  # NVM bash completion
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # Standard installation (Linux)
  source "$NVM_DIR/nvm.sh"
  # NVM bash completion
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
fi
