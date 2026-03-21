local function set_hl()
	vim.api.nvim_set_hl(0, "TabbyBuf", { fg = "#878787", bg = "#eeeeee" })
	vim.api.nvim_set_hl(0, "TabbyBufCurrent", { fg = "#444444", bg = "#eeeeee", bold = true })
	vim.api.nvim_set_hl(0, "TabbyBufModified", { fg = "#d70087", bg = "#eeeeee", bold = true })
	vim.api.nvim_set_hl(0, "TabbyFill", { bg = "#eeeeee" })
end

set_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

require("tabby").setup({
	line = function(line)
		local bufs = line.bufs().foreach(function(buf)
			local name = buf.name()
			local hl = "TabbyBuf"
			if buf.is_current() then
				hl = "TabbyBufCurrent"
			end
			if buf.is_changed() then
				hl = "TabbyBufModified"
				name = name .. " +"
			end
			return { " " .. name .. " ", hl = hl }
		end)
		return {
			bufs,
			line.spacer(),
			hl = "TabbyFill",
		}
	end,
})

vim.o.showtabline = 2
