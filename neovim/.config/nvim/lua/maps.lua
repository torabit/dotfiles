local g = vim.g

-- Leader/local leader
g.mapleader = [[ ]]
g.maplocalleader = [[,]]

-- Keybindings
local silent = { silent = true, noremap = true }

-- Quit, close buffers, etc.
local map = vim.api.nvim_set_keymap
map('n', '<leader>q', '<cmd>qa<cr>', silent)
map('n', '<leader>x', '<cmd>x!<cr>', silent)
map('n', '<leader>d', '<cmd>Sayonara<cr>', { silent = true, nowait = true, noremap = true })

-- Save buffer
map('i', '<c-s>', '<esc><cmd>w<cr>a', silent)
map('n', '<leader>w', '<cmd>w<cr>', silent)

-- Esc in the terminal
map('i', 'jj', '<esc>', silent)

-- New tab
map('n', 'te', ':tabedit<Return>', silent)

-- Split window
map('n', 'ss', ':split<Return><C-w>w', silent)
map('n', 'sv', ':vsplit<Return><C-w>w', silent)

-- Window movement
map('n', '<c-h>', '<c-w>h', silent)
map('n', '<c-j>', '<c-w>j', silent)
map('n', '<c-k>', '<c-w>k', silent)
map('n', '<c-l>', '<c-w>l', silent)

-- Tab movement
map('n', '<c-Left>', '<cmd>tabpre<cr>', silent)
map('n', '<c-Right>', '<cmd>tabnext<cr>', silent)

