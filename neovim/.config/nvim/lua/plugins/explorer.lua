vim.g.molder_show_hidden = 1

vim.keymap.set("n", "<leader>e", function()
	local buf_name = vim.api.nvim_buf_get_name(0)
	local dir = vim.fn.filereadable(buf_name) == 1 and vim.fn.fnamemodify(buf_name, ":h") or vim.fn.getcwd()
	vim.cmd("edit " .. vim.fn.fnameescape(dir))
end, { desc = "File explorer" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "molder",
	callback = function()
		local opts = { buffer = true }

		-- % : new file (netrw convention)
		vim.keymap.set("n", "%", function()
			local name = vim.fn.input("New file: ")
			if name == "" then
				return
			end
			local dir = vim.fn.expand("%:p")
			vim.cmd("edit " .. vim.fn.fnameescape(dir .. name))
		end, vim.tbl_extend("force", opts, { desc = "New file" }))

		-- d : new directory (netrw convention)
		vim.keymap.set("n", "d", function()
			local name = vim.fn.input("New directory: ")
			if name == "" then
				return
			end
			local dir = vim.fn.expand("%:p")
			vim.fn.mkdir(dir .. name, "p")
			vim.cmd("edit " .. vim.fn.fnameescape(dir))
		end, vim.tbl_extend("force", opts, { desc = "New directory" }))

		-- D : delete (netrw convention)
		vim.keymap.set("n", "D", function()
			local line = vim.api.nvim_get_current_line()
			local name = line:match("^%s*(.+)$")
			if not name then
				return
			end
			local dir = vim.fn.expand("%:p")
			local path = dir .. name
			if vim.fn.confirm("Delete " .. name .. "?", "&Yes\n&No", 2) ~= 1 then
				return
			end
			vim.fn.delete(path, "rf")
			vim.cmd("edit " .. vim.fn.fnameescape(dir))
		end, vim.tbl_extend("force", opts, { desc = "Delete" }))

		-- R : rename (netrw convention)
		vim.keymap.set("n", "R", function()
			local line = vim.api.nvim_get_current_line()
			local old = line:match("^%s*(.+)$")
			if not old then
				return
			end
			old = old:gsub("/$", "")
			local new = vim.fn.input("Rename to: ", old)
			if new == "" or new == old then
				return
			end
			local dir = vim.fn.expand("%:p")
			vim.fn.rename(dir .. old, dir .. new)
			vim.cmd("edit " .. vim.fn.fnameescape(dir))
		end, vim.tbl_extend("force", opts, { desc = "Rename" }))
	end,
})
