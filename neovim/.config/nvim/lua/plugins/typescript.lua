require("nvim-ts-autotag").setup({})

require("template-string").setup({})

require("typescript-tools").setup({
	settings = {
		tsserver_plugins = {
			"@styled/typescript-styled-plugin",
		},
		tsserver_file_preferences = {
			includeInlayParameterNameHints = "all",
			includeCompletionsForModuleExports = true,
		},
	},
})
