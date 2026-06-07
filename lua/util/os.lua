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

return M
