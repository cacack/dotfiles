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

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
