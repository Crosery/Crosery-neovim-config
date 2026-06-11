# lua/util — 共享工具

`require("util.<name>")` 调用。无第三方依赖，纯 Neovim API。

## 文件

### `os.lua`

跨平台 open / reveal 封装。

- `M.is_mac` / `M.is_linux` / `M.is_windows`：bool，从 `vim.uv.os_uname().sysname` 推。
- `M.opener()` → `"open"` / `"start"` / `"xdg-open"`
- `M.open(target)`：`jobstart({opener, target}, {detach=true})`
- `M.reveal(target)`：在系统文件管理器中定位 target。
  - mac → `open -R <target>`（Finder 选中）
  - windows → `explorer /select,<target>`
  - linux → `xdg-open <dirname(target)>`（无统一 select 语义，退化为打开父目录）

调用方：
- `lua/config/keymaps.lua` `gx` 行为：表格 / PDF / 图片 / 视频用外部程序打开。
- `lua/config/keymaps.lua` `<leader>oo` / `<leader>oO`：万能 open（buffer / neo-tree 节点 / visual 选区）+ reveal。
- `lua/plugins/snacks.lua` `<leader>fo`：系统文件管理器打开当前目录。

### `preview.lua`

按 filetype / 扩展名分派预览模式。

- `M.toggle()`（绑 `<leader>pv`，见 `keymaps.lua` 第 5 行）：
  - `csv` / `tsv` → `:CsvViewToggle`
  - `markdown` → `:RenderMarkdown toggle`
  - 图片扩展名（png/jpg/...）→ 提示 image.nvim 自动渲染
  - 二进制文件 → `hexyl --length 4096` 渲染（需要 `hexyl` 安装）
  - 否则 → `warn`
- `M.hexyl_view()` / `M.hexyl_restore()` 配对，用 `hexyl_buf` 表追踪关联。
- `M.is_binary()` 用首行存在 `\0` 判定。

## 增加新工具

- 新建 `lua/util/<name>.lua`，`return M`。
- 调用方 `local <name> = require("util.<name>")`。
- 工具应该是**纯函数 + Neovim API**，不依赖具体插件。需要插件时把工具放到对应 `lua/plugins/<plugin>.lua` 里。
