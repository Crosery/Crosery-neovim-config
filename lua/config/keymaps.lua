local map = LazyVim.safe_keymap_set
local os_util = require("util.os")
local preview = require("util.preview")

map("n", "<leader>pv", preview.toggle, { desc = "Toggle preview mode" })

-- 防止空格键超时显示 <20>
map("n", "<Space>", "<Nop>", { silent = true })

local function parse_checkbox(line)
  local prefix, status, suffix = line:match("^(%s*[%-%*%+]%s*)%[([ xX])%](.*)$")
  if prefix then
    return prefix, status, suffix
  end

  return line:match("^(%s*%d+[%.%)]%s*)%[([ xX])%](.*)$")
end

local function parse_list_item(line)
  local prefix, text = line:match("^(%s*[%-%*%+]%s+)(.+)$")
  if prefix then
    return prefix, text
  end

  return line:match("^(%s*%d+[%.%)]%s+)(.+)$")
end

local function toggle_checkbox_line(line)
  local prefix, status, suffix = parse_checkbox(line)
  if prefix then
    local next_status = status == " " and "x" or " "
    return string.format("%s[%s]%s", prefix, next_status, suffix)
  end

  prefix, suffix = parse_list_item(line)
  if prefix then
    return string.format("%s[ ] %s", prefix, suffix)
  end

  local indent, text = line:match("^(%s*)(.*)$")
  if text == "" then
    return indent .. "- [ ] "
  end

  return string.format("%s- [ ] %s", indent, text)
end

local function toggle_checkbox_range(line1, line2)
  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
  for i, line in ipairs(lines) do
    lines[i] = toggle_checkbox_line(line)
  end
  vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
end

-- 全选 (空格 + v + a)
map("n", "<leader>va", "ggVG", { desc = "全选 (Visual All)" })
-- 选中当前行 (空格 + v + l)
map("n", "<leader>vl", "V", { desc = "选中行 (Line)" })

-- 全部退出 (Ctrl + q)
--    先禁用 autosave 避免 E788，再退出
map({ "n", "i", "v" }, "<C-q>", function()
  vim.g.auto_save = 0
  vim.cmd("confirm qa")
end, { desc = "全部退出 (Quit All)" })

-- 保存并退出 (空格 + w + q)
--    这是对标准 :wq 命令的快捷方式，更安全直观
map("n", "<leader>wq", "<cmd>wq<cr>", { desc = "保存并退出" })

-- 禁掉 LazyVim 的 <leader>ft / <leader>fT 终端 (改用 toggleterm)
vim.keymap.set("n", "<leader>ft", "<Nop>", { desc = "disabled" })
vim.keymap.set("n", "<leader>fT", "<Nop>", { desc = "disabled" })
-- 终端 <A-Esc> 退出到 normal mode（为复制等场景）。
-- esc 不再截获 → 透传给底层程序（claude code 取消、lazygit 等正常工作），副作用是 lazygit 那条特例不再需要
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(args)
    vim.keymap.set("t", "<A-Esc>", "<C-\\><C-n>", { buffer = args.buf, desc = "退出终端模式（去复制）" })
  end,
})

-- LSP
-- LSP重启
map("n", "<C-l>r", "<cmd>LspRestart<cr>", { desc = "重启LSP (LSP Restart)" })
-- LSP更新
map("n", "<C-l>u", "<cmd>LspUpdate<cr>", { desc = "更新LSP (LSP Update)" })

-- insert mode下移动光标
map("i", "<C-h>", "<Left>", { desc = "向左移动" })
map("i", "<C-l>", "<Right>", { desc = "向右移动" })
map("i", "<C-k>", "<Up>", { desc = "向上移动" })
map("i", "<C-j>", "<Down>", { desc = "向下移动" })

-- gx: 特定文件类型用外部程序打开，否则打开光标下的URL并聚焦浏览器窗口
map("n", "gx", function()
  -- 特定文件类型用外部程序打开
  local ext = vim.fn.expand("%:e"):lower()
  local external_types = {
    -- 表格/文档/演示
    csv = true, xlsx = true, xls = true,
    docx = true, doc = true, pptx = true, ppt = true,
    pdf = true,
    -- 图片
    png = true, jpg = true, jpeg = true, gif = true, webp = true, svg = true, bmp = true,
    -- 视频/音频
    mp4 = true, mkv = true, avi = true, mov = true, webm = true,
    mp3 = true, flac = true, wav = true, ogg = true,
  }
  if external_types[ext] then
    os_util.open(vim.fn.expand("%:p"))
    vim.notify("外部打开: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
    return
  end

  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 转为 1-based

  local url = nil

  -- 策略1: Markdown 链接 [text](url)
  for s, link_url, e in line:gmatch("()%[.-%]%((.-)%)()") do
    if col >= s and col < e then
      url = link_url
      break
    end
  end

  -- 策略2: 尖括号链接 <url>
  if not url then
    for s, inner, e in line:gmatch("()<(.-)>()") do
      if col >= s and col < e and inner:match("^https?://") then
        url = inner
        break
      end
    end
  end

  -- 策略3: 裸 URL
  if not url then
    for s, match, e in line:gmatch("()(https?://[%w%.%-%_~:/%?#%[%]@!%$&'%(%)%*%+,;=]+)()") do
      if col >= s and col < e then
        url = match
        break
      end
    end
  end

  -- 策略4: 当前行任意位置的 URL（光标不在链接上时，取行内第一个）
  if not url then
    url = line:match("https?://[%w%.%-%_~:/%?#%[%]@!%$&'%(%)%*%+,;=]+")
  end

  -- 策略5: treesitter / extmark
  if not url then
    local ok, urls = pcall(function() return require("vim.ui")._get_urls() end)
    if ok and urls and #urls > 0 then url = urls[1] end
  end

  -- 策略6: fallback <cfile>
  if not url then
    url = vim.fn.expand("<cfile>")
  end

  if not url or url == "" then
    vim.notify("光标下未找到链接", vim.log.levels.WARN)
    return
  end

  os_util.open(url)
  vim.notify("打开: " .. url, vim.log.levels.INFO)
end, { desc = "打开链接并跳转浏览器 (Open URL)" })


vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx", "quarto", "rmd" },
  callback = function(args)
    vim.keymap.set("n", "<leader>tt", function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      toggle_checkbox_range(row, row)
    end, { buffer = args.buf, desc = "切换 Markdown 复选框" })

    vim.keymap.set("x", "<leader>tt", function()
      local start_row = vim.fn.line("'<")
      local end_row = vim.fn.line("'>")
      if start_row > end_row then
        start_row, end_row = end_row, start_row
      end
      toggle_checkbox_range(start_row, end_row)
    end, { buffer = args.buf, desc = "切换 Markdown 复选框" })
  end,
})
