-- =============================================================================
-- Part 1: lazy.nvim 插件管理器的安装与引导
-- =============================================================================

-- 定义 lazy.nvim 的安装路径。
-- vim.fn.stdpath("data") 通常指向 ~/.local/share/nvim (在 Linux/macOS 上)
-- 所以 lazypath 变量的值会是 ~/.local/share/nvim/lazy/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- 检查 lazy.nvim 是否已经存在。
-- (vim.uv or vim.loop) 是为了兼容不同版本的 Neovim API。
-- fs_stat 用来获取文件或目录的状态，如果不存在，就会返回 nil。
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- 如果 lazy.nvim 不存在，就从 GitHub 克隆它。
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  -- 使用 git clone 命令下载 lazy.nvim。
  -- --filter=blob:none: 这是一个性能优化选项，只克隆最新的提交，不下载历史版本的文件内容，可以加快克隆速度。
  -- --branch=stable: 指定克隆 "stable" 分支，以获取更稳定的版本。
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

  -- 检查 git clone 命令是否执行成功。
  -- vim.v.shell_error 不为 0 表示上一条系统命令执行失败了。
  if vim.v.shell_error ~= 0 then
    -- 如果克隆失败，显示错误信息。
    vim.api.nvim_echo({
      { "克隆 lazy.nvim 失败:\n", "ErrorMsg" }, -- 错误提示
      { out, "WarningMsg" }, -- 显示 git 命令的输出
      { "\n按任意键退出..." }, -- 退出提示
    }, true, {})
    vim.fn.getchar() -- 等待用户按键
    os.exit(1) -- 退出 Neovim
  end
end

-- 将 lazy.nvim 的路径添加到 Neovim 的运行时路径（runtimepath）的最前面。
-- 这确保了 Neovim 可以找到并加载 lazy.nvim。
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- Part 2: lazy.nvim 的核心配置
-- =============================================================================

-- 调用 lazy.nvim 的 setup 函数，开始配置插件。
require("lazy").setup({
  -- `spec` (specification) 定义了要加载的插件列表。
  spec = {
    -- 导入 LazyVim 官方插件集。
    -- 这会自动加载 LazyVim 预设的所有插件和配置。
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- 导入你自己的插件配置。
    -- `import = "plugins"` 会告诉 lazy.nvim 去加载 `lua/plugins/` 目录下的所有 .lua 文件。
    -- 你可以在这个目录中创建文件来添加新插件或覆盖 LazyVim 的默认设置。
    { import = "plugins" },
  },

  -- `defaults` 部分为所有插件设置默认行为。
  defaults = {
    -- `lazy = false`：默认情况下，只有 LazyVim 的核心插件是懒加载的。
    -- 你自己添加的插件（在 lua/plugins/ 目录下）会默认在启动时就加载。
    -- 如果你清楚所有插件的加载时机，可以设置为 `true`，让你的插件也默认懒加载，从而加快启动速度。
    lazy = false,

    -- `version = false`：建议保持为 false。
    -- 这会让 lazy.nvim 始终拉取插件的最新 git commit。
    -- 如果设置为 `true` 或 `"*"`，它会尝试使用插件的 "release" 版本，但很多插件的 release 版本可能已经过时，反而会导致问题。
    version = false, -- 总是使用最新的 git 提交
  },

  -- `install` 部分配置插件安装时的行为。
  install = {
    -- 在 lazy.nvim 安装插件时，临时使用 "tokyonight" 或 "habamax" 主题。
    -- 这样可以避免在安装过程中界面颜色混乱。
    colorscheme = { "tokyonight", "habamax" },
  },

  -- `checker` 部分配置插件更新检查。
  checker = {
    enabled = true, -- 启用自动检查插件更新的功能。
    notify = false, -- 当有更新时，不要自动弹出通知窗口。你可以手动运行 :Lazy update 来查看和更新。
  },

  -- `performance` 部分用于优化 Neovim 的启动和运行性能。
  performance = {
    rtp = {
      -- `disabled_plugins` 用于禁用一些 Vim 内置的不常用插件，以加快启动速度。
      disabled_plugins = {
        "gzip", -- 用于直接读写 .gz 文件
        -- "matchit",  -- 扩展了 '%' 的匹配功能，LazyVim 有更好的替代品
        -- "matchparen", -- 用于高亮匹配的括号，LazyVim 有更好的替代品
        -- "netrwPlugin",-- Vim 内置的文件浏览器，通常会被 nvim-tree 等插件替代
        "tarPlugin", -- 用于浏览 tar 文件
        "tohtml", -- 将代码转换为 HTML
        "tutor", -- Vim 教程
        "zipPlugin", -- 用于浏览 zip 文件
      },
    },
  },
})
