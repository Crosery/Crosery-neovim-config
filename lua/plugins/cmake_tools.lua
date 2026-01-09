return {
  {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    lazy = true,
    init = function()
      local loaded = false
      local function check()
        local cwd = vim.uv.cwd()
        if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
          require("lazy").load({ plugins = { "cmake-tools.nvim" } })
          loaded = true
        end
      end
      check()
      vim.api.nvim_create_autocmd("DirChanged", {
        callback = function()
          if not loaded then check() end
        end,
      })
    end,
    opts = {
      cmake_kits_path = vim.fn.expand("~/.config/nvim/cmake/cmake-kits.json"),

      -- 构建使用 quickfix，避免终端阻塞
      cmake_executor = {
        name = "quickfix",
        opts = {
          show = "always",
          position = "belowright",
          size = 10,
        },
      },

      -- 运行使用 toggleterm，添加 on_exit 回调加速退出
      cmake_runner = {
        name = "toggleterm",
        opts = {
          direction = "float",
          close_on_exit = false,
          singleton = true,
          on_exit = function(_, _, _, _)
            -- 空回调，加速进程退出处理
          end,
        },
      },

      cmake_dap_configuration = {
        name = "cpp",
        type = "codelldb",
        request = "launch",
        stopOnEntry = false,
        runInTerminal = true,
        console = "integratedTerminal",
      },
    },

    keys = {
      { "<leader>m", "", desc = "+CMake" },
      { "<leader>ms", "<cmd>CMakeSelectKit<cr>", desc = "选择 Kit" },
      { "<leader>mg", "<cmd>CMakeGenerate<cr>", desc = "生成项目" },
      { "<leader>mb", "<cmd>CMakeBuild<cr>", desc = "构建目标" },
      { "<leader>mr", "<cmd>CMakeRun<cr>", desc = "运行目标" },
      { "<leader>md", "<cmd>CMakeDebug<cr>", desc = "调试目标" },
      { "<leader>mt", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "选择启动目标" },
      { "<leader>mc", "<cmd>CMakeClean<cr>", desc = "清理构建" },
    },
  },
}
