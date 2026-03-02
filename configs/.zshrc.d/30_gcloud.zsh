# Google Cloud SDK helpers
if (( $+commands[gcloud] )); then

  # gsp - Google Switch Profile (configuration)
  # Usage: gsp [config_name]
  #   No args: list available configurations
  #   With arg: activate the named configuration
  gsp() {
    if [[ -z "$1" ]]; then
      gcloud config configurations list
      return
    fi
    gcloud config configurations activate "$1"
  }

  # Tab completion for gsp
  _gsp() {
    local -a configs
    configs=($(gcloud config configurations list --format='value(name)' 2>/dev/null))
    _describe 'gcloud configuration' configs
  }
  compdef _gsp gsp

fi
