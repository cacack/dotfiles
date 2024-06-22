local options = {
	lsp_fallback = true,

	-- Formatters available -- https://github.com/stevearc/conform.nvim?tab=readme-ov-file#formatters
	formatters_by_ft = {
		css = { "prettier" },
		--go = { "goimports-reviser", "gofumpt" },
		go = { "gofumpt", "goimports-reviser" },
		html = { "prettier" },
		javascript = { "prettier" },
		lua = { "stylua" },
		markdown = { "mdformat" },
		python = { "black" },
		sh = { "shfmt" },
		terraform = { "terraform_fmt" },
	},

	-- adding same formatter for multiple filetypes can look too much work for some
	-- instead of the above code you could just use a loop! the config is just a table after all!

	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_fallback = true,
	},
	-- run the formatter asynchronously after save.
	-- format_after_save = {
	--   lsp_fallback = true,
	-- },
}

require("conform").setup(options)
