if [ -d "${HOME}/.local/opt/nvim-linux-x86_64" ]; then
  export PATH="${HOME}/.local/opt/nvim-linux-x86_64/bin:$PATH"
elif [ -d "${HOME}/.local/opt/nvim-macos-arm64" ]; then
  export PATH="${HOME}/.local/opt/nvim-macos-arm64/bin:$PATH"
elif [ -d "${HOME}/.local/opt/nvim-macos-x86_64" ]; then
  export PATH="${HOME}/.local/opt/nvim-macos-x86_64/bin:$PATH"
fi
