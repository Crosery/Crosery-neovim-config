return {
  -- gruvbox 主题
  { "ellisonleao/gruvbox.nvim" },

  -- 配置 LazyVim 使用 gruvbox 主题
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },

  -- 添加 transparent.nvim 插件，并配置为仅在非 Neovide 环境下启用
  {
    "xiyaowong/transparent.nvim",
    -- 关键：只有在 vim.g.neovide 不存在时，才启用此插件
    enabled = not vim.g.neovide,
    -- 避免延迟加载，确保启动时能正确清除背景高亮
    lazy = false,
    config = function()
      require("transparent").setup({
        -- 你可以保留默认的 groups，或者自定义
        extra_groups = {
          -- 添加这些可以让 Lazy.nvim, Mason 等浮动窗口也变透明
          "NormalFloat",
          -- 如果你使用 nvim-tree
          "NvimTreeNormal",
        },
        exclude_groups = {},
      })

      -- 在插件加载后，自动执行 :TransparentEnable 命令来开启透明效果
      vim.cmd("TransparentEnable")
    end,
  },
}
