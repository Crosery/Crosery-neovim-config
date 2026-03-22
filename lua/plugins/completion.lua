return {
  {
    "saghen/blink.cmp",
    opts = {
      enabled = function()
        -- ACP 输入框使用自己的 / 命令补全，禁用 blink.cmp
        if vim.b.acp_input then return false end
        return true
      end,
      keymap = {
        preset = "enter", -- 保持回车确认
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-k>"] = { "fallback" },
      },
    },
  },
}
