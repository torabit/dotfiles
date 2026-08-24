require("oil").setup({
	default_file_explorer = true,
	view_options = {
		show_hidden = true,
	},
	keymaps = {
		["g?"] = "actions.show_help",
		["<CR>"] = "actions.select",
		["-"] = "actions.parent",
		["_"] = "actions.open_cwd",
		["`"] = "actions.cd",
		["~"] = "actions.tcd",
		["gs"] = "actions.change_sort",
		["gx"] = "actions.open_external",
		["g."] = "actions.toggle_hidden",
		["q"] = "actions.close",
	},
	use_default_keymaps = false,
})

vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer" })
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
