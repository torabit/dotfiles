vim.pack.add({
	"https://github.com/NLKNguyen/papercolor-theme",
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://www.github.com/echasnovski/mini.nvim",
	"https://www.github.com/ibhagwan/fzf-lua",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	-- Language Server Protocols
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/L3MON4D3/LuaSnip",
	-- TSX/React
	"https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
	"https://github.com/windwp/nvim-ts-autotag",
	"https://github.com/axelvc/template-string.nvim",
	"https://github.com/pmizio/typescript-tools.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	-- Explorer
	"https://github.com/stevearc/oil.nvim",
	-- Git
	"https://github.com/sindrets/diffview.nvim",
	-- UI
	"https://github.com/folke/trouble.nvim",
	"https://github.com/folke/flash.nvim",
	"https://github.com/kylechui/nvim-surround",
	-- Tmux
	"https://github.com/christoomey/vim-tmux-navigator",
})

local function packadd(name)
	vim.cmd("packadd " .. name)
end

packadd("papercolor-theme")
packadd("nvim-treesitter")
packadd("gitsigns.nvim")
packadd("mini.nvim")
packadd("fzf-lua")
packadd("nvim-lspconfig")
packadd("mason.nvim")
packadd("conform.nvim")
packadd("nvim-lint")
packadd("blink.cmp")
packadd("LuaSnip")
packadd("plenary.nvim")
packadd("nvim-ts-context-commentstring")
packadd("nvim-ts-autotag")
packadd("template-string.nvim")
packadd("typescript-tools.nvim")
packadd("oil.nvim")
packadd("diffview.nvim")
packadd("trouble.nvim")
packadd("flash.nvim")
packadd("nvim-surround")
packadd("vim-tmux-navigator")

require("plugins.colorscheme")
require("plugins.treesitter")
require("plugins.mini")
require("plugins.explorer")
require("plugins.fzf")
require("plugins.typescript")
require("plugins.gitsigns")
require("plugins.lsp")
require("plugins.completion")
require("plugins.conform")
require("plugins.lint")
require("plugins.diffview")
require("plugins.trouble")
require("plugins.flash")
require("nvim-surround").setup({})
