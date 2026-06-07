return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    local icons = LazyVim.config.icons
    vim.o.laststatus = vim.g.lualine_laststatus

    -- Gruvbox 配色 + 全透明背景
    local colors = {
      fg = "#ebdbb2",
      yellow = "#d79921",
      green = "#98971a",
      orange = "#d65d0e",
      purple = "#b16286",
      blue = "#458588",
      red = "#cc241d",
      gray = "#a89984",
    }

    -- 全透明主题
    local transparent_theme = {
      normal = {
        a = { fg = colors.blue, bg = "NONE", gui = "bold" },
        b = { fg = colors.fg, bg = "NONE" },
        c = { fg = colors.gray, bg = "NONE" },
      },
      insert = {
        a = { fg = colors.green, bg = "NONE", gui = "bold" },
        b = { fg = colors.fg, bg = "NONE" },
        c = { fg = colors.gray, bg = "NONE" },
      },
      visual = {
        a = { fg = colors.purple, bg = "NONE", gui = "bold" },
        b = { fg = colors.fg, bg = "NONE" },
        c = { fg = colors.gray, bg = "NONE" },
      },
      replace = {
        a = { fg = colors.red, bg = "NONE", gui = "bold" },
        b = { fg = colors.fg, bg = "NONE" },
        c = { fg = colors.gray, bg = "NONE" },
      },
      command = {
        a = { fg = colors.orange, bg = "NONE", gui = "bold" },
        b = { fg = colors.fg, bg = "NONE" },
        c = { fg = colors.gray, bg = "NONE" },
      },
      inactive = {
        a = { fg = colors.gray, bg = "NONE" },
        b = { fg = colors.gray, bg = "NONE" },
        c = { fg = colors.gray, bg = "NONE" },
      },
    }

    local opts = {
      options = {
        theme = transparent_theme,
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          {
            -- 当前工作目录（home 替换为 ~）
            function()
              return " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
            end,
            color = { fg = colors.yellow, gui = "bold" },
          },
          {
            "branch",
            icon = "",
            color = { fg = colors.green, gui = "bold" },
          },
        },

        lualine_c = {
          LazyVim.lualine.root_dir(),
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { LazyVim.lualine.pretty_path() },
        },
        lualine_x = {
          Snacks.profiler.status(),
          -- stylua: ignore
          {
            function() return require("noice").api.status.command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
            color = function() return { fg = Snacks.util.color("Statement") } end,
          },
          -- stylua: ignore
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
            color = function() return { fg = Snacks.util.color("Constant") } end,
          },
          -- stylua: ignore
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = function() return { fg = Snacks.util.color("Debug") } end,
          },
          -- stylua: ignore
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function() return { fg = Snacks.util.color("Special") } end,
          },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_y = {
          -- LSP 服务器
          {
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then return "" end
              local names = {}
              for _, client in ipairs(clients) do
                table.insert(names, client.name)
              end
              return " " .. table.concat(names, ", ")
            end,
            cond = function() return #vim.lsp.get_clients({ bufnr = 0 }) > 0 end,
          },
          { "encoding" },
          { "fileformat" },
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          function()
            return " " .. os.date("%R")
          end,
        },
      },
      extensions = { "neo-tree", "lazy", "fzf" },
    }

    -- Trouble symbols
    if vim.g.trouble_lualine and LazyVim.has("trouble.nvim") then
      local trouble = require("trouble")
      local symbols = trouble.statusline({
        mode = "symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        hl_group = "lualine_c_normal",
      })
      table.insert(opts.sections.lualine_c, {
        symbols and symbols.get,
        cond = function()
          return vim.b.trouble_lualine ~= false and symbols.has()
        end,
      })
    end

    return opts
  end,
}
