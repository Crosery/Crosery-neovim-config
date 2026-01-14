local map = LazyVim.safe_keymap_set

-- 全选 (空格 + v + a)
map("n", "<leader>va", "ggVG", { desc = "全选 (Visual All)" })
-- 选中当前行 (空格 + v + l)
map("n", "<leader>vl", "V", { desc = "选中行 (Line)" })

-- 全部退出 (Ctrl + q)
--    模式 { "n", "i", "v" } 意味着在普通、插入和可视模式下都可用
map({ "n", "i", "v" }, "<C-q>", "<cmd>qa<cr>", { desc = "全部退出 (Quit All)" })

-- 保存并退出 (空格 + w + q)
--    这是对标准 :wq 命令的快捷方式，更安全直观
map("n", "<leader>wq", "<cmd>wq<cr>", { desc = "保存并退出" })

-- 创建终端相关键位
map("n", "<leader>tl", "<cmd>vert term<cr>", { desc = "垂直分割终端 (Terminal Vertical)" })
map("n", "<leader>th", "<cmd>term<cr>", { desc = "水平分割终端 (Terminal Horizontal)" })
map("t", "<esc>", "<C-\\><C-n>", { desc = "退出终端模式 (Exit Terminal Mode)" })

-- LSP
-- LSP重启
map("n", "<C-l>r", "<cmd>LspRestart<cr>", { desc = "重启LSP (LSP Restart)" })
-- LSP更新
map("n", "<C-l>u", "<cmd>LspUpdate<cr>", { desc = "更新LSP (LSP Update)" })

-- AI copilot

-- 关闭ai补全
map("n", "<leader>ad", "<cmd>Copilot disable<cr>", { desc = "关闭AI补全 (AI Copilot Disable)" })
-- 开启ai补全
map("n", "<leader>ae", "<cmd>Copilot enable<cr>", { desc = "开启AI补全 (AI Copilot Enable)" })

-- insert mode下移动光标
map("i", "<C-a>", "<Left>", { desc = "向左移动" })
map("i", "<C-d>", "<Right>", { desc = "向右移动" })
map("i", "<C-w>", "<Up>", { desc = "向上移动" })
map("i", "<C-s>", "<Down>", { desc = "向下移动" })
