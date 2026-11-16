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

Language servers and formatters are installed, pinned and locked by the
dotfiles' mise configs, not Mason: light tier in `configs/.config/mise/config.toml`
(every machine: Lua, Markdown, TOML, shell, Docker), heavy tier in
`config.desktop.toml` (desktops). `lua/configs/tools.lua` enables the servers for
the machine's tier (`MISE_ENV=desktop`, or the profile file).

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

### Formatters & Tools (via mise)

- **Python**: ruff, black
- **Go**: gofumpt, goimports-reviser
- **Rust**: rustfmt (from the mise rust toolchain)
- **Terraform**: tflint (tfsec was folded into Trivy, which the dotfiles install)
- **Lua**: stylua
- **Web**: prettier
- **Shell**: shfmt (shellcheck comes from the dotfiles' light mise set)
- **Docker**: hadolint
- **Markdown**: mdformat

## Key Configuration Files

### lua/chadrc.lua:15

Base configuration with "onedark" theme selected

### lua/configs/tools.lua

Language servers to enable per tier (lspconfig reads it), including the YAML LSP's Cloud Custodian schema and ts_ls's tsserver path

### lua/options.lua:8-9

Spell checking enabled for US English

## Common Development Tasks

### Adding Language Support

1. Pin the server in the dotfiles' mise config (`config.toml` if it is a self-contained binary, else `config.desktop.toml`), run `make mise-lock`, and enable it in `lua/configs/tools.lua` in the same tier
1. Add Treesitter parser to `lua/plugins/init.lua` treesitter ensure_installed
1. Add a formatter to the mise config and `lua/configs/conform.lua` if needed

### Theme Customization

Modify `lua/chadrc.lua` M.base46 table for theme changes

### Custom Keymaps

Add to `lua/mappings.lua` (loaded via vim.schedule in init.lua)

## Installation Dependencies

Neovim configuration installs automatically via Lazy.nvim:

- Language servers and formatters via the dotfiles' `make tools` (mise); Mason installs nothing
- Plugins via Lazy.nvim
- Treesitter parsers automatically

## Special Features

- **Cloud Custodian**: YAML schema support for `*.yml` files
- **Format on save**: Conform.nvim configured with "BufWritePre" event
- **Spell checking**: Enabled by default for US English
- **Modern LSP**: Uses vim.lsp.enable() and vim.lsp.config() (new Neovim API)

