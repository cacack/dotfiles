local M = {}

-- Supported languages -- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
-- Additional config (aka modules) -- https://github.com/nvim-treesitter/nvim-treesitter#available-modules
M.treesitter = {
  ensure_installed = {
    "bash",
    "css",
    "dockerfile",
    "go",
    "html",
    "javascript",
    "json",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "python",
    "rust",
    "terraform",
    "toml",
    "typescript",
    "vim",
    "xml",
    "yaml",
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
}

-- Manages LSP servers, formatters, linters and debug adapters.
-- Configuration: https://github.com/williamboman/mason.nvim#configuration
-- Registry: https://mason-registry.dev/registry/list
M.mason = {
  ensure_installed = {
    -- python
    "black",
    "isort",
    "mypy",
    "pyright",
    "ruff",

    -- go
    "gofumpt",
    "goimports-reviser",
    "gopls",

    --rust
    "rust-analyzer",
    "rustfmt",

    -- terraform
    "terraform-ls",
    "tflint",
    "tfsec",

    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "deno",
    "html-lsp",
    "prettier",
    "typescript-language-server",
    "yaml-language-server",

    -- shell stuffs
    "bash-language-server",
    "shellcheck",
    "shfmt",
    "autotools-language-server",

    -- docker stuffs
    "hadolint",

    -- misc
    -- remark seems to be NodeJS specific; https://github.com/remarkjs/remark-language-server/issues/6
    -- "remark-language-server",
    -- "remark-cli",
    "mdformat",
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },

}

return M
