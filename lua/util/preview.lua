local M = {}

local hexyl_buf = {}

function M.toggle()
  local ft = vim.bo.filetype
  local ext = vim.fn.expand("%:e"):lower()

  if ft == "csv" or ft == "tsv" then
    vim.cmd("CsvViewToggle")
    return
  end

  if ft == "markdown" then
    vim.cmd("RenderMarkdown toggle")
    return
  end

  if vim.tbl_contains({ "png", "jpg", "jpeg", "gif", "webp", "avif", "svg" }, ext) then
    vim.notify("图片类型由 image.nvim 自动渲染，移动光标切换", vim.log.levels.INFO)
    return
  end

  if hexyl_buf[vim.api.nvim_get_current_buf()] then
    M.hexyl_restore()
    return
  end

  if M.is_binary() then
    M.hexyl_view()
    return
  end

  vim.notify("当前文件类型无预览模式: " .. ft, vim.log.levels.WARN)
end

function M.is_binary()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)
  if #lines == 0 then return false end
  return lines[1]:find("%z") ~= nil
end

function M.hexyl_view()
  local file = vim.fn.expand("%:p")
  if vim.fn.executable("hexyl") ~= 1 then
    vim.notify("hexyl 未安装: brew install hexyl 或 cargo install hexyl", vim.log.levels.ERROR)
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  hexyl_buf[bufnr] = { file = file, pos = vim.api.nvim_win_get_cursor(0) }
  local output = vim.fn.systemlist("hexyl --length 4096 " .. vim.fn.shellescape(file))
  vim.cmd("enew")
  local new_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, output)
  vim.bo[new_buf].buftype = "nofile"
  vim.bo[new_buf].modifiable = false
  vim.bo[new_buf].filetype = "hexyl"
  hexyl_buf[new_buf] = hexyl_buf[bufnr]
  hexyl_buf[bufnr] = nil
end

function M.hexyl_restore()
  local bufnr = vim.api.nvim_get_current_buf()
  local info = hexyl_buf[bufnr]
  if not info then return end
  vim.cmd("edit " .. vim.fn.fnameescape(info.file))
  pcall(vim.api.nvim_win_set_cursor, 0, info.pos)
  vim.api.nvim_buf_delete(bufnr, { force = true })
  hexyl_buf[bufnr] = nil
end

return M
