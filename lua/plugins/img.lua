return {
  "3rd/image.nvim",
  dependencies = {
    {
      "leafo/magick",
      lazy = true,
      build = "luarocks install --server=https://luarocks.org/dev magick",
    },
  },
  opts = {
    backend = "kitty",
    processor = "magick_rock",
    integrations = {
      -- 必须改成表结构
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "markdown", "vimwiki" }, -- 可以在这里指定关联的文件类型
      },
      neorg = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "norg" },
      },
      html = {
        enabled = true,
      },
      css = {
        enabled = true,
      },
    },
    max_width = 100,
    max_height = 12,
    max_width_window_percentage = math.huge,
    max_height_window_percentage = math.huge,
    window_overlap_clear_enabled = true,
    editor_only_render_when_focused = false,
    tmux_show_only_in_active_window = true,
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
  },
}
