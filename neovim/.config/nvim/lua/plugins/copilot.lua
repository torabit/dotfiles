require("copilot").setup({
	copilot_node_command = { "mise", "x", "node@lts", "--", "node" },
	suggestion = {
		enabled = true,
		auto_trigger = true,
		keymap = {
			-- <Tab> は blink.cmp 側のハンドラが accept を呼ぶ。ここで張ると
			-- copilot のバッファマップが blink のマップを上書きし、候補が無いとき
			-- 委譲先 expr の戻り値を捨てるためインデントが効かなくなる。
			accept = false,
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
