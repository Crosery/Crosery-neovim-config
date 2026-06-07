-- neovide配置
if vim.g.neovide then
  vim.o.guifont = "JetBrainsMono Nerd Font:h18"
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_scale_factor = 0.9
  vim.g.snake_animate = false
  vim.g.neovide_theme = "dark"
  vim.g.neovide_background_image = "~/background/1.png"
  vim.g.neovide_background_transparency = 0.5
end

-- neovim配置
vim.lsp.log.set_level("off")

-- 自动保存
vim.g.auto_save = 1
vim.g.auto_save_interval = 1

-- 此文件由 plugins.core 自动加载，用于配置 Neovim 的核心选项

-- =============================================================================
-- 全局变量设置 (vim.g)
-- 这些变量通常用于配置插件或 Neovim 的全局行为
-- =============================================================================

-- 设置 <Leader> 键为空格键。 "Leader" 键是自定义快捷键的前缀。
-- 例如，你可以将快捷键设置为 <Leader>f，它实际就是 "空格 + f"。
vim.g.mapleader = " "
-- 设置 <LocalLeader> 键为反斜杠 `\`。 "LocalLeader" 用于设置仅在特定文件类型中生效的局部快捷键。
vim.g.maplocalleader = "\\"

-- LazyVim 自动格式化功能。设置为 true 时，会在保存文件时自动进行格式化。
vim.g.autoformat = true

-- Snacks 动画效果开关。
-- "Snacks" 是一个用于显示动画效果的插件库。设置为 `false` 可以全局禁用所有相关动画。
vim.g.snacks_animate = true

-- 配置 LazyVim 使用的模糊查找器（picker）。
-- 可选值: "telescope", "fzf"。
-- 设置为 "auto" 会自动使用通过 `:LazyExtras` 启用的那个查找器。
vim.g.lazyvim_picker = "fzf"

-- 配置 LazyVim 使用的代码补全引擎。
-- 可选值: "nvim-cmp", "blink.cmp"。
-- 设置为 "auto" 会自动使用通过 `:LazyExtras` 启用的那个补全引擎。
vim.g.lazyvim_cmp = "auto"


-- 如果当前的补全引擎支持 AI 补全源（例如 Copilot），
-- 设置为 true 会把 AI 放进补全菜单；设置为 false 则关闭 AI 补全菜单源。
vim.g.ai_cmp = true

-- LazyVim 的项目根目录检测规则。
-- 它会按顺序尝试以下方法来确定项目根目录：
-- 1. "lsp": 询问当前活动的 LSP (语言服务器) 认为的根目录是什么。
-- 2. { ".git", "lua" }: 向上查找是否存在 `.git` 目录或 `lua` 目录。
-- 3. "cwd": 如果以上都失败，则使用当前工作目录 (current working directory) 作为根目录。
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- 在使用 "lsp" 规则检测项目根目录时，需要忽略的 LSP 服务器列表。
-- 这很有用，因为像 "copilot" 这样的全局 LSP 服务器不应该被用来决定项目根目录。
vim.g.root_lsp_ignore = { "copilot" }

-- 隐藏关于插件或 Neovim API 的弃用警告。
vim.g.deprecation_warnings = false

-- 在状态栏（lualine）中显示来自 Trouble 插件的当前文档符号位置信息。
-- 你可以在某个特定缓冲区中通过 `vim.b.trouble_lualine = false` 来临时禁用它。
vim.g.trouble_lualine = true

-- =============================================================================
-- 核心编辑器选项 (vim.opt)
-- 这是对 Neovim 核心功能进行精细调整的地方
-- =============================================================================

local opt = vim.opt

opt.autowrite = true -- 启用自动写入。在执行某些命令（如 :make）时自动保存文件。

-- 设置剪贴板。如果不在 SSH 会话中，则使用 "unnamedplus" 与系统剪贴板同步。
-- 在 SSH 会话中设置为空，是为了让 OSC 52 终端协议能够自动工作（实现远程复制粘贴）。
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

opt.completeopt = "menu,menuone,noselect" -- 自动补全菜单的选项：总是显示菜单，即使只有一个匹配项，并且不自动选择第一项。
opt.conceallevel = 2 -- 隐藏 Markdown 中的加粗/斜体等标记符号，使其显示为实际样式。
opt.confirm = true -- 在退出修改过的缓冲区前，弹出确认提示。
opt.cursorline = true -- 高亮显示当前光标所在的行。
opt.expandtab = true -- 输入 Tab 键时，自动转换为空格。
opt.fillchars = { -- 自定义 UI 元素的显示字符
  foldopen = "", -- 折叠打开时的图标
  foldclose = "", -- 折叠关闭时的图标
  fold = " ", -- 折叠区域的填充字符
  foldsep = " ", -- 折叠区域的分隔符
  diff = "╱", -- diff 模式下的分隔符
  eob = " ", -- 文件末尾（End of Buffer）的标记，设置为空格以隐藏 `~`
}
opt.foldlevel = 99 -- 默认打开所有折叠。
opt.foldmethod = "indent" -- 使用基于缩进的折叠方式。
opt.foldtext = "" -- 不显示折叠区域的替代文本。
opt.formatexpr = "v:lua.LazyVim.format.formatexpr()" -- 设置格式化表达式，由 LazyVim 的格式化函数处理。
opt.formatoptions = "jcroqlnt" -- 格式化选项，控制自动格式化的行为。
opt.grepformat = "%f:%l:%c:%m" -- `grep` 命令输出的格式。
opt.grepprg = "rg --vimgrep" -- 使用 `ripgrep` (rg) 作为 `grep` 的替代程序，性能更好。
opt.ignorecase = true -- 搜索时忽略大小写。
opt.inccommand = "nosplit" -- 在执行替换命令时，实时预览替换效果，并且不创建新的分割窗口。
opt.jumpoptions = "view" -- 在跳转（例如使用 '`' 或 tag）时，尽量保持视图不变。
opt.laststatus = 3 -- 总是显示全局状态栏。
opt.linebreak = true -- 在单词边界处进行软换行，避免截断单词。
opt.list = true -- 显示一些不可见的字符（如 Tab）。
opt.mouse = "a" -- 在所有模式下启用鼠标支持。
opt.number = true -- 显示行号。
opt.pumblend = 10 -- 弹出菜单（比如补全菜单）的半透明度。
opt.pumheight = 10 -- 弹出菜单的最大高度（显示的条目数）。
opt.relativenumber = true -- 显示相对行号（当前行为绝对行号，其他行为相对距离）。
opt.ruler = false -- 禁用默认的状态栏标尺，因为 lualine 提供了更丰富的信息。
opt.scrolloff = 4 -- 在垂直滚动时，光标距离窗口顶部/底部的最小保留行数。
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" } -- 定义 `:mksession` 保存的内容。
opt.shiftround = true -- 缩进时，对齐到最近的 `shiftwidth` 倍数。
opt.shiftwidth = 2 -- 每次缩进的空格数。
opt.shortmess:append({ W = true, I = true, c = true, C = true }) -- 简化一些冗长的消息提示。
opt.showmode = false -- 不显示默认的模式指示（如 `-- INSERT --`），因为状态栏会显示。
opt.sidescrolloff = 8 -- 在水平滚动时，光标距离窗口左/右边缘的最小保留列数。
opt.signcolumn = "yes" -- 始终显示符号列（用于显示 Git 状态、诊断图标等），避免文本跳动。
opt.smartcase = true -- 如果搜索模式中包含大写字母，则自动切换为大小写敏感搜索。
opt.smartindent = true -- 启用智能自动缩进。
opt.smoothscroll = true -- 启用平滑滚动效果。
opt.spelllang = { "en" } -- 默认的拼写检查语言为英语。
opt.splitbelow = true -- 创建新的水平分割窗口时，新窗口出现在当前窗口下方。
opt.splitkeep = "screen" -- 调整分割窗口大小时，尽量保持光标在屏幕上的位置。
opt.splitright = true -- 创建新的垂直分割窗口时，新窗口出现在当前窗口右侧。
opt.statuscolumn = [[%!v:lua.LazyVim.statuscolumn()]] -- 使用 LazyVim 的 Lua 函数来自定义状态列（行号左侧区域）。
opt.tabstop = 2 -- 一个 Tab 字符代表的空格数。
opt.termguicolors = true -- 启用 24 位真彩色支持，让颜色主题显示更精确。
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- 300ms 触发 which-key 弹窗；弹窗弹出后不再受 timeout 限制，可慢慢按下个键
opt.undofile = true -- 启用撤销历史文件，这样关闭 Neovim 后再打开，仍然可以撤销之前的修改。
opt.undolevels = 10000 -- 最大的撤销次数。
opt.updatetime = 200 -- 更新时间间隔（毫秒）。用于触发 `CursorHold` 事件和写入交换文件。
opt.virtualedit = "block" -- 在可视块模式下，允许光标移动到没有文本的区域。
opt.wildmode = "longest:full,full" -- 命令行补全模式的行为。
opt.winminwidth = 5 -- 窗口的最小宽度。
opt.wrap = false -- 默认禁用自动换行（软换行）。

-- =============================================================================
-- 特定插件的设置
-- =============================================================================

-- 修复 Markdown 文件的缩进设置。
-- 这是针对某个 Markdown 插件的特定选项，用于禁用其推荐的样式。
vim.g.markdown_recommended_style = 0

-- 禁用不使用的 providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

-- 默认关闭 AI 补全 (Copilot)
-- 可以使用 :Copilot enable 手动开启
vim.g.copilot_enabled = false
