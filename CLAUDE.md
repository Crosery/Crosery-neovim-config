# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

LazyVim-based Neovim configuration. Uses `lazy.nvim` as plugin manager with LazyVim as the base framework. Positioned as a **code reader** that pairs with Claude Code in an external window: nvim left, Claude Code right.

## Architecture

**Entry point**: `init.lua` → `require("config.lazy")`

**Core config** (`lua/config/`):
- `lazy.lua` — lazy.nvim bootstrap, plugin spec definition, disabled built-in plugins
- `options.lua` — editor settings (space leader, 2-space tabs, relative numbers, FZF picker, blink.cmp)
- `keymaps.lua` — custom keybindings
- `autocmds.lua` — autocommands (transparency, auto-reload, yank highlight, etc.)

**Plugins** (`lua/plugins/`): Each `.lua` file is auto-loaded by lazy.nvim and returns plugin spec(s). These override/extend LazyVim defaults.

**ACP package** (`lua/acp/`): Self-authored agent-communication-protocol package. Surfaced via `lua/plugins/acp.lua` (`<A-u>` toggle / `<A-i>` list). Reserved for future plugin work.

**LSP overrides** (`after/lsp/`): Per-language LSP configs (vtsls).

**Utilities** (`lua/util/`): Shared helpers (`os.lua` for cross-platform open, `preview.lua` for the preview toggle).

**Assets** (`lua/assets/`): Non-plugin data (`header_img/` for alpha dashboard headers).

**LazyVim extras** (via `lazyvim.json`): dap.core, clangd, json, markdown, python, rust, toml, alpha, neo-tree.

## Key Design Decisions

- **Transparency**: Autocmds zero out backgrounds for Normal, TabLine, BufferLine, etc. Custom orange separator color.
- **Theme switching**: `colorscheme.lua` top-level `theme` variable controls gruvbox vs dankcolors (base16-nvim with hot-reload).
- **Picker**: FZF-lua (not Telescope) as primary picker.
- **Completion**: blink.cmp (not nvim-cmp).
- **Neovide support**: Font, cursor effects, and transparency configured in `options.lua`.
- **Autosave**: Enabled globally (`vim.g.auto_save = 1`).

## Common Commands

```vim
:Lazy              " Plugin management UI
:Mason             " LSP/DAP/formatter/linter installer
:LazyExtras        " Enable/disable LazyVim modules
```

## Working with This Config

- Plugin specs go in `lua/plugins/` — one file per plugin or related group
- To override a LazyVim default plugin, create a spec with the same plugin name in `lua/plugins/`
- Language-specific LSP configs go in `after/lsp/`
- `lazy-lock.json` is the lockfile for reproducible plugin versions — commit changes to it
- Target languages: C/C++, Python, Rust, TypeScript (Flutter/C#/CMake removed in the reader-mode refactor — re-add via `lazyvim.json` extras + `lua/plugins/<lang>.lua` if needed)
- AI integration: external Claude Code only. Copilot/CopilotChat and the in-nvim AI CLI floating terminals (OpenCode/Codex/Claude/Gemini) were removed; do not re-add them without confirmation.
