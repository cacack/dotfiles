# Azure CLI helpers
if (( $+commands[az] )); then

  # azs - Azure Subscription Switch
  # Usage: azs [subscription_name_or_id]
  #   No args: list available subscriptions
  #   With arg: set the active subscription
  azs() {
    if [[ -z "$1" ]]; then
      az account list --output table
      return
    fi
    az account set --subscription "$1"
  }

  # Tab completion for azs
  _azs() {
    local -a subscriptions
    subscriptions=("${(@f)$(az account list --query '[].name' --output tsv 2>/dev/null)}")
    _describe 'azure subscription' subscriptions
  }
  compdef _azs azs

fi
