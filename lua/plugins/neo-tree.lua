return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      async_directory_scan = "always",
      find_by_full_path_words = true,
      window = {
        mappings = {
          ["/"] = "fuzzy_finder",
          ["#"] = "fuzzy_sorter",
          ["F"] = function()
            require("fzf-lua").files()
          end,
          ["D"] = function()
            require("fzf-lua").fzf_exec("fd --type d --hidden --exclude .git --max-depth 5", {
              prompt = "Switch Dir> ",
              cwd = vim.env.HOME,
              actions = {
                ["default"] = function(selected)
                  if not selected or #selected == 0 then return end
                  local dir = vim.env.HOME .. "/" .. selected[1]
                  vim.cmd.cd(dir)
                  require("neo-tree.command").execute({ action = "focus", dir = dir })
                end,
              },
            })
          end,
        },
      },
    },
  },
}
