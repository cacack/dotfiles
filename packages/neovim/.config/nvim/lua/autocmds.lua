local autocmd = vim.api.nvim_create_autocmd

-- Strip trailing whitespace
autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

-- Command alias: :W to save without formatting (noautocmd write)
vim.api.nvim_create_user_command("W", "noautocmd write", {})
