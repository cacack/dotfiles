# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal Neovim configuration based on NvChad v2.5, providing a modern and feature-rich development environment with LSP support, formatting, and comprehensive language support.

## Includes

Include the following files:

- @.claude/REQUIREMENTS.md

## Architecture

The configuration follows NvChad's modular structure:

- **init.lua**: Bootstrap file that loads Lazy.nvim and NvChad
- **lua/chadrc.lua**: Main configuration file for NvChad customizations
- **lua/plugins/init.lua**: Custom plugin configurations and overrides
- **lua/configs/**: Configuration files for specific tools (LSP, formatting, etc.)
- **lua/options.lua**: Neovim options and settings
- **lua/mappings.lua**: Custom key mappings
- **lua/autocmds.lua**: Custom autocommands

## Plugin Management

Uses **Lazy.nvim** as the plugin manager with NvChad as the base framework:

- NvChad v2.5 branch is imported as the foundation
- Custom plugins are defined in `lua/plugins/init.lua`
- Plugin configurations are in `lua/configs/`

## Language Support

Tools come in two tiers, both listed in `lua/configs/tools.lua`: light (every
machine, binaries only: Lua, Markdown, TOML, shell lint/format, Docker) and
heavy (added when `MISE_ENV=desktop`; needs the go/node/python/rust runtimes
that the dotfiles' desktop mise profile installs).

### LSP Servers (enabled by `lua/configs/lspconfig.lua` from `tools.lua`)

- **Python**: pyright, ruff
- **Go**: gopls
- **Rust**: rust-analyzer
- **Terraform**: terraform-ls
- **JavaScript/TypeScript**: ts_ls
- **Web**: css-lsp, html-lsp
- **Shell**: bash-language-server
- **Lua**: lua-language-server
- **Markdown**: marksman
- **TOML**: taplo
- **YAML**: yaml-language-server (with Cloud Custodian schema support)

### Treesitter Parsers

Syntax highlighting and parsing for: bash, css, dockerfile, go, html, javascript, json, lua, make, markdown, python, rust, terraform, toml, typescript, vim, xml, yaml

### Formatters & Tools (via Mason)

- **Python**: ruff, black
- **Go**: gofumpt, goimports-reviser
- **Rust**: rustfmt (from the mise rust toolchain, not Mason)
- **Terraform**: tflint, tfsec
- **Lua**: stylua
- **Web**: prettier
- **Shell**: shfmt, shellcheck
- **Docker**: hadolint
- **Markdown**: mdformat

## Key Configuration Files

### lua/chadrc.lua:15

Base configuration with "onedark" theme selected

### lua/configs/tools.lua

Mason packages and language servers per tier (Mason's `ensure_installed` and lspconfig both read it), including the YAML LSP's Cloud Custodian schema

### lua/options.lua:8-9

Spell checking enabled for US English

## Common Development Tasks

### Adding Language Support

1. Add the Mason package and the LSP server to `lua/configs/tools.lua`: light only if it is a self-contained binary, otherwise heavy
1. Add Treesitter parser to `lua/plugins/init.lua` treesitter ensure_installed
1. Add a formatter to `tools.lua` and `lua/configs/conform.lua` if needed

### Theme Customization

Modify `lua/chadrc.lua` M.base46 table for theme changes

### Custom Keymaps

Add to `lua/mappings.lua` (loaded via vim.schedule in init.lua)

## Installation Dependencies

Neovim configuration installs automatically via Lazy.nvim:

- Language servers and tools via Mason
- Plugins via Lazy.nvim
- Treesitter parsers automatically

## Special Features

- **Cloud Custodian**: YAML schema support for `*.yml` files
- **Format on save**: Conform.nvim configured with "BufWritePre" event
- **Spell checking**: Enabled by default for US English
- **Modern LSP**: Uses vim.lsp.enable() and vim.lsp.config() (new Neovim API)

