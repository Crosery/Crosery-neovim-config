return {
  "kawre/leetcode.nvim",

  dependencies = {
    "nvim-lua/plenary.nvim", -- Telescope 的依赖
    "MunifTanjim/nui.nvim",
  },

  opts = {

    -- 编程语言
    lang = "cpp",

    cn = { -- leetcode.cn
      enabled = true, ---@type boolean
      translator = true, ---@type boolean
      translate_problems = true, ---@type boolean
    },

    ---@type lc.storage
    storage = {
      home = vim.fn.stdpath("data") .. "/leetcode",
      cache = vim.fn.stdpath("cache") .. "/leetcode",
    },
  },
}
