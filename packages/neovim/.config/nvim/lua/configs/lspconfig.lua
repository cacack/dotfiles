-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

-- https://nvchad.com/docs/recipes#clean_lspconfig_syntax
local servers = require("configs.tools").servers

-- lsps with default config
for name, opts in pairs(servers) do
  vim.lsp.enable(name)
  vim.lsp.config(name, opts)
end
