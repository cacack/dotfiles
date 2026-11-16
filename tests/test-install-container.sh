#!/usr/bin/env bash
# End-to-end test of the light (CLI, no root) install in a fresh Ubuntu
# container. Needs Docker and network access, so it is not part of `make test`;
# run it with `make test-install`.
#
# Checks: install.sh succeeds without root, every pinned tool is installed and
# no language runtime is, the first interactive shell is quiet, and Neovim's
# light-tier language servers (installed by mise) attach. The desktop path
# (`install.sh --desktop`) is not covered.
set -euo pipefail

IMAGE="${IMAGE:-ubuntu:24.04@sha256:73b999393d07f2bf65a40373778a44dc9a6d54ad7718d29247d8ff9413c4d6a8}"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "${1:-}" != "--inside" ]]; then
    command -v docker >/dev/null 2>&1 || { echo "ERROR: docker is required"; exit 1; }
    echo "Testing the light install in ${IMAGE} (takes a few minutes)..."
    exec docker run --rm -v "${DOTFILES_DIR}:/repo:ro" "${IMAGE}" \
        bash /repo/tests/test-install-container.sh --inside
fi

# --- Inside the container, as root: baseline prerequisites only (no libatomic;
# only the desktop set needs it). ---
failures=0
pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; failures=$((failures + 1)); }
as_dev() { su - dev -c "$1"; }

apt-get update -qq >/dev/null
apt-get install -y -qq ca-certificates curl git make stow tar unzip zsh >/dev/null 2>&1
useradd -m -s /bin/bash dev
cp -a /repo /home/dev/.dotfiles
chown -R dev:dev /home/dev/.dotfiles

echo "install.sh (no root, no sudo):"
if as_dev 'cd ~/.dotfiles && bash install.sh' >/tmp/install.log 2>&1; then
    pass "install.sh succeeded"
else
    fail "install.sh failed; last lines:"; tail -20 /tmp/install.log; exit 1
fi

echo "Interactive shell:"
# The first shells clone zinit and its plugins (some load deferred), which is
# expected output. After that, a shell must start silently.
for _ in 1 2; do as_dev 'zsh -i -c true' >/dev/null 2>&1 || true; done
# zle cannot be enabled without a terminal; that line is an artifact of zsh -c.
noise="$(as_dev 'zsh -i -c true' 2>&1 | grep -v "can't change option: zle" || true)"
[[ -z "$noise" ]] && pass "shell starts silently once plugins are fetched" || fail "shell output: $noise"

echo "Shell plugin pins:"
# A fresh install must already sit on every pin, so syncing moves nothing.
moved="$(as_dev 'cd ~/.dotfiles && make -s zinit-update' 2>&1 | grep -v '^# Syncing\|^$' || true)"
[[ -z "$moved" ]] && pass "zinit and plugins installed at their pinned commits" || fail "not at pins: $moved"
# Repinning a plugin (here to its parent commit) must move it on the next sync.
plugin=/home/dev/.local/share/zinit/plugins/Aloxaf---fzf-tab
parent="$(as_dev "git -C $plugin rev-parse HEAD~1")"
as_dev "cd ~/.dotfiles && sed -i 's|^\(  Aloxaf/fzf-tab \)[0-9a-f]*|\1$parent|' configs/.zshrc.d/00_init.zsh && make -s zinit-update >/dev/null"
[[ "$(as_dev "git -C $plugin rev-parse HEAD")" == "$parent" ]] && pass "make update moves a plugin to a changed pin" || fail "plugin did not follow its new pin"
as_dev 'cd ~/.dotfiles && git checkout -q -- configs/.zshrc.d/00_init.zsh && make -s zinit-update >/dev/null'

echo "Tools:"
missing="$(as_dev 'zsh -i -c "mise ls --missing"' 2>/dev/null)"
[[ -z "$missing" ]] && pass "every pinned tool is installed" || fail "not installed: $missing"
runtimes="$(as_dev 'zsh -i -c "for t in go node python3 ruby rustc; do (( \$+commands[\$t] )) && echo \$t; done; true"' 2>/dev/null)"
[[ -z "$runtimes" ]] && pass "no language runtimes in the light set" || fail "runtimes present: $runtimes"

echo "Neovim:"
as_dev 'zsh -i -c "nvim --headless \"+Lazy! restore\" +qa"' >/tmp/lazy.log 2>&1 \
    && pass "plugins restored from lazy-lock.json" || fail "Lazy restore failed"
as_dev 'cd /tmp && printf "# hi\n" > x.md && printf "a = 1\n" > x.toml && printf "local a = 1\n" > x.lua'
for f in x.md x.toml x.lua; do
    # NvChad loads lspconfig on User FilePost, which needs a UI; fire it by hand.
    clients="$(as_dev "cd /tmp && zsh -i -c 'nvim --headless $f \"+doautocmd User FilePost\" +e \"+sleep 4\" \"+lua io.stdout:write(#vim.lsp.get_clients({bufnr=0}))\" +qa'" 2>/dev/null | tail -c1)"
    [[ "$clients" == "1" ]] && pass "language server attaches to $f" || fail "no language server for $f"
done

echo
if (( failures == 0 )); then echo "All container install checks passed!"; else echo "$failures container install check(s) failed"; exit 1; fi
