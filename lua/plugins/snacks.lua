-- 覆盖 LazyVim 默认的 snacks.nvim 键位
-- <leader>E / <leader>fE 改为用 Nautilus 打开当前文件所在目录
local function open_in_nautilus()
  local dir = vim.fn.expand("%:p:h")
  vim.fn.jobstart({ "nautilus", dir }, { detach = true })
  vim.notify("Nautilus: " .. dir, vim.log.levels.INFO)
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>E", open_in_nautilus, desc = "系统文件管理器打开当前目录" },
      { "<leader>fE", open_in_nautilus, desc = "系统文件管理器打开当前目录" },
      -- 禁用 LazyVim 默认的 Snacks.terminal，改用 toggleterm
      { "<c-/>", false },
      { "<c-_>", false },
      { "<leader>ft", false },
      { "<leader>fT", false },
    },
    opts = {
      picker = {
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["<c-t>"] = false, -- 禁用 explorer 里的终端绑定
                },
              },
            },
          },
        },
      },
    },
  },
}
