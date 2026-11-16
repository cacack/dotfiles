-- Language servers to enable, in two tiers matching the dotfiles' mise profiles:
--   light: every machine.
--   heavy: desktop installs (MISE_ENV=desktop).
-- The servers and formatters themselves are installed, pinned and locked by mise
-- (configs/.config/mise/config.toml and config.desktop.toml), not by Mason.
-- The tier comes from $MISE_ENV, or from the profile file `make desktop` writes
-- when Neovim was not started from zsh (GUI launcher, bash, ssh host nvim).

local function profile()
  if vim.env.MISE_ENV then
    return vim.env.MISE_ENV
  end
  local file = io.open(vim.fn.expand "~/.config/dotfiles/mise-env")
  if not file then
    return nil
  end
  local value = vim.trim(file:read "*a")
  file:close()
  return value
end

-- typescript-language-server and typescript are separate mise installs, so
-- point the server at the tsserver of the typescript package whose `tsc` is on
-- PATH (<install>/node_modules/.bin/tsc beside <install>/node_modules/typescript).
local function tsserver_path()
  local tsc = vim.fn.exepath "tsc"
  local lib = vim.fn.fnamemodify(tsc, ":h:h") .. "/typescript/lib"
  if tsc == "" or vim.fn.filereadable(lib .. "/tsserver.js") == 0 then
    return nil
  end
  return lib
end

local M = {
  desktop = profile() == "desktop",
  servers = {
    -- marksman is a .NET binary; invariant mode drops its libicu dependency.
    marksman = { cmd_env = { DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1" } },
    taplo = {},
  },
}

local heavy = {
  bashls = {},
  cssls = {},
  gopls = {},
  html = {},
  jsonls = {},
  pyright = {},
  ruff = {},
  rust_analyzer = {},
  terraformls = {},
  ts_ls = { init_options = { tsserver = { path = tsserver_path() } } },
  yamlls = {
    settings = {
      yaml = {
        schemas = {
          ["./c7n-schema.json"] = "*.yml",
        },
      },
    },
  },
}

if M.desktop then
  M.servers = vim.tbl_extend("error", M.servers, heavy)
end

return M
