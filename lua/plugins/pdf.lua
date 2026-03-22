return {
  {
    dir = "pdf-preview",
    name = "pdf-preview",
    virtual = true,
    init = function()
      vim.api.nvim_create_autocmd("BufReadCmd", {
        pattern = "*.pdf",
        callback = function(ev)
          local file = vim.fn.expand("<afile>:p")
          local buf = ev.buf

          vim.bo[buf].buftype = "nofile"
          vim.bo[buf].swapfile = false
          vim.bo[buf].modifiable = true

          local output = vim.fn.systemlist({ "pdftotext", "-layout", file, "-" })
          if vim.v.shell_error ~= 0 then
            output = { "Error: pdftotext failed. Install poppler: pacman -S poppler" }
          end

          vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
          vim.bo[buf].modifiable = false
          vim.bo[buf].filetype = "text"
        end,
      })
    end,
  },
}
