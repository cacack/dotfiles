-- Editor tools in two tiers, matching the dotfiles' mise profiles:
--   light: every machine; self-contained binaries, no language runtime needed.
--   heavy: desktop installs (MISE_ENV=desktop), where mise provides go, node,
--          python and rust for the packages below.
-- The tier comes from $MISE_ENV, or from the profile file `make desktop` writes
-- when Neovim was not started from zsh (GUI launcher, bash, ssh host nvim).
-- `mason` lists Mason packages (https://mason-registry.dev/registry/list);
-- `servers` maps language servers to enable onto their config.

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

local M = {
  desktop = profile() == "desktop",
  mason = {
    "hadolint",
    "lua-language-server",
    "marksman",
    "shfmt",
    "stylua",
    "taplo",
  },
  servers = {
    -- marksman is a .NET binary; invariant mode drops its libicu dependency.
    marksman = { cmd_env = { DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1" } },
    taplo = {},
  },
}

local heavy = {
  mason = {
    -- python
    "pyright",
    "ruff",
    "black",
    "mdformat",

    -- go
    "gofumpt",
    "goimports-reviser",
    "gopls",

    -- rust
    "rust-analyzer",

    -- terraform
    "terraform-ls",
    "tflint",
    "tfsec",

    -- web dev, shell, yaml, json (node)
    "bash-language-server",
    "css-lsp",
    "deno",
    "html-lsp",
    "json-lsp",
    "prettier",
    "typescript-language-server",
    "yaml-language-server",

    -- remark seems to be NodeJS specific; https://github.com/remarkjs/remark-language-server/issues/6
    -- "remark-language-server",
    -- "remark-cli",
  },
  servers = {
    bashls = {},
    cssls = {},
    gopls = {},
    html = {},
    jsonls = {},
    pyright = {},
    ruff = {},
    rust_analyzer = {},
    terraformls = {},
    ts_ls = {},
    yamlls = {
      settings = {
        yaml = {
          schemas = {
            ["./c7n-schema.json"] = "*.yml",
          },
        },
      },
    },
  },
}

if M.desktop then
  vim.list_extend(M.mason, heavy.mason)
  M.servers = vim.tbl_extend("error", M.servers, heavy.servers)
end

return M
