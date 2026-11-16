-- Editor tools in two tiers, matching the dotfiles' mise profiles:
--   light: every machine; self-contained binaries, no language runtime needed.
--   heavy: desktop installs (MISE_ENV=desktop), where mise provides go, node,
--          python and rust for the packages below.
-- `mason` lists Mason packages (https://mason-registry.dev/registry/list);
-- `servers` maps language servers to enable onto their config.

local M = {
  mason = {
    "hadolint",
    "lua-language-server",
    "marksman",
    "shellcheck",
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
      yaml = {
        schemas = {
          ["./c7n-schema.json"] = "*.yml",
        },
      },
    },
  },
}

if vim.env.MISE_ENV == "desktop" then
  vim.list_extend(M.mason, heavy.mason)
  M.servers = vim.tbl_extend("error", M.servers, heavy.servers)
end

return M
