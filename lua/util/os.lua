local M = {}

local uname = vim.uv.os_uname().sysname

M.is_mac = uname == "Darwin"
M.is_linux = uname == "Linux"
M.is_windows = uname:match("Windows") ~= nil

function M.opener()
  if M.is_mac then return "open" end
  if M.is_windows then return "start" end
  return "xdg-open"
end

function M.open(target)
  vim.fn.jobstart({ M.opener(), target }, { detach = true })
end

-- 在系统文件管理器中定位 target 所在目录并选中 target。
-- macOS: open -R / Windows: explorer /select, / Linux: 退化为打开父目录（xdg-open 无统一 select 语义）
function M.reveal(target)
  if M.is_mac then
    vim.fn.jobstart({ "open", "-R", target }, { detach = true })
  elseif M.is_windows then
    vim.fn.jobstart({ "explorer", "/select,", target }, { detach = true })
  else
    vim.fn.jobstart({ "xdg-open", vim.fn.fnamemodify(target, ":h") }, { detach = true })
  end
end

return M
