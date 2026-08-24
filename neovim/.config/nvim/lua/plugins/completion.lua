require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "select_and_accept", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<Tab>"] = {
			function(cmp)
				if require("copilot.suggestion").is_visible() then
					require("copilot.suggestion").accept()
					return true
				end
				return cmp.snippet_forward()
			end,
			"fallback",
		},
		["<S-Tab>"] = { "snippet_backward", "fallback" },
		["<C-d>"] = { "show_documentation", "hide_documentation", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = {
		menu = { auto_show = true },
		documentation = { auto_show = false },
	},
	sources = { default = { "lsp", "path", "buffer", "snippets" } },
	cmdline = {
		keymap = {
			preset = "inherit",
			["<CR>"] = { "fallback" },
			["<Tab>"] = { "accept", "fallback" },
		},
		completion = { menu = { auto_show = true } },
	},
	snippets = {
		expand = function(snippet)
			require("luasnip").lsp_expand(snippet)
		end,
	},
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
})

vim.lsp.config["*"] = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}
