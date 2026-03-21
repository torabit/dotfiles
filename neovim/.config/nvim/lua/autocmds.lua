local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- auto-reload files changed outside of nvim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	group = augroup,
	callback = function(args)
		if vim.bo[args.buf].buftype == "" then
			vim.cmd("silent! checktime " .. args.buf)
		end
	end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	group = augroup,
	callback = function()
		vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
	end,
})

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"')
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
	end,
})

return augroup
