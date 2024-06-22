local autocmd = vim.api.nvim_create_autocmd

-- Strip trailing whitespace
autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})
