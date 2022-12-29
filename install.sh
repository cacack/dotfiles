#!/usr/bin/bash

repo_url="https://gitlab.com/cacack/dotfiles.git"
dotfiles_dir="${HOME}/.dotfiles"

echo "Cloning the dotfiles repo.."
git clone "${repo_url}" "${dotfiles_dir}"

(
  cd "${dotfiles_dir}" || exit 1
  make setup-desktop
)
