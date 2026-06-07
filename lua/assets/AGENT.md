# lua/assets — 非插件数据

不参与 lazy.nvim spec 自动加载，被代码 `require` 或读取。

## 子目录

### `header_img/`

alpha 启动页头图。每个 `.lua` 文件 `return` 一个 dashboard layout block，由 `lua/plugins/my-alpha.lua` 的 `load_random_header` 随机选一张展示。

当前：
- `muguizi.lua` — 像素艺术，约 4000 行 `vim.api.nvim_set_hl` + `text` 段

新增头图：
1. 把图导出成 ASCII / 像素艺术
2. 写成 `return { type="text", val={...}, opts={position="center"} }` 形式（参考 muguizi.lua 结构）
3. 放到本目录，文件名任意
4. alpha 启动会自动扫描

## 命名规则

不用 `init.lua`（避免和 module 加载机制混淆）。文件名即资源标识。
