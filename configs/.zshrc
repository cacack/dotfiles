# Enable zsh profiling for debugging timing.
# Can also use https://github.com/romkatv/zsh-bench
# zmodload zsh/zprof

# Source in external configs.
for script in "${HOME}"/.zshrc.d/*; do
  # skip non-executable files (allows toggling configs with chmod +x/-x)
  [[ -x "${script}" ]] || continue
  # execute $script in the context of the current shell
  source "${script}"
done

# Source in external work configs if they exist
if [[ -d ${HOME}/.zshrc_work.d ]]; then
  for script in "${HOME}"/.zshrc_work.d/*; do
    # skip non-executable files (allows toggling configs with chmod +x/-x)
    [[ -x "${script}" ]] || continue
    # execute $script in the context of the current shell
    source "${script}"
  done
fi

# Source in external secrets configs if they exist
if [[ -d ${HOME}/.zshrc_secrets.d ]]; then
  for script in "${HOME}"/.zshrc_secrets.d/*; do
    # skip non-executable files (allows toggling configs with chmod +x/-x)
    [[ -x "${script}" ]] || continue
    # execute $script in the context of the current shell
    source "${script}"
  done
fi

# Trigger the profiler
# zprof
