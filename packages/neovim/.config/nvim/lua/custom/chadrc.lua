---@type ChadrcConfig

-- Source custom autocommands
require "custom.autocmds"

-- Should probably go somewhere else...
vim.opt.spelllang = "en_us"
vim.opt.spell = true

local M = {}

M.ui = {
  theme = "kanagawa",
  hl_override = {
      -- Visual = { bg = "base02" }, -- original
      -- Visual = { bg = "#545460" },
      Visual = { bg = "lightbg" },
      -- Visual = { bg = "line" },
  }
}

M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"

return M
