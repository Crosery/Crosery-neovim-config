# nvim

Crosery 的私人 Neovim 配置，基于 [LazyVim](https://www.lazyvim.org/) + [lazy.nvim](https://github.com/folke/lazy.nvim)。

定位：配合 Claude Code 的代码阅读器 —— 文件树、模糊搜索、LSP 跳转、语法高亮、Markdown/CSV/PDF/图像渲染。

## 结构

- `init.lua` → `lua/config/lazy.lua` 引导 lazy.nvim
- `lua/config/` — options / keymaps / autocmds / lazy bootstrap
- `lua/plugins/` — 自定义/覆盖的插件 spec
- `lua/acp/` — 自研 ACP agent 包
- `lua/util/` — 共享工具
- `lua/assets/header_img/` — alpha 启动页头图
- `after/lsp/` — 单语言 LSP 覆盖（vtsls 等）
- `lazyvim.json` — LazyVim extras 列表

## 主题

`lua/plugins/colorscheme.lua` 顶部 `theme` 变量切换 `"gruvbox"` / `"dankcolors"`，后者是内联的 base16-nvim 配色，保存自动热重载。
