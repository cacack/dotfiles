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

  format_on_save = function(bufnr)
    -- Check if formatting is disabled for this buffer
    if vim.b[bufnr].disable_autoformat then
      return nil
    end
    -- These options will be passed to conform.format()
    return {
      timeout_ms = 500,
      lsp_fallback = true,
    }
  end,
}

return options
