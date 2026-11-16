require "nvchad.options"

-- NvChad puts Mason's bin dir first on PATH. Language servers and formatters
-- come from mise (lua/configs/tools.lua), so drop it: binaries Mason installed
-- before the switch must not shadow the pinned ones.
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"
vim.env.PATH = table.concat(
  vim.tbl_filter(function(dir)
    return dir ~= mason_bin
  end, vim.split(vim.env.PATH, ":", { plain = true })),
  ":"
)

-- add yours here!

local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

o.spelllang = "en_us"
o.spell = true
