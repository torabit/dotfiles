require("copilot").setup({
	copilot_node_command = { "mise", "x", "node@lts", "--", "node" },
	suggestion = {
		enabled = true,
		auto_trigger = true,
		keymap = {
			accept = "<Tab>",
			accept_word = "<C-Right>",
			accept_line = "<C-End>",
			next = "<M-]>",
			prev = "<M-[>",
			dismiss = "<C-]>",
		},
	},
	panel = { enabled = false },
	filetypes = {
		markdown = true,
		yaml = true,
	},
})
