-- 文件：~/.config/nvim/lua/plugins/dap.lua
-- 作用：配置所有通用调试功能，包括 DAP 核心、UI 布局和自动化钩子

-- ============================================================================
-- 辅助函数：创建浮动窗口
-- ============================================================================
local function create_float_win(buf, opts)
  opts = opts or {}
  local width = opts.width or math.min(95, vim.o.columns - 10)
  local height = opts.height or math.min(25, vim.o.lines - 10)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = opts.title or "",
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(win, "winhighlight", "Normal:NormalFloat,FloatBorder:FloatBorder")
  vim.api.nvim_win_set_option(win, "cursorline", true)

  -- 快捷键关闭窗口
  local close = function()
    vim.api.nvim_win_close(win, true)
  end
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })

  return win
end

-- ============================================================================
-- 辅助函数：设置调试视图高亮
-- ============================================================================
local function setup_debug_highlights()
  local hl = vim.api.nvim_set_hl
  -- 通用
  hl(0, "DbgAddr", { fg = "#56b6c2", bold = true }) -- 地址 (青色)
  hl(0, "DbgTitle", { fg = "#61afef", bold = true }) -- 标题 (蓝色)
  hl(0, "DbgHeader", { fg = "#98c379" }) -- 表头 (绿色)
  hl(0, "DbgSep", { fg = "#5c6370" }) -- 分隔符 (灰色)
  hl(0, "DbgCurrent", { fg = "#e06c75", bold = true }) -- 当前行标记 (红色)
  hl(0, "DbgCurrentLine", { bg = "#3e4452" }) -- 当前行背景
  -- 汇编
  hl(0, "DbgSymbol", { fg = "#5c6370", italic = true }) -- 符号注释 (灰色斜体)
  -- 内存
  hl(0, "DbgAscii", { fg = "#98c379" }) -- ASCII (绿色)
  hl(0, "DbgHex", { fg = "#e5c07b" }) -- 十六进制 (黄色)
end

---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
  local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
    if config.type and config.type == "java" then
      ---@diagnostic disable-next-line: return-type-mismatch
      return new_args
    end
    return require("dap.utils").splitstr(new_args)
  end
  return config
end

return {
  -- ====================================================================
  -- 1. nvim-dap: 调试核心
  -- ====================================================================
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      { "theHamsta/nvim-dap-virtual-text", opts = {} },
    },
    keys = {
      -- 新增：IDE 风格的 F 键调试快捷键
      {
        "<F9>",
        function()
          require("dap").continue()
        end,
        desc = "运行/继续 (F9)",
      },
      {
        "<F2>",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "切换断点 (F2)",
      },
      {
        "<F8>",
        function()
          require("dap").step_over()
        end,
        desc = "单步步过 (F10)",
      },
      {
        "<F7>",
        function()
          require("dap").step_into()
        end,
        desc = "单步步入 (F7)",
      },
      {
        "<C-F9>",
        function()
          require("dap").step_out()
        end,
        desc = "步出 (Ctrl-F9)",
      },
      {
        "<F12>",
        function()
          require("dap").terminate()
        end,
        desc = "终止 (F12)",
      },

      -- 保留原有的 <leader>d... 快捷键，方便通过 which-key 查看
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "设置条件断点",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "切换断点",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "运行/继续",
      },
      {
        "<leader>da",
        function()
          require("dap").continue({ before = get_args })
        end,
        desc = "带参数运行",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "运行到光标处",
      },
      {
        "<leader>dg",
        function()
          require("dap").goto_()
        end,
        desc = "跳转到 (不执行)",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "步入",
      },
      {
        "<leader>dj",
        function()
          require("dap").down()
        end,
        desc = "向下",
      },
      {
        "<leader>dk",
        function()
          require("dap").up()
        end,
        desc = "向上",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "运行上次",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "步出",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_over()
        end,
        desc = "步过",
      },
      {
        "<leader>dP",
        function()
          require("dap").pause()
        end,
        desc = "暂停",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "切换 REPL",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "会话",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "终止",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "悬浮组件",
      },
      {
        "<leader>dd",
        function()
          local dap = require("dap")
          local session = dap.session()
          if not session then
            vim.notify("没有活动的调试会话", vim.log.levels.WARN)
            return
          end

          local frame = session.current_frame
          if not frame then
            vim.notify("没有可用的栈帧信息", vim.log.levels.WARN)
            return
          end

          session:request("disassemble", {
            memoryReference = frame.instructionPointerReference or tostring(frame.instructionPointerReference),
            instructionOffset = -50,
            instructionCount = 100,
          }, function(err, response)
            if err then
              vim.notify("获取汇编失败: " .. vim.inspect(err), vim.log.levels.ERROR)
              return
            end

            vim.schedule(function()
              setup_debug_highlights()

              local buf = vim.api.nvim_create_buf(false, true)
              vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

              local lines = {
                "  反汇编视图",
                "",
                "       │ 地址               │ 指令",
                "  ─────┼────────────────────┼"
                  .. string.rep("─", 60),
              }
              local current_line = nil
              local current_addr = frame.instructionPointerReference or ""

              if response and response.instructions then
                for _, inst in ipairs(response.instructions) do
                  local addr = inst.address or ""
                  local instr = inst.instruction or ""
                  local symbol = inst.symbol and ("  ; " .. inst.symbol) or ""
                  local marker = (addr == current_addr) and " >>> " or "     "
                  if addr == current_addr then
                    current_line = #lines + 1
                  end

                  local full_instr = instr .. symbol
                  if #full_instr > 55 then
                    full_instr = full_instr:sub(1, 52) .. "..."
                  end

                  table.insert(lines, string.format("  %s│ %-18s │ %s", marker, addr, full_instr))
                end
              else
                table.insert(lines, "       │                    │ 无法获取汇编指令")
              end
              table.insert(lines, "")

              vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
              vim.api.nvim_buf_set_option(buf, "modifiable", false)

              -- 高亮
              local ns = vim.api.nvim_create_namespace("dap_disasm")
              vim.api.nvim_buf_add_highlight(buf, ns, "DbgTitle", 0, 0, -1)
              vim.api.nvim_buf_add_highlight(buf, ns, "DbgHeader", 2, 0, -1)
              vim.api.nvim_buf_add_highlight(buf, ns, "DbgSep", 3, 0, -1)

              for i = 4, #lines - 2 do
                local line = lines[i + 1]
                if line then
                  if line:match(">>>") then
                    vim.api.nvim_buf_add_highlight(buf, ns, "DbgCurrent", i, 2, 7)
                    vim.api.nvim_buf_add_highlight(buf, ns, "DbgCurrentLine", i, 0, -1)
                  end
                  vim.api.nvim_buf_add_highlight(buf, ns, "DbgSep", i, 7, 8)
                  vim.api.nvim_buf_add_highlight(buf, ns, "DbgSep", i, 27, 28)
                  vim.api.nvim_buf_add_highlight(buf, ns, "DbgAddr", i, 9, 27)
                  local sym_pos = line:find(";")
                  if sym_pos then
                    vim.api.nvim_buf_add_highlight(buf, ns, "DbgSymbol", i, sym_pos - 1, -1)
                  end
                end
              end

              local win = create_float_win(buf, { width = 100, height = 35, title = "  反汇编 " })
              if current_line then
                vim.api.nvim_win_set_cursor(win, { current_line, 0 })
                vim.cmd("normal! zz")
              end
            end)
          end)
        end,
        desc = "查看汇编",
      },
      {
        "<leader>dm",
        function()
          local dap = require("dap")
          local session = dap.session()
          if not session then
            vim.notify("没有活动的调试会话", vim.log.levels.WARN)
            return
          end

          -- 内存读取并显示函数
          local function show_memory(addr, byte_count)
            byte_count = byte_count or 256
            session:request("readMemory", {
              memoryReference = addr,
              count = byte_count,
            }, function(err, response)
              if err then
                vim.schedule(function()
                  vim.notify("读取内存失败: " .. vim.inspect(err), vim.log.levels.ERROR)
                end)
                return
              end

              vim.schedule(function()
                setup_debug_highlights()

                local buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

                local data = response.data or ""
                local decoded = vim.base64.decode(data)
                local bytes = { string.byte(decoded, 1, #decoded) }

                local lines = {
                  string.format("  内存视图: %s (%d 字节)", addr, #bytes),
                  "",
                  "  地址               │ 00 01 02 03 04 05 06 07  08 09 0A 0B 0C 0D 0E 0F │ ASCII",
                  "  ──────────────────┼─────────────────────────────────────────────────┼─────────────────",
                }

                local addr_num = addr:gsub("^0x", "")
                local base_addr = tonumber(addr_num, 16) or 0

                for i = 1, #bytes, 16 do
                  local hex_part, ascii_part = "", ""
                  for j = 0, 15 do
                    local idx = i + j
                    if idx <= #bytes then
                      local byte = bytes[idx]
                      hex_part = hex_part .. string.format("%02X ", byte)
                      ascii_part = ascii_part .. ((byte >= 32 and byte <= 126) and string.char(byte) or ".")
                    else
                      hex_part = hex_part .. "   "
                      ascii_part = ascii_part .. " "
                    end
                    if j == 7 then
                      hex_part = hex_part .. " "
                    end
                  end
                  table.insert(lines, string.format("  0x%016X │ %s│ %s", base_addr + i - 1, hex_part, ascii_part))
                end

                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                vim.api.nvim_buf_set_option(buf, "modifiable", false)

                -- 高亮
                local ns = vim.api.nvim_create_namespace("memory_view")
                vim.api.nvim_buf_add_highlight(buf, ns, "DbgTitle", 0, 0, -1)
                vim.api.nvim_buf_add_highlight(buf, ns, "DbgHeader", 2, 0, -1)
                vim.api.nvim_buf_add_highlight(buf, ns, "DbgSep", 3, 0, -1)

                for i = 4, #lines - 1 do
                  vim.api.nvim_buf_add_highlight(buf, ns, "DbgAddr", i, 2, 22)
                  vim.api.nvim_buf_add_highlight(buf, ns, "DbgSep", i, 22, 23)
                  vim.api.nvim_buf_add_highlight(buf, ns, "DbgAscii", i, 74, -1)
                end

                create_float_win(buf, { width = 95, height = 25, title = " 󰍛 内存查看器 " })
              end)
            end)
          end

          -- 获取变量地址
          local function try_get_address(var_name, callback)
            local frame_id = session.current_frame and session.current_frame.id
            local captured_output = ""

            -- 临时监听 output 事件
            local orig_handler = dap.listeners.after.event_output["memory_view"]
            dap.listeners.after.event_output["memory_view"] = function(_, body)
              if body and body.output then
                captured_output = captured_output .. body.output
              end
            end

            -- 发送 p &a 命令
            session:request("evaluate", {
              expression = "p &" .. var_name,
              frameId = frame_id,
              context = "repl",
            }, function()
              -- 延迟一点以确保 output 事件被处理
              vim.defer_fn(function()
                -- 移除监听器
                dap.listeners.after.event_output["memory_view"] = orig_handler

                -- 从捕获的输出中提取地址
                local addr = captured_output:match("0x%x+")
                if addr then
                  callback(addr)
                else
                  vim.notify("无法提取地址，输出: [" .. captured_output .. "]", vim.log.levels.WARN)
                end
              end, 100)
            end)
          end

          -- 获取用户输入
          vim.ui.input({ prompt = "内存地址 (0x...) 或变量名: " }, function(input)
            if not input or input == "" then
              return
            end

            -- 如果是十六进制地址，直接读取
            if input:match("^0x") then
              show_memory(input)
              return
            end

            -- 否则尝试获取变量地址
            try_get_address(input, function(addr)
              vim.schedule(function()
                show_memory(addr)
              end)
            end)
          end)
        end,
        desc = "查看内存",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- 钩子 1: 在调试会话成功初始化后触发
      dap.listeners.after.event_initialized["dapui_config"] = function()
        -- 核心逻辑：强制关闭所有侧边栏
        local function force_close_sidebars()
          -- 关闭 Snacks Explorer / Picker (LazyVim 新版默认)
          if _G.Snacks then
            pcall(function()
              for _, p in ipairs(_G.Snacks.picker.get()) do
                p:close()
              end
            end)
          end
          -- 关闭 Neo-tree (兼容旧配置)
          if package.loaded["neo-tree"] then
            pcall(function() vim.cmd("Neotree close") end)
          end
        end

        -- 第一波关闭：立刻执行
        force_close_sidebars()
        
        -- 打开调试界面
        dapui.open()

        -- 第二波关闭：延迟执行（针对 UI 渲染滞后的情况）
        -- 增加多个时间点的检查，确保万无一失
        vim.defer_fn(force_close_sidebars, 50)
        vim.defer_fn(force_close_sidebars, 200)
        vim.defer_fn(force_close_sidebars, 500)
      end

      -- 钩子 2: 在调试会话终止或退出前触发
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- --- 保留你原有的 config 内容 ---
      if LazyVim.has("mason-nvim-dap.nvim") then
        require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
      end

      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      for name, sign in pairs(LazyVim.config.icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      local vscode = require("dap.ext.vscode")
      local json = require("plenary.json")
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end
    end,
  },

  -- ====================================================================
  -- 2. nvim-dap-ui: 调试界面
  -- ====================================================================
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.40 }, -- 变量区改回 40% (主力显示)
            { id = "stacks", size = 0.25 }, -- 栈 25%
            { id = "breakpoints", size = 0.20 }, -- 断点 20%
            { id = "watches", size = 0.15 }, -- 监视 15%
          },
          size = 40,
          position = "left",
        },
        {
          -- 底部布局：只保留 repl 和 console，且高度增加
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 15, -- 增加高度，避免挤压
          position = "bottom",
        },
      },
      floating = {
        max_height = nil,
        max_width = nil,
        border = "rounded",
        mappings = { close = { "q", "<Esc>" } },
      },
      windows = { indent = 1 },
      -- 显式配置按键映射
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" }, -- 回车 或 鼠标双击 展开/收起
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
    },
  },
}
