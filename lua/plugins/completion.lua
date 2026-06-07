return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "enter", -- 保持回车确认
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-k>"] = { "fallback" },
      },
    },
  },
}
