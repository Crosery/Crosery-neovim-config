return {
  "MeanderingProgrammer/render-markdown.nvim",
  -- 推荐使用 ft (filetype) 来触发加载，更高效
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
  ---@module 'render_markdown'
  ---@type render-markdownder.md.UserConfig
  opts = {
    heading = { position = "inline", icons = { "󰼏 ", "󰎨 " } },
  },
}
