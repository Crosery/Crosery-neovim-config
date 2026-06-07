-- 切换主题: "gruvbox" | "dankcolors"
local theme = "gruvbox"

local function apply_dankcolors()
  require("base16-colorscheme").setup({
    base00 = "#19120c",
    base01 = "#19120c",
    base02 = "#a59e98",
    base03 = "#a59e98",
    base04 = "#fff6ef",
    base05 = "#fffbf8",
    base06 = "#fffbf8",
    base07 = "#fffbf8",
    base08 = "#ffa29c",
    base09 = "#ffa29c",
    base0A = "#ffc18f",
    base0B = "#b3ffa3",
    base0C = "#ffdec4",
    base0D = "#ffc18f",
    base0E = "#ffcca3",
    base0F = "#ffcca3",
  })

  vim.api.nvim_set_hl(0, "Visual", { bg = "#a59e98", fg = "#fffbf8", bold = true })
  vim.api.nvim_set_hl(0, "Statusline", { bg = "#ffc18f", fg = "#19120c" })
  vim.api.nvim_set_hl(0, "LineNr", { fg = "#a59e98" })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffdec4", bold = true })
  vim.api.nvim_set_hl(0, "Statement", { fg = "#ffcca3", bold = true })
  vim.api.nvim_set_hl(0, "Keyword", { link = "Statement" })
  vim.api.nvim_set_hl(0, "Repeat", { link = "Statement" })
  vim.api.nvim_set_hl(0, "Conditional", { link = "Statement" })
  vim.api.nvim_set_hl(0, "Function", { fg = "#ffc18f", bold = true })
  vim.api.nvim_set_hl(0, "Macro", { fg = "#ffc18f", italic = true })
  vim.api.nvim_set_hl(0, "@function.macro", { link = "Macro" })
  vim.api.nvim_set_hl(0, "Type", { fg = "#ffdec4", bold = true, italic = true })
  vim.api.nvim_set_hl(0, "Structure", { link = "Type" })
  vim.api.nvim_set_hl(0, "String", { fg = "#b3ffa3", italic = true })
  vim.api.nvim_set_hl(0, "Operator", { fg = "#fff6ef" })
  vim.api.nvim_set_hl(0, "Delimiter", { fg = "#fff6ef" })
  vim.api.nvim_set_hl(0, "@punctuation.bracket", { link = "Delimiter" })
  vim.api.nvim_set_hl(0, "@punctuation.delimiter", { link = "Delimiter" })
  vim.api.nvim_set_hl(0, "Comment", { fg = "#a59e98", italic = true })
end

return {
  { "ellisonleao/gruvbox.nvim", enabled = theme == "gruvbox" },

  {
    "RRethy/base16-nvim",
    enabled = theme == "dankcolors",
    lazy = false,
    priority = 1000,
    config = function()
      apply_dankcolors()

      if not _G._dankcolors_watcher then
        local uv = vim.uv or vim.loop
        local path = vim.fn.stdpath("config") .. "/lua/plugins/colorscheme.lua"
        _G._dankcolors_watcher = uv.new_fs_event()
        _G._dankcolors_watcher:start(path, {}, vim.schedule_wrap(function()
          local ok, specs = pcall(dofile, path)
          if ok and type(specs) == "table" then
            for _, s in ipairs(specs) do
              if type(s) == "table" and s[1] == "RRethy/base16-nvim" and s.config then
                s.config()
                print("Theme reload")
                break
              end
            end
          end
        end))
      end
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = theme == "gruvbox" and "gruvbox" or function() end,
    },
  },

  {
    "xiyaowong/transparent.nvim",
    enabled = not vim.g.neovide,
    lazy = false,
    config = function()
      require("transparent").setup({
        extra_groups = { "NormalFloat", "NvimTreeNormal" },
        exclude_groups = {},
      })
      vim.cmd("TransparentEnable")
    end,
  },
}
