vim.g.mapleader = " " -- space for leader
vim.g.maplocalleader = " " -- space for localleader

vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", function()
	require("mini.bufremove").delete(0)
end, { desc = "Delete buffer" })

vim.keymap.set("n", "<A-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Move to left window" })
vim.keymap.set("n", "<A-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Move to bottom window" })
vim.keymap.set("n", "<A-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Move to top window" })
vim.keymap.set("n", "<A-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Move to right window" })

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })


vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

vim.keymap.set("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p"):gsub("^%w+://", "")
	path = vim.fn.fnamemodify(path, ":.")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy relative file path" })

vim.keymap.set("n", "<leader>wn", "<cmd>noautocmd w<CR>", { desc = "Save without formatting" })

vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Toggle undotree" })

vim.keymap.set("n", "<leader>pv", function()
	local file = vim.fn.expand("%:p")
	if file:match("%.svg$") or file:match("%.png$") or file:match("%.jpg$") or file:match("%.jpeg$") or file:match("%.gif$") or file:match("%.webp$") then
		vim.fn.system({ "open", file })
	else
		vim.notify("Not an image file", vim.log.levels.WARN)
	end
end, { desc = "Preview image in macOS" })
