# Source in external work configs if they exist
if [[ -d ${HOME}/.zshrc_work.d ]]; then
  for script in "${HOME}"/.zshrc_work.d/*; do
    # skip non-executable snippets
    [ -x "${script}" ] || continue
    # execute $script in the context of the current shell
    . "${script}"
  done
fi

# Source in external configs.
for script in "${HOME}"/.zshrc.d/*; do
  # skip non-executable snippets
  [[ -x "${script}" ]] || continue
  # execute $script in the context of the current shell
  source "${script}"
done
