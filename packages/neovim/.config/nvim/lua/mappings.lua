require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- gitsigns
map("n", "<leader>gb", function()
  require("gitsigns").blame_line { full = true }
end, { desc = "git blame line" })
map("n", "<leader>gB", require("gitsigns").toggle_current_line_blame, { desc = "git blame toggle" })

-- spelling using telescope
map("n", "<leader>ss", "<cmd>Telescope spell_suggest<CR>", { desc = "spelling suggestions" })

-- file operations
map("n", "<leader>rf", "<cmd>e<CR>", { desc = "reload current file" })

-- formatting toggle
map("n", "<leader>tf", function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  if vim.b.disable_autoformat then
    vim.notify("Format on save: DISABLED", vim.log.levels.WARN)
  else
    vim.notify("Format on save: ENABLED", vim.log.levels.INFO)
  end
end, { desc = "toggle format on save" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
