local status, leap = pcall(require, 'leap')
if (not status) then return end

local map = vim.api.nvim_set_keymap
local opts = { noremap = false }

leap.setup {}

map('n', 'z', '<Plug>(leap-forward-x)', opts)
map('n', 'Z', '<Plug>(leap-backward-x)', opts)

-- visual-mode
map('x', 'z', '<Plug>(leap-forward-x)', opts)
map('x', 'Z', '<Plug>(leap-backward-x)', opts)

-- operator-pending-mode
map('o', 'z', '<Plug>(leap-forward-x)', opts)
map('o', 'Z', '<Plug>(leap-backward-x)', opts)
