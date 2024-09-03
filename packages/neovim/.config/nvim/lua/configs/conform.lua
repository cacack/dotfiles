local options = {
  formatters_by_ft = {
		css = { "prettier" },
		go = { "gofumpt", "goimports-reviser" },
		html = { "prettier" },
		javascript = { "prettier" },
		lua = { "stylua" },
		markdown = { "mdformat" },
		python = { "black" },
		sh = { "shfmt" },
		terraform = { "terraform_fmt" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
