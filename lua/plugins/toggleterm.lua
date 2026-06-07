-- 记录最后活跃的终端 ID
local last_float = 1
local last_horiz = 11

-- 工具终端 ID 范围（100+），与普通终端完全隔离
local TOOL_ID_MIN = 100

-- 辅助函数：获取同类型终端的排序 ID 列表（排除工具终端）
local function get_ids(direction)
  local ids = {}
  for _, t in ipairs(require("toggleterm.terminal").get_all(true)) do
    if t.direction == direction and t.id < TOOL_ID_MIN then table.insert(ids, t.id) end
  end
  table.sort(ids)
  return ids
end

-- 浮动终端标题栏: | 1 | *2* | 3 |
local function build_float_title(current_id)
  local ids = get_ids("float")
  if #ids == 0 then return " Terminal " end
  local parts = {}
  for i, id in ipairs(ids) do
    if id == current_id then
      table.insert(parts, " *" .. i .. "* ")
    else
      table.insert(parts, " " .. i .. " ")
    end
  end
  return " " .. table.concat(parts, "|") .. " "
end

-- 确保不在浮动窗口中 (修复 toggleterm is_split bug)
local function escape_float()
  if vim.fn.win_gettype() ~= "popup" then return end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.fn.win_gettype(vim.api.nvim_win_get_number(win)) ~= "popup" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

-- 找下一个可用 ID
local function next_free_id(start)
  local used = {}
  for _, t in ipairs(require("toggleterm.terminal").get_all(true)) do
    used[t.id] = true
  end
  local id = start
  while used[id] do id = id + 1 end
  return id
end

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    -- <C-t>: 浮动终端 toggle
    {
      "<C-t>",
      function()
        -- 在终端模式下: 关闭当前终端
        local cur = require("toggleterm.terminal").get_focused_id()
        if cur then
          local term = require("toggleterm.terminal").get(cur)
          if term and term.direction == "float" then
            term:close()
            return
          end
        end
        -- 在普通模式下: 打开上次的浮动终端
        require("toggleterm").toggle(last_float, nil, nil, "float")
      end,
      mode = { "n", "t", "i" },
      desc = "Toggle float terminal",
    },
    -- <C-/>: 底部终端 toggle
    {
      "<C-/>",
      function()
        local cur = require("toggleterm.terminal").get_focused_id()
        if cur then
          local term = require("toggleterm.terminal").get(cur)
          if term and term.direction == "horizontal" then
            term:close()
            return
          end
        end
        escape_float()
        require("toggleterm").toggle(last_horiz, 15, nil, "horizontal")
      end,
      mode = { "n", "t", "i" },
      desc = "Toggle horizontal terminal",
    },
    {
      "<C-_>",
      function()
        local cur = require("toggleterm.terminal").get_focused_id()
        if cur then
          local term = require("toggleterm.terminal").get(cur)
          if term and term.direction == "horizontal" then
            term:close()
            return
          end
        end
        escape_float()
        require("toggleterm").toggle(last_horiz, 15, nil, "horizontal")
      end,
      mode = { "n", "t", "i" },
      desc = "Toggle horizontal terminal",
    },
  },
  config = function()
    local Terminal = require("toggleterm.terminal").Terminal

    -- 自定义 winbar: 只显示同类型终端的标签
    local function set_custom_winbar(term)
      if not term.window or not vim.api.nvim_win_is_valid(term.window) then return end
      if term.direction == "float" then return end -- 浮动终端用标题栏
      local ids = get_ids(term.direction)
      local parts = {}
      for i, id in ipairs(ids) do
        if id == term.id then
          table.insert(parts, "%#WinBarActive# *" .. i .. "* %*")
        else
          table.insert(parts, "%#WinBarInactive# " .. i .. " %*")
        end
      end
      pcall(vim.api.nvim_set_option_value, "winbar", table.concat(parts, "|"), { win = term.window })
    end

    require("toggleterm").setup({
      size = 20,
      direction = "float",
      float_opts = {
        border = "curved",
        title_pos = "center",
      },
      winbar = { enabled = false },
      on_open = function(term)
        -- 记录最后活跃的终端
        if term.direction == "float" then
          last_float = term.id
        elseif term.direction == "horizontal" then
          last_horiz = term.id
        end
        -- 浮动终端: 更新标题栏
        if term.direction == "float" and term.window and vim.api.nvim_win_is_valid(term.window) then
          pcall(vim.api.nvim_win_set_config, term.window, {
            title = build_float_title(term.id),
          })
        end
        -- 底部终端: 设置自定义 winbar
        set_custom_winbar(term)
        -- 异步进入终端模式（不干扰 toggle 序列）
        vim.schedule(function() vim.cmd("startinsert") end)
      end,
    })

    ---------------------------------------------------------------------------
    -- 终端内键位 (全部在终端模式 "t" 下)
    ---------------------------------------------------------------------------

    -- 切换同类型终端（供 Alt+a/d/r 复用）
    local function switch_same_type(delta)
      local cur_id = require("toggleterm.terminal").get_focused_id()
      if not cur_id then return end
      local cur_term = require("toggleterm.terminal").get(cur_id)
      if not cur_term then return end
      local dir = cur_term.direction
      local ids = get_ids(dir)
      if #ids < 2 then return end

      local idx = 1
      for i, v in ipairs(ids) do
        if v == cur_id then idx = i break end
      end
      local next_idx = ((idx - 1 + delta) % #ids) + 1
      local next_id = ids[next_idx]

      if dir == "float" then
        require("toggleterm").toggle(cur_id, nil, nil, "float")
        require("toggleterm").toggle(next_id, nil, nil, "float")
        last_float = next_id
      else
        cur_term:close()
        require("toggleterm.terminal").get(next_id):open()
        last_horiz = next_id
      end
    end

    -- Alt+q: 隐藏终端回到编辑器 (不销毁)
    vim.keymap.set("t", "<A-q>", function()
      local cur = require("toggleterm.terminal").get_focused_id()
      if cur then
        local term = require("toggleterm.terminal").get(cur)
        if term then term:close() end
      end
    end, { desc = "Hide terminal" })

    -- Alt+r: 销毁当前终端，跳到上一个
    vim.keymap.set("t", "<A-r>", function()
      local cur_id = require("toggleterm.terminal").get_focused_id()
      if not cur_id then return end
      local cur_term = require("toggleterm.terminal").get(cur_id)
      if not cur_term then return end
      local dir = cur_term.direction
      local ids = get_ids(dir)

      -- 找目标
      local target = nil
      for i, id in ipairs(ids) do
        if id == cur_id then
          if i > 1 then target = ids[i - 1]
          elseif #ids > 1 then target = ids[2]
          end
          break
        end
      end

      -- 销毁当前
      cur_term:shutdown()

      -- 打开目标
      if target then
        if dir == "float" then
          last_float = target
        else
          last_horiz = target
        end
        vim.defer_fn(function()
          if dir == "float" then
            vim.cmd(target .. "ToggleTerm direction=float")
          else
            escape_float()
            vim.cmd(target .. "ToggleTerm size=15 direction=horizontal")
          end
        end, 50)
      end
    end, { desc = "Remove current terminal" })

    -- Alt+n: 新建同类型终端
    vim.keymap.set("t", "<A-n>", function()
      local cur_id = require("toggleterm.terminal").get_focused_id()
      if not cur_id then return end
      local cur_term = require("toggleterm.terminal").get(cur_id)
      if not cur_term then return end
      local dir = cur_term.direction

      if dir == "float" then
        local new_id = next_free_id(1)
        require("toggleterm").toggle(cur_id, nil, nil, "float")
        require("toggleterm").toggle(new_id, nil, nil, "float")
        last_float = new_id
      else
        local new_id = next_free_id(11)
        cur_term:close()
        local new_term = Terminal:new({ id = new_id, direction = "horizontal" })
        new_term:open(15)
        last_horiz = new_id
      end
    end, { desc = "New terminal (same type)" })

    -- Alt+a / Alt+d: 左右切换
    vim.keymap.set("t", "<A-a>", function() switch_same_type(-1) end, { desc = "Prev terminal" })
    vim.keymap.set("t", "<A-d>", function() switch_same_type(1) end, { desc = "Next terminal" })

    -- Alt+1~9: 跳到同类型的第 N 个终端
    for i = 1, 9 do
      vim.keymap.set("t", "<A-" .. i .. ">", function()
        local cur_id = require("toggleterm.terminal").get_focused_id()
        if not cur_id then return end
        local cur_term = require("toggleterm.terminal").get(cur_id)
        if not cur_term then return end
        local dir = cur_term.direction
        local ids = get_ids(dir)
        if i > #ids or ids[i] == cur_id then return end
        local target_id = ids[i]
        if dir == "float" then
          require("toggleterm").toggle(cur_id, nil, nil, "float")
          require("toggleterm").toggle(target_id, nil, nil, "float")
          last_float = target_id
        else
          cur_term:close()
          require("toggleterm.terminal").get(target_id):open()
          last_horiz = target_id
        end
  
      end, { desc = "Jump to terminal #" .. i })
    end

  end,
}
