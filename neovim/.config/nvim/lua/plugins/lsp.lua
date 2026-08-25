local augroup = require("autocmds")
local p = require("palette")


local diagnostic_signs = {
	Error = "",
	Warn = "",
	Hint = "",
	Info = "",
}

vim.diagnostic.config({
	virtual_text = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
		focusable = true,
		style = "minimal",
	},
})

do
	local orig = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, opts)
	vim.keymap.set("n", "<leader>gr", function()
		require("fzf-lua").lsp_references()
	end, opts)

	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts)

	vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

	vim.keymap.set("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts)
	vim.keymap.set("n", "<leader>d", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	vim.keymap.set("n", "<leader>ft", function()
		require("fzf-lua").lsp_typedefs()
	end, opts)
	vim.keymap.set("n", "<leader>fs", function()
		require("fzf-lua").lsp_document_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fw", function()
		require("fzf-lua").lsp_workspace_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fi", function()
		require("fzf-lua").lsp_implementations()
	end, opts)

	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				require("conform").format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- Server configs and vim.lsp.enable are in lua/servers/
require("servers")

-- fix diagnostic colors to match palette.json (must run after everything else)
vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { fg = p.error, bg = p.bg })
vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { fg = p.warn, bg = p.bg })
vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { fg = p.visual, bg = p.bg })
vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { fg = p.comment, bg = p.bg })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = p.bg })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = p.border, bg = p.bg })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = p.error, fg = p.error })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = p.warn, fg = p.warn })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = p.visual, fg = p.visual })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = p.comment, fg = p.comment })
vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = p.error, bg = p.bg })
vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = p.warn, bg = p.bg })
vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = p.visual, bg = p.bg })
vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = p.comment, bg = p.bg })
