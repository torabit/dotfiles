require("diffview").setup({})

vim.keymap.set("n", "<leader>gdo", "<cmd>DiffviewOpen<cr>", { desc = "Diffview open" })
vim.keymap.set("n", "<leader>gdc", "<cmd>DiffviewClose<cr>", { desc = "Diffview close" })
vim.keymap.set("n", "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history (current)" })
vim.keymap.set("n", "<leader>gdH", "<cmd>DiffviewFileHistory<cr>", { desc = "File history (all)" })
