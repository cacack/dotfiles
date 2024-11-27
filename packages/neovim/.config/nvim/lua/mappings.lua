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

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
