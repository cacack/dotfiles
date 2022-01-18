#!/usr/bin/env bash

GIT_DIR="$(readlink -f "$(git rev-parse --git-dir)")"
GIT_CONFIG="${GIT_DIR}/config"
CONF_SNIPPET_HOME="${HOME}/devel/blah/.gitconfig"
CONF_SNIPPET_WORK="${HOME}/devel/work/.gitconfig"
if [[ "${GIT_DIR}" =~ '/devel/home/' ]] && [[ -r "${CONF_SNIPPET_HOME}" ]]; then
  CONF_SNIPPET="${CONF_SNIPPET_HOME}"
elif [[ "${GIT_DIR}" =~ '/dev/cas/' ]] && [[ -r "${CONF_SNIPPET_WORK}" ]]; then
  CONF_SNIPPET="${CONF_SNIPPET_HOME}"
fi

if [[ "$(git config user.email)" == '' ]] \
|| [[ "$(git config user.name)" == '' ]]; then
  if [[ -n "${CONF_SNIPPET}" ]]; then
    echo "cat ${CONF_SNIPPET} >> ${GIT_CONFIG}"
    cat "${CONF_SNIPPET}" >> "${GIT_CONFIG}"
  else
    echo 'Configuring per repository user information..'
    read -rp 'Enter your name: ' username
    read -rp 'Enter your email: ' email
    cat <<SNIPPET >> "${GIT_CONFIG}"
[user]
  name = ${username}
  email = ${email}
SNIPPET
  fi
fi
