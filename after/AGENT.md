# after/ — LSP 覆盖

Neovim 0.11+ 原生 LSP 风格：`after/lsp/<server>.lua` 在对应 LSP server 启动时被合并到 `vim.lsp.Config`。

## 当前

| 文件 | 作用 |
|---|---|
| `lsp/vtsls.lua` | 把 vtsls 的 filetypes 限定为 ts / js / tsx / jsx（默认还会触发 vue 等场景） |

## 新增规则

- 文件名 = LSP server 名（mason 注册名）
- `return` 一个 table，会合并进 `vim.lsp.config(<server>, opts)` 的 opts
- 字段直接对应 `vim.lsp.Config`：`filetypes` / `settings` / `init_options` / `capabilities` / `on_attach` 等
- 不在这里 `vim.lsp.enable()`——主配置 `lua/plugins/lsp.lua` 已经负责启用

## 与 lua/plugins/lsp.lua 的边界

- **`lua/plugins/lsp.lua`**：全局 LSP 行为（diagnostics 样式 / inlay hints / mason 安装列表 / 全 server 共享 capabilities 与 keys）。
- **`after/lsp/<server>.lua`**：单 server 局部覆盖。改单语言行为优先放这里，不污染主配置。
