# mise: puts the pinned tools from ~/.config/mise/config.toml on PATH.
# Activation runs its hook immediately, so the tools are available to the
# files after this one (10_plugins.zsh, 10_prompt.zsh) that init fzf, zoxide
# and starship.
if (( $+commands[mise] )); then
  # Desktop installs (`make desktop`) record MISE_ENV=desktop for this machine.
  if [[ -r "${HOME}/.config/dotfiles/mise-env" ]]; then
    export MISE_ENV="$(<"${HOME}/.config/dotfiles/mise-env")"
  fi
  _cached_init mise 'mise activate zsh' mise
fi
