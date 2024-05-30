-- https://nvchad.com/docs/config/mappings
---@type MappingsTable

local M = {}

-- For a more complex keymap
M.general = {
	n = {
    --  format with conform
    ["<leader>fm"] = {
      function()
        require("conform").format()
      end,
      "formatting",
    },
		["<leader>tt"] = {
			function()
				require("base46").toggle_transparency()
			end,
			"Toggle Transparency",
		},
    ["<leader>sh"] = {
      "*N",
      "Search and Highlight"
    },
    ["<leader>sr"] = {
      ":%s/<C-r><C-w>//g<Left><Left>",
      "Search and Replace"
    },
    ["<leader>ss"] = {
      "z=",
      "Spelling suggestions"
    },
	},

}

-- -- In order to disable a default keymap, use
-- M.disabled = {
--   n = {
--       ["<leader>h"] = "",
--       ["<C-a>"] = ""
--   }
-- }
--
-- -- Your custom mappings
-- M.abc = {
--   n = {
--      ["<C-n>"] = {"<cmd> Telescope <CR>", "Telescope"},
--      ["<C-s>"] = {":Telescope Files <CR>", "Telescope Files"}
--   },
--
--   i = {
--      ["jk"] = { "<ESC>", "escape insert mode" , opts = { nowait = true }},
--     -- ...
--   }
-- }

return M
