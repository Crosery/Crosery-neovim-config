local os_util = require("util.os")
local function open_in_file_manager()
  local dir = vim.fn.expand("%:p:h")
  os_util.open(dir)
  vim.notify("打开目录: " .. dir, vim.log.levels.INFO)
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>fo", open_in_file_manager, desc = "系统文件管理器打开当前目录" },
      -- 禁用 LazyVim 默认的 Snacks.terminal，改用 toggleterm
      { "<c-/>", false },
      { "<c-_>", false },
      { "<leader>ft", false },
      { "<leader>fT", false },
    },
    opts = {
      explorer = { enabled = false },
    },
  },
}
