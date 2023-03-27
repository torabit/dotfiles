local status, packer = pcall(require, 'packer')
if (not status) then
  print("Packer is not installed")
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Wrapping/delimiters
  use 'machakann/vim-sandwich'
  use {
    'andymass/vim-matchup',
    setup = [[require('config.matchup')]],
    event = 'User ActuallyEditing'
  }

  -- Statusline
  -- use 'hoob3rt/lualine.nvim'
  -- Snippets
  use 'L3MON4D3/LuaSnip'

  -- Completion
  use 'onsails/lspkind-nvim'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/nvim-cmp'
  use 'neovim/nvim-lspconfig'

  -- Highlights
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  }
end)
