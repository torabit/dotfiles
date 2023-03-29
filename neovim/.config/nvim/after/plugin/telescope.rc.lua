local status, telescope = pcall(require, 'telescope')
if (not status) then return end

telescope.setup {
  defaults = {
    theme = require('telescope.themes').get_dropdown { layout_config = { prompt_position = 'top' } },
  },
  ['ui-select'] = {
    require('telescope.themes').get_dropdown { layout_config = { prompt_position = 'top' } },
  },
  file_browser = {
    hijack_netwrw = true,
    mappings = {},
  },
}

-- Extensions
telescope.load_extension 'ui-select'
telescope.load_extension 'file_browser'
