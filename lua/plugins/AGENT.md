# lua/plugins — 插件 spec

lazy.nvim 自动导入本目录下所有 `.lua` 文件并合并到 spec tree。每个文件 `return` 一个 spec 或 spec 列表，可覆盖 LazyVim 默认插件（用相同插件名）。

## 当前清单（21 个）

| 文件 | 作用 |
|---|---|
| `colorscheme.lua` | gruvbox / dankcolors 切换 + base16 热重载 + transparent.nvim |
| `lsp.lua` | nvim-lspconfig 主配置，servers 列表、diagnostics、inlay hints |
| `nvim-treesitter.lua` | 语法高亮 + 语言安装列表 |
| `nvim-navic.lua` | 文档符号 breadcrumb |
| `fzf.lua` | FZF-lua picker 自定义 |
| `neo-tree.lua` | 文件树 + 模糊筛选 + 切换工作目录 |
| `which-key.lua` | leader 分组定义 |
| `lualine.lua` | 状态栏 |
| `noice.lua` | 命令行 / 通知 UI |
| `trouble.lua` | diagnostics quickfix UI |
| `snacks.lua` | LazyVim Snacks 覆盖（禁用 explorer + 内置终端） |
| `my-alpha.lua` | 启动页 dashboard，头图从 `lua/assets/header_img/` 随机选 |
| `markdown_render.lua` | render-markdown.nvim |
| `csv.lua` | csvview.nvim，自动启用 |
| `pdf.lua` | `BufReadCmd *.pdf` → pdftotext 转文本 |
| `img.lua` | image.nvim，kitty backend，markdown 图片渲染 |
| `toggleterm.lua` | 浮动 / 底部终端 + 切换；`<C-t>` / `<C-/>` |
| `dap.lua` | DAP 调试 UI 与 keymaps |
| `rust.lua` | rustaceanvim + codelldb DAP adapter |
| `completion.lua` | blink.cmp 键位 + 屏蔽 ACP input buffer 自动补全 |
| `acp.lua` | 加载 `lua/acp/` 包，绑定 `<A-u>` / `<A-i>` |

## 增删规则

- **一文件一插件**或一组紧密相关插件。不要把多个无关插件塞同一文件。
- **覆盖 LazyVim 默认**：spec 中 `[1]` 字段写完整 GitHub 仓库名（与 LazyVim 中一致），即可与默认配置合并。
- **删插件**：本目录直接删文件；如果该插件由 LazyVim extras 提供（`lazyvim.json` 列出的），还要去 `lazyvim.json` extras 列表里删一行。
- **新 LSP 语言**：先在 `lazyvim.json` extras 加 `lazyvim.plugins.extras.lang.<name>`，需要细调时再在本目录加 `<name>.lua` 覆盖。

## 已知禁区

- 不再添加 copilot / copilot-chat / 任何 in-nvim AI CLI 浮动终端集成（OpenCode/Codex/Claude/Gemini）。详见根 `AGENT.md` 的 AI 集成边界。
- 不重新加 leetcode / csharp / flutter-tools / cmake_tools——已在重构中砍掉。如需恢复请用户先批准。

## 键位冲突排查

- `which-key.lua` 的 leader 分组在 `<leader>a-z` 中声明。新插件用 leader 键时先看那里有没有占用，避免覆盖。
- 终端键位在 `toggleterm.lua` 内集中绑定（`<C-t>` / `<C-/>` / `<A-q/r/n/a/d/1-9>`）。
- ACP 键位在 `acp.lua`（`<A-u>` / `<A-i>`），不走 leader。
