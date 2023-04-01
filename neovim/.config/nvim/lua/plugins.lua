local status, packer = pcall(require, 'packer')
if (not status) then
  print("Packer is not installed")
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Color scheme
  use 'yorik1984/newpaper.nvim'

  -- Movement
  use 'chaoren/vim-wordmotion'
  use 'ggandor/leap.nvim'
  use 'tpope/vim-repeat'
  use 'ggandor/flit.nvim'

  -- Indentation tracking
  use 'lukas-reineke/indent-blankline.nvim'

  -- Commenting
  use 'numToStr/Comment.nvim'

  -- Wrapping/delimiters
  use 'machakann/vim-sandwich'
  use 'andymass/vim-matchup'

  -- Statusline
  use 'hoob3rt/lualine.nvim'

  -- Snippets
  use 'L3MON4D3/LuaSnip'
  use 'rafamadriz/friendly-snippets'

  -- Quick fix
  use { 'Olical/vim-enmasse', cmd = 'EnMasse' }
  use { 'kevinhwang91/nvim-bqf', ft = 'qf' }
  use 'https://gitlab.com/yorickpeterse/nvim-pqf'

  -- Completion
  use 'onsails/lspkind-nvim'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/nvim-cmp'
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/cmp-cmdline'
  use 'folke/trouble.nvim'
  use 'ray-x/lsp_signature.nvim'

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

  -- Text objects
  use 'wellle/targets.vim'

  -- Search
  use 'romainl/vim-cool'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-telescope/telescope-file-browser.nvim'
  use 'nvim-telescope/telescope-ui-select.nvim'

  -- Git
  use 'lewis6991/gitsigns.nvim'

  -- Pretty UI
  use 'stevearc/dressing.nvim'
  use 'vigoux/notifier.nvim'
  use 'folke/todo-comments.nvim'
  use 'j-hui/fidget.nvim'

  -- Highlight colors
  use 'norcalli/nvim-colorizer.lua'

  -- File icons
  use 'kyazdani42/nvim-web-devicons'

  -- Buffer management
  use 'akinsho/bufferline.nvim'
  use 'jose-elias-alvarez/null-ls.nvim'
  use 'b0o/incline.nvim'
  use 'filipdutescu/renamer.nvim'
end)
