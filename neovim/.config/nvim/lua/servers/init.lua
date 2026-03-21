require("servers.lua_ls")
require("servers.pyright")
require("servers.bashls")
require("servers.gopls")
require("servers.clangd")
require("servers.tailwindcss")
require("servers.efm")

vim.lsp.enable({
	"lua_ls",
	"pyright",
	"bashls",
	"gopls",
	"clangd",
	"efm",
	"tailwindcss",
})
