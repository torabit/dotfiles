require("mini.ai").setup({})
require("ts_context_commentstring").setup({
	enable_autocmd = false,
})
require("mini.comment").setup({
	options = {
		custom_commentstring = function()
			return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
		end,
	},
})
require("mini.move").setup({})
require("mini.cursorword").setup({})
require("mini.bracketed").setup({
	hunk = { suffix = "" }, -- disabled, using gitsigns [h ]h
})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})
MiniIcons.mock_nvim_web_devicons()

require("mini.clue").setup({
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },
		{ mode = "n", keys = "]" },
		{ mode = "n", keys = "[" },
	},
	clues = {
		require("mini.clue").gen_clues.builtin_completion(),
		require("mini.clue").gen_clues.g(),
		require("mini.clue").gen_clues.marks(),
		require("mini.clue").gen_clues.registers(),
		require("mini.clue").gen_clues.windows(),
		require("mini.clue").gen_clues.z(),
		{ mode = "n", keys = "<Leader>f", desc = "+search" },
		{ mode = "n", keys = "<Leader>g", desc = "+goto" },
		{ mode = "n", keys = "<Leader>h", desc = "+git hunk" },
		{ mode = "n", keys = "<Leader>b", desc = "+buffer" },
		{ mode = "n", keys = "<Leader>s", desc = "+split" },
		{ mode = "n", keys = "<Leader>c", desc = "+clear" },
		{ mode = "n", keys = "<Leader>r", desc = "+refactor" },
		{ mode = "n", keys = "<Leader>d", desc = "+diagnostic" },
		{ mode = "n", keys = "<Leader>p", desc = "+path/paste" },
		{ mode = "n", keys = "<Leader>o", desc = "+organize" },
		{ mode = "n", keys = "<Leader>w", desc = "+write" },
	},
	window = {
		delay = 300,
		config = { width = "auto" },
	},
})
