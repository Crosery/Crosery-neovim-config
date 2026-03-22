-- 确保 Neovim 有 listen socket，并导出环境变量给子终端
-- 这样从 toggleterm 启动的 Claude Code 能通过 NVIM_LISTEN_ADDRESS 连回来
local function setup_nvim_instance()
  if vim.g.vscode then return end

  local server = vim.v.servername
  if not server or server == "" then
    local sock_dir = (vim.fn.stdpath("run") or "/tmp") .. "/nvim-agent"
    vim.fn.mkdir(sock_dir, "p")
    local sock = string.format("%s/nvim-%d.sock", sock_dir, vim.fn.getpid())
    local ok, addr = pcall(vim.fn.serverstart, sock)
    if ok and addr and addr ~= "" then
      server = addr
    else
      local ok2, addr2 = pcall(vim.fn.serverstart)
      server = (ok2 and addr2 ~= "" and addr2) or ""
    end
  end

  vim.env.NVIM_LISTEN_ADDRESS = server
  vim.env.NVIM_INSTANCE_ID = tostring(vim.fn.getpid())
  vim.env.NVIM_AGENT = "1"
end

setup_nvim_instance()

return {
  {
    dir = vim.fn.stdpath("config") .. "/lua/acp",
    name = "acp",
    event = "VeryLazy",
    config = function()
      require("acp").setup()
    end,
    keys = {
      { "<A-u>", "<cmd>Acp<CR>", desc = "ACP Toggle", mode = { "n", "i", "v", "t" } },
      { "<A-i>", "<cmd>Acp list<CR>", desc = "ACP List", mode = { "n", "i", "v", "t" } },
    },
  },
}
