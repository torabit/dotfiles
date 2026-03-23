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
	-- Undo
	"https://github.com/mbbill/undotree",
	-- Tabline
	"https://github.com/nanozuki/tabby.nvim",
	-- Navigation
	"https://github.com/ThePrimeagen/harpoon",
	-- Markdown
	"https://github.com/OXY2DEV/markview.nvim",
	-- Notification
	"https://github.com/j-hui/fidget.nvim",
	-- UI
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/folke/trouble.nvim",
	"https://github.com/folke/flash.nvim",
	"https://github.com/kylechui/nvim-surround",
	-- Marks
	"https://github.com/chentoast/marks.nvim",
	-- Tmux
	"https://github.com/christoomey/vim-tmux-navigator",
	-- Copilot
	"https://github.com/zbirenbaum/copilot.lua",
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
packadd("undotree")
packadd("tabby.nvim")
packadd("harpoon")
packadd("markview.nvim")
packadd("todo-comments.nvim")
packadd("trouble.nvim")
packadd("flash.nvim")
packadd("nvim-surround")
packadd("marks.nvim")
packadd("fidget.nvim")
packadd("vim-tmux-navigator")
packadd("copilot.lua")

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
require("plugins.tabline")
require("plugins.harpoon")
require("markview").setup({})
require("todo-comments").setup({
	search = {
		args = {
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--glob=!node_modules/",
			"--glob=!dist/",
			"--glob=!build/",
			"--glob=!*.min.*",
			"--glob=!*.lock",
			"--glob=!*-lock.*",
			"--glob=!schema.json",
			"--glob=!__generated__/",
		},
	},
})
require("plugins.trouble")
require("plugins.flash")
require("marks").setup({})
require("fidget").setup({})
require("nvim-surround").setup({})
require("plugins.copilot")
