-- This file  needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
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

return M
