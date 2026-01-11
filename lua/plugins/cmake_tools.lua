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

    config = function(_, opts)
      local function check_cmake()
        if vim.fn.filereadable(vim.uv.cwd() .. "/CMakeLists.txt") ~= 1 then
          vim.notify("当前目录没有 CMakeLists.txt 文件", vim.log.levels.WARN)
          return false
        end
        return true
      end

      local function map(key, cmd, desc)
        vim.keymap.set("n", key, function()
          if check_cmake() then
            vim.cmd(cmd)
          end
        end, { desc = desc })
      end

      map("<leader>ms", "CMakeSelectKit", "选择 Kit")
      map("<leader>mg", "CMakeGenerate", "生成项目")
      map("<leader>mb", "CMakeBuild", "构建目标")
      map("<leader>mr", "CMakeRun", "运行目标")
      map("<leader>md", "CMakeDebug", "调试目标")
      map("<leader>mt", "CMakeSelectLaunchTarget", "选择启动目标")
      map("<leader>mc", "CMakeClean", "清理构建")

      require("cmake-tools").setup(opts)
    end,
  },
}
