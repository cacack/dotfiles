-- Config: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md
-- Docs on builtins: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
local null_ls = require "null-ls"

local b = null_ls.builtins

local sources = {

  -- webdev stuff
  b.formatting.deno_fmt, -- choosed deno for ts/js files cuz its very fast!
  b.formatting.prettier.with { filetypes = { "html", "markdown", "css" } }, -- so prettier works only on these filetypes

  -- Lua
  b.formatting.stylua,

  -- terraform
  b.formatting.terraform_fmt,

  -- go
  b.formatting.gofumpt,
  b.formatting.goimports_reviser,
  b.formatting.golines,

  -- python
  b.formatting.black,
  b.formatting.isort,
  b.diagnostics.mypy,
  b.diagnostics.ruff,
}

null_ls.setup {
  debug = true,
  sources = sources,
}
