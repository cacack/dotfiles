#!/bin/sh
# Start ssh-agent and load SSH key
# https://help.github.com/articles/working-with-ssh-key-passphrases/#auto-launching-ssh-agent-on-msysgit
################################################################################

# Note: ~/.ssh/environment should not be used, as it
#       already has a different purpose in SSH.

env=~/.ssh/agent.env

# Note: Don't bother checking SSH_AGENT_PID. It's not used
#       by SSH itself, and it might even be incorrect
#       (for example, when using agent-forwarding over SSH).

agent_is_running() {
    if [ -S "$SSH_AUTH_SOCK" ]; then
        # ssh-add returns:
        #   0 = agent running, has keys
        #   1 = agent running, no keys
        #   2 = agent not running
        ssh-add -l >/dev/null 2>&1 || [ $? -eq 1 ]
    else
        false
    fi
}

agent_has_keys() {
	ssh-add -l >/dev/null 2>&1
}

agent_add_keys() {
	#ssh-add -t 25920000 -K ~/.ssh/id_rsa
	ssh-add -t 24h -K ~/.ssh/id_rsa
}

agent_load_env() {
	. "$env" >/dev/null
}

agent_start() {
	(umask 077; ssh-agent >"$env")
	. "$env" >/dev/null
}

if ! agent_is_running; then
	agent_load_env
fi

# if your keys are not stored in ~/.ssh/id_rsa or ~/.ssh/id_dsa, you'll need
# to paste the proper path after ssh-add
if ! agent_is_running; then
	agent_start
	agent_add_keys
elif ! agent_has_keys; then
	agent_add_keys
fi

# attempt to connect to a running agent - cache SSH_AUTH_SOCK in ~/.ssh/
sagent() {
	[ -S "$SSH_AUTH_SOCK" ] || export SSH_AUTH_SOCK="$(< ~/.ssh/ssh-agent.env)"

	# if cached agent socket is invalid, start a new one
	[ -S "$SSH_AUTH_SOCK" ] || {
		eval "$(ssh-agent)"
		ssh-add -t 25920000 -K ~/.ssh/id_rsa
		echo "$SSH_AUTH_SOCK" > ~/.ssh/ssh-agent.env
	}
}

typeset -fx sagent

unset env
