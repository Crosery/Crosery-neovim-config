return {
  {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    opts = {
      view = {
        display_mode = "border",
      },
    },
    config = function(_, opts)
      require("csvview").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "csv", "tsv" },
        callback = function() vim.defer_fn(function() require("csvview").enable() end, 50) end,
      })
    end,
  },
}
