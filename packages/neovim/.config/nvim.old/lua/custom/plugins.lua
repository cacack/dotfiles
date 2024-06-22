-- source configs/overrides into overrides variable

local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {
  -- override plugin definition options..

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },

  -- syntax awareness
  -- Home: https://github.com/nvim-treesitter/nvim-treesitter#nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  -- Package manager for LSP servrers, linters, formatters..
  -- Home: https://github.com/williamboman/mason.nvim
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  -- conform replaces null-ls now
  -- https://github.com/stevearc/conform.nvim
  {
    "stevearc/conform.nvim",
    --  for users those who want auto-save conform + lazyloading!
    -- event = "BufWritePre"
    config = function()
      require "custom.configs.conform"
    end,
  },

}

return plugins
