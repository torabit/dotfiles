local status, packer = pcall(require, 'packer')
if (not status) then
  print("Packer is not installed")
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Commenting
  use 'numToStr/Comment.nvim'
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
  use 'hrsh7th/cmp-cmdline'

  -- Highlights
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  }

  -- Endwise
  use 'RRethy/nvim-treesitter-endwise'

  -- Autopairs
  use 'windwp/nvim-autopairs'
  use 'windwp/nvim-ts-autotag'

  -- Search
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-telescope/telescope-file-browser.nvim'
  use 'nvim-telescope/telescope-ui-select.nvim'

  -- Git
  use 'lewis6991/gitsigns.nvim'

  -- Pretty UI
  use 'rcarriga/nvim-notify'

  -- Highlight colors
  use 'norcalli/nvim-colorizer.lua'

  -- File icons
  use 'kyazdani42/nvim-web-devicons'

  -- Buffer management
  use 'akinsho/bufferline.nvim'
  use 'jose-elias-alvarez/null-ls.nvim'
  use 'b0o/incline.nvim'
end)
