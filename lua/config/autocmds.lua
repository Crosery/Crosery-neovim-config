-- 此文件由 lazyvim.config.init 自动加载

-- 定义一个函数，用于创建自动命令组（augroup）
-- 这样可以确保每次重载配置时，旧的命令组会被清空，避免重复执行
local function augroup(name)
  return vim.api.nvim_create_augroup("custom_cfg_" .. name, { clear = true })
end

-- 1. 当文件在外部被修改时，自动重新加载
-- 触发条件：重新聚焦 Neovim 窗口、关闭或离开终端时
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("自动检查文件变动"),
  callback = function()
    -- 仅对普通文件执行检查
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- 2. 复制文本后，高亮显示已复制的区域
-- 触发条件：执行复制（yank）操作后
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("复制时高亮"),
  callback = function()
    -- 使用 vim.highlight.on_yank() 提供视觉反馈
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- 3. 当 Neovim 窗口大小改变时，自动调整所有分割窗口的尺寸
-- 触发条件：Vim 窗口大小被调整
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("自动调整窗口分割"),
  callback = function()
    -- 记录当前所在的标签页
    local current_tab = vim.fn.tabpagenr()
    -- 对所有标签页执行窗口大小均衡命令
    vim.cmd("tabdo wincmd =")
    -- 切换回原来的标签页
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- 4. 打开文件时，自动跳转到上次光标所在的位置
-- 触发条件：文件被读取到缓冲区后
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("跳转到上次编辑位置"),
  callback = function(event)
    -- 定义一些不需要此功能的特殊文件类型
    local exclude = { "gitcommit" }
    local buf = event.buf
    -- 如果文件类型在排除列表，或已设置过标记，则直接返回
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    -- 获取上次光标位置的标记（"）
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    -- 如果标记有效，则跳转到该位置
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 5. 为某些特殊类型的窗口设置 'q' 键为关闭快捷键
-- 触发条件：文件类型（FileType）被设置时
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("用q关闭特定窗口"),
  -- 适用于以下文件类型
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    -- 将这些窗口设置为不在缓冲区列表中显示
    vim.bo[event.buf].buflisted = false
    -- 延迟执行，确保缓冲区已完全加载
    vim.schedule(function()
      -- 在当前缓冲区中，将 'q' 键映射为关闭窗口
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf, -- 仅对当前缓冲区生效
        silent = true,
        desc = "关闭当前缓冲区", -- 快捷键描述
      })
    end)
  end,
})

-- 6. 简化 man 手册页的关闭（使其不显示在缓冲区列表）
-- 触发条件：文件类型为 'man'
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man手册页不列出"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- 7. 为文本文档自动开启换行和拼写检查
-- 触发条件：文件类型为文本、Markdown等
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("文本文件自动换行与拼写检查"),
  pattern = { "text", "plaintex", "typst", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true -- 开启自动换行
    vim.opt_local.spell = true -- 开启拼写检查
  end,
})

-- 7.1 Markdown 默认只开启换行（不自动启用 spell，避免“满屏红线”）
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("Markdown默认不启用拼写检查"),
  pattern = { "markdown", "markdown.mdx" },
  callback = function(event)
    vim.opt_local.wrap = true
    vim.opt_local.spell = false

    -- 关闭 Markdown 的所有诊断提示（包含 LSP / linter 产生的 diagnostics）
    vim.diagnostic.enable(false, { bufnr = event.buf })
    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
    end
  end,
})

-- 8. 修复 JSON 文件中引号等字符被隐藏的问题
-- 触发条件：文件类型为 json, jsonc, 或 json5
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("修复JSON隐藏字符"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    -- conceallevel=0 表示不隐藏任何字符
    vim.opt_local.conceallevel = 0
  end,
})

-- 9. 保存文件时，如果目录不存在，则自动创建
-- 触发条件：写入缓冲区之前
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("保存时自动创建目录"),
  callback = function(event)
    -- 忽略网络路径 (如 scp://...)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    -- 获取文件的绝对路径
    local file = vim.uv.fs_realpath(event.match) or event.match
    -- 创建文件所在的目录，'-p' 参数可以递归创建多层目录
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- 10. 顶部栏透明化（Tabline/Winbar/Bufferline）
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = augroup("顶部栏透明"),
  callback = function()
    local groups = {
      "TabLine",
      "TabLineFill",
      "TabLineSel",
      "WinBar",
      "WinBarNC",
      "BufferLineFill",
      "BufferLineBackground",
      "BufferLineBufferVisible",
      "BufferLineBufferSelected",
      "BufferLineTab",
      "BufferLineTabSelected",
      "BufferLineTabClose",
      "BufferLineCloseButton",
      "BufferLineCloseButtonVisible",
      "BufferLineCloseButtonSelected",
      "BufferLineSeparator",
      "BufferLineSeparatorVisible",
      "BufferLineSeparatorSelected",
      "BufferLineDuplicate",
      "BufferLineDuplicateVisible",
      "BufferLineDuplicateSelected",
      "BufferLineModified",
      "BufferLineModifiedVisible",
      "BufferLineModifiedSelected",
      "BufferLineIndicator",
      "BufferLineIndicatorSelected",
      "BufferLineIndicatorVisible",
      "BufferLinePick",
      "BufferLinePickVisible",
      "BufferLinePickSelected",
      "BufferLineOffset",
      "BufferLineOffsetSeparator",
      "SnacksExplorerNormal",
      "SnacksExplorerNormalNC",
      "SnacksExplorerTitle",
      "SnacksExplorerBorder",
      "SnacksExplorerWinSeparator",
      "Normal",
      "NormalNC",
      "SignColumn",
      "EndOfBuffer",
    }
    for _, group in ipairs(groups) do
      vim.cmd(("highlight %s guibg=NONE ctermbg=NONE"):format(group))
    end

    -- 给分割线一点颜色，同时保持透明背景
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#d79921", bg = "NONE" })
    vim.api.nvim_set_hl(0, "VertSplit", { fg = "#d79921", bg = "NONE" })
  end,
})
