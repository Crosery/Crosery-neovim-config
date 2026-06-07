# nvim — Agent 协作上下文

唯一的全项目级 AI 上下文文件。`CLAUDE.md` 通过 `@AGENT.md` 路由到这里。给人看的简介在 `README.md`，不要在两边重复信息。

## 定位

LazyVim + lazy.nvim。**代码阅读器**，配合外部 Claude Code 工作：nvim 左、Claude Code 右。本仓库不内嵌任何 AI CLI。

## 模块结构与自治

每个子目录维护自己的 `AGENT.md`。当编辑该目录的代码时主动 Read 对应文件，按其声明的规约工作。

| 路径 | 职责 | 文档 |
|---|---|---|
| `lua/config/` | lazy 引导 / options / keymaps / autocmds | `lua/config/AGENT.md` |
| `lua/plugins/` | 自定义/覆盖的插件 spec | `lua/plugins/AGENT.md` |
| `lua/acp/` | 自研 ACP agent 包（17 文件） | `lua/acp/AGENT.md` |
| `lua/util/` | 共享工具（os/preview） | `lua/util/AGENT.md` |
| `lua/assets/` | 非插件数据（alpha 头图） | `lua/assets/AGENT.md` |
| `after/lsp/` | 单语言 LSP 覆盖 | `after/AGENT.md` |

入口：`init.lua` → `lua/config/lazy.lua`。

## 工作流约束

- **AI 集成边界**：外部 Claude Code 唯一。不再添加 copilot / copilot-chat / 内嵌 AI CLI 浮动终端。如需破例必须用户先批准。
- **目标语言**：C/C++ (clangd) / Python / Rust / TypeScript (vtsls) / Lua。Flutter / C# / CMake 已在重构中砍掉，需要时显式恢复 `lazyvim.json` extras + 对应 `lua/plugins/<lang>.lua`。
- **LazyVim extras**（`lazyvim.json` 当前）：dap.core / clangd / json / markdown / python / rust / toml / alpha / neo-tree。
- **Picker**：FZF-lua（不要切回 Telescope）。
- **Completion**：blink.cmp（不要切回 nvim-cmp）。

## 设计决策

- **透明背景**：`lua/config/autocmds.lua` 第 10 个 autocmd 在 `ColorScheme/VimEnter` 清空一组 UI 组的 `guibg`。新增 UI 元素后透明失效，去这里追加组名。
- **主题切换**：`lua/plugins/colorscheme.lua` 顶部 `local theme` 控制 `gruvbox` / `dankcolors`。dankcolors 内联在该文件，保存触发热重载（`_G._dankcolors_watcher`）。
- **Neovide 专属**：字体 / 光标 vfx / 背景图，集中在 `lua/config/options.lua` 第 2-10 行。
- **自动保存**：全局 `vim.g.auto_save = 1`，间隔 1 秒。`<C-q>` 强退前先关 autosave 避免 E788。

## 文档维护规则

- **改代码必须同步动对应 `AGENT.md`**（雷区：改代码不更新文档）。
- **`README.md` 是给人看的**：项目是什么、怎么用。不写架构细节。
- **`AGENT.md` 是给 AI 看的**：架构、约束、扩展规则、设计决策。
- **任何 `AGENT.md` 不写"可能 / 应该 / 大概"**。引用字段名 / 行号前实测确认。

## 常用命令

```vim
:Lazy              " 插件管理
:Mason             " LSP/DAP/formatter/linter 安装器
:LazyExtras        " LazyVim 模块开关
:checkhealth       " 诊断
```

## 启动检查（headless）

```bash
nvim --headless -c "lua vim.defer_fn(function() local p=require('lazy').plugins(); local e=0; for _,pl in ipairs(p) do if pl._.loaded and pl._.loaded.err then e=e+1 end end; print('errs='..e); vim.cmd('qa!') end, 1500)"
```

期望 `errs=0`。`image.nvim: cannot query terminal size` 是 headless 下的正常警告，忽略。
