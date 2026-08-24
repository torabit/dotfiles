local neotest = require("neotest")

neotest.setup({
	adapters = {
		require("neotest-rspec"),
		require("neotest-rust")({
			args = { "--no-capture" },
			dap_adapter = "codelldb",
		}),
	},
})

vim.keymap.set("n", "<leader>tn", function()
	neotest.run.run()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("%"))
end, { desc = "Run current file tests" })

vim.keymap.set("n", "<leader>ts", function()
	neotest.summary.toggle()
end, { desc = "Toggle test summary" })

vim.keymap.set("n", "<leader>to", function()
	neotest.output.open({ enter = true })
end, { desc = "Open test output" })

vim.keymap.set("n", "<leader>tp", function()
	neotest.output_panel.toggle()
end, { desc = "Toggle test output panel" })
