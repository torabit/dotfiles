vim.pack.add({
	"https://github.com/NLKNguyen/papercolor-theme",
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://www.github.com/echasnovski/mini.nvim",
	"https://www.github.com/ibhagwan/fzf-lua",
	"https://www.github.com/nvim-tree/nvim-tree.lua",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	-- Language Server Protocols
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/creativenull/efmls-configs-nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/L3MON4D3/LuaSnip",
	-- TSX/React
	"https://github.com/windwp/nvim-ts-autotag",
	"https://github.com/axelvc/template-string.nvim",
	"https://github.com/pmizio/typescript-tools.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
})

local function packadd(name)
	vim.cmd("packadd " .. name)
end

packadd("papercolor-theme")
packadd("nvim-treesitter")
packadd("gitsigns.nvim")
packadd("mini.nvim")
packadd("fzf-lua")
packadd("nvim-tree.lua")
packadd("nvim-lspconfig")
packadd("mason.nvim")
packadd("efmls-configs-nvim")
packadd("blink.cmp")
packadd("LuaSnip")
packadd("plenary.nvim")
packadd("nvim-ts-autotag")
packadd("template-string.nvim")
packadd("typescript-tools.nvim")

require("plugins.colorscheme")
require("plugins.treesitter")
require("plugins.nvim-tree")
require("plugins.fzf")
require("plugins.mini")
require("plugins.typescript")
require("plugins.gitsigns")
require("plugins.lsp")
require("plugins.completion")
