-- rustaceanvim configuration
-- NOTE: rustaceanvim manages rust-analyzer LSP internally.
-- Do NOT add rust_analyzer to lua/servers/ or vim.lsp.enable().
vim.g.rustaceanvim = {
	server = {
		default_settings = {
			["rust-analyzer"] = {
				checkOnSave = {
					command = "clippy",
					extraArgs = { "--all-targets" },
				},
				cargo = {
					allFeatures = true,
					buildScripts = { enable = true },
				},
				procMacro = {
					enable = true,
					attributes = { enable = true },
				},
				diagnostics = {
					enable = true,
					experimental = { enable = true },
				},
				inlayHints = {
					bindingModeHints = { enable = true },
					chainingHints = { enable = true },
					closingBraceHints = { enable = true },
					closureReturnTypeHints = { enable = true },
					lifetimeElisionHints = { enable = true },
					parameterHints = { enable = true },
					typeHints = { enable = true },
				},
			},
		},
	},
}

-- crates.nvim
require("crates").setup({
	lsp = {
		enabled = true,
		actions = true,
		completion = true,
		hover = true,
	},
})
