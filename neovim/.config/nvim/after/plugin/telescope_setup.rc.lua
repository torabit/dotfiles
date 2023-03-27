local status, telescope = pcall(require, "telescope")
if (not status) then return end
local map = vim.api.nvim_set_keymap

local function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

local silent = { silent = true, noremap = true }
-- Navigate buffers and repos
map('n', '<c-b>', [[<cmd>Telescope buffers show_all_buffers=true theme=get_dropdown<cr>]], silent)
map('n', '<c-p>', [[<cmd>Telescope commands theme=get_dropdown<cr>]], silent)
map('n', '<c-s>', [[<cmd>Telescope git_files theme=get_dropdown<cr>]], silent)
map('n', '<c-d>', [[<cmd>Telescope find_files theme=get_dropdown<cr>]], silent)
map('n', '<c-g>', [[<cmd>Telescope live_grep theme=get_dropdown<cr>]], silent)

vim.keymap.set('n', '<c-f>', function ()
  telescope.extensions.file_browser.file_browser({
    path = "%:p:h",
    cwd = telescope_buffer_dir(),
    respect_gitignore = false,
    hidden = true,
    grouped = true,
    previewer = false,
    initial_mode = "normal",
    layout_config = { height = 40 }
  })
end)
