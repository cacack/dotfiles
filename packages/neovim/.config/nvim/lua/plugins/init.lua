return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      -- https://mason-registry.dev/registry/list
      ensure_installed = {
        -- python
        "pyright",
        "ruff",
        "black",

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
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
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
    },
  },
}
