local status, saga = pcall(require, 'lspsaga')
if (not status) then return end

saga.setup({
  ui = {
    winblend = 10,
    border = 'rounded',
    colors = {
      normal_bg = '#002b36'
    }
  }
})

local map = vim.api.nvim_set_keymap
local silent = { silent = true, noremap = true }

map('n', '<c-j>', '<cmd>Lspsaga diagnostic_jump_next<cr>', silent)
map('n', 'gl', '<cmd>Lspsaga show_diagnostic<cr>', silent)
map('n', 'K', '<cmd>Lspsaga hover_doc<cr>', silent)
map('n', 'gd', '<cmd>Lspsaga lsp_finder<cr>', silent)
map('i', '<c-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', silent)
map('n', 'gp', '<cmd>Lspsaga peek_definition<cr>', silent)
map('n', 'gr', '<cmd>Lspsaga rename<cr>', silent)
