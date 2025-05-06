-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

-- https://nvchad.com/docs/recipes#clean_lspconfig_syntax
local servers = {
  autotools_ls = {},
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
        "./c7n-schema.json" == "*.yml",
      },
    },
  },
}

-- lsps with default config
for name, opts in pairs(servers) do
  vim.lsp.enable(name)
  vim.lsp.config(name, opts)
end
