return {
  "mrcjkb/rustaceanvim",
  version = "^6", -- Recommended
  lazy = false, -- This plugin is already lazy
  opts = function()
    local codelldb_path = vim.fn.expand("$HOME") .. "/.local/share/nvim/mason/packages/codelldb/extension/adapter/codelldb"
    local liblldb_path = vim.fn.expand("$HOME") .. "/.local/share/nvim/mason/packages/codelldb/extension/lldb/lib/liblldb.dylib"
    return {
      dap = {
        adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path),
      },
    }
  end,
}
