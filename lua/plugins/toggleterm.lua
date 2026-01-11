return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      -- 你可以在这里进行一些全局的 toggleterm 设置
      -- 例如，默认打开的窗口大小
      size = 20,
      open_mapping = [[<c-t>]], -- 设置一个打开普通终端的快捷键
      direction = "float", -- 默认方向为浮动
      -- 其他设置...
    })

    -------------------------------------------------------------------------
    -- 智能终端管理器工厂函数
    -------------------------------------------------------------------------
    local Terminal = require("toggleterm.terminal").Terminal

    -- 用来记录每个工具上次运行的目录
    local last_cwds = {
      opencode = nil,
      codex = nil,
    }

    -- 创建自定义终端的辅助函数
    local function create_tool_terminal(name, cmd, keymap_desc)
      -- 内部变量存储当前实例
      local term_instance = nil

      -- 辅助函数：创建新实例
      local function create_new_term()
        return Terminal:new({
          cmd = cmd,
          hidden = true,
          direction = "float",
          float_opts = {
            border = "curved",
            width = 120,
            height = 35,
            title_pos = "center",
            title = " " .. name .. " ",
          },
          on_open = function(term)
            vim.api.nvim_win_set_option(term.window, "wrap", true)

            -- 绑定按键：按 Esc 发送给终端程序
            vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
            -- 绑定按键：按 Ctrl+q 直接关闭窗口
            vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-q>", "<cmd>close<CR>", { noremap = true, silent = true })
          end,
        })
      end

      -- 返回切换函数
      return function()
        local current_cwd = vim.fn.getcwd()

        -- 情况1: 还没创建过实例 -> 创建并打开
        if not term_instance then
          term_instance = create_new_term()
          term_instance.dir = current_cwd
          term_instance:open()
          last_cwds[name] = current_cwd
          return
        end

        -- 情况2: 目录变了 -> 彻底销毁旧的，创建新的并打开
        if last_cwds[name] and last_cwds[name] ~= current_cwd then
          term_instance:shutdown() -- 杀掉旧进程
          term_instance = create_new_term() -- 创建新对象
          term_instance.dir = current_cwd
          term_instance:open() -- 直接打开，不要用 toggle
          last_cwds[name] = current_cwd
          return
        end

        -- 情况3: 目录没变 -> 正常切换显隐
        term_instance:toggle()
      end
    end

    -------------------------------------------------------------------------
    -- 1. OpenCode (<leader>oq)
    -------------------------------------------------------------------------
    local toggle_opencode = create_tool_terminal("OpenCode", "opencode", "Toggle OpenCode")
    vim.keymap.set("n", "<leader>oq", toggle_opencode, { noremap = true, silent = true, desc = "Toggle OpenCode" })

    -------------------------------------------------------------------------
    -- 2. Codex (<leader>ow)
    -------------------------------------------------------------------------
    local toggle_codex = create_tool_terminal("Codex", "codex", "Toggle Codex")
    vim.keymap.set("n", "<leader>ow", toggle_codex, { noremap = true, silent = true, desc = "Toggle Codex" })

    -------------------------------------------------------------------------
    -- 3. Claudecode (<leader>oe)
    -------------------------------------------------------------------------
    local toggle_opencode = create_tool_terminal("ClaudeCode", "claude", "Toggle Claudecode")
    vim.keymap.set("n", "<leader>oe", toggle_opencode, { noremap = true, silent = true, desc = "Toggle Claudecode" })
  end,
  opts = {},
}
