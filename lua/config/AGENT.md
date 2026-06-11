# lua/config — 核心引导与全局配置

`init.lua` → `require("config.lazy")` 后这 4 个文件按字母序自动加载（LazyVim 约定）。

## 文件职责

| 文件 | 职责 |
|---|---|
| `lazy.lua` | lazy.nvim bootstrap + 插件 spec 收集 + 禁用内置插件 |
| `options.lua` | `vim.g.*` / `vim.opt.*` 全局；neovide 专属配置头部 2-10 行 |
| `keymaps.lua` | 自定义键位 + 终端 Esc 退出 autocmd + URL/checkbox/gx 行为 + `<leader>oo`/`<leader>oO` 万能 open |
| `autocmds.lua` | 文件变动重载 / yank 高亮 / 透明背景 / `q` 关窗 / 拼写规则 |

## 关键约定

- **Leader**：`<Space>`；LocalLeader：`\`。空格在 normal 模式被映射为 `<Nop>` 防 timeout 提示（`keymaps.lua` 第 8 行）。
- **Picker**：`vim.g.lazyvim_picker = "fzf"`（`options.lua` 第 42 行）。
- **Completion**：`vim.g.lazyvim_cmp = "auto"`（实际由 blink.cmp 配置控制）。
- **Autosave**：`vim.g.auto_save = 1`、间隔 1 秒。`<C-q>` 强退前会关闭 autosave 避免 `E788`。
- **lazy 默认非懒加载**：`lazy.lua` `defaults.lazy = false`。新插件若启动慢，单独在该插件 spec 加 `lazy = true` + `event/cmd/ft`。

## 修改规则

- 改 `options.lua` 后实测：开 nvim 看预期是否生效。LazyVim 有些 opts 会被它自己的 plugin spec 覆盖。
- 改 `keymaps.lua` 时检查 `lua/plugins/which-key.lua` 的分组定义是否同步更新（leader 一级分组）。
- 改 `autocmds.lua` 的"透明背景"组：在该 autocmd 的 `groups` 列表追加新 highlight 组名，否则新 UI 透明失效。

## 禁止

- 不重新引入 `vim.g.copilot_enabled` / Copilot 启用键。AI 集成边界见根 `AGENT.md`。
- 不重置 `vim.g.lazyvim_picker` 切回 telescope。
