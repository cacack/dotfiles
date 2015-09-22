#~/.profile
# 
# Sourced for *ALL* interactive login shells and non-interactive shells with the 
# --login option.

# Function to source seperate config files.
run_scripts() {
   for script in ${1}/*; do
      # skip non-executable snippets
      [ -x "${script}" ] || continue
      # execute $script in the context of the current shell
      #source ${script} >/dev/null 2>&1
      source ${script}
   done
}

# Source in external configs.
[ -d ${HOME}/.profile.d ] && run_scripts ${HOME}/.profile.d
