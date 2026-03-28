local treesitter = require("nvim-treesitter")
treesitter.setup({})

-- Add nvim-treesitter runtime/ to rtp so inherited queries (ecma, jsx) are found
local ts_runtime = vim.fn.stdpath("data") .. "/site/pack/core/opt/nvim-treesitter/runtime"
if vim.fn.isdirectory(ts_runtime) == 1 and not vim.list_contains(vim.opt.rtp:get(), ts_runtime) then
	vim.opt.rtp:prepend(ts_runtime)
end

local ensure_installed = {
	"vim",
	"vimdoc",
	"rust",
	"toml",
	"c",
	"cpp",
	"go",
	"html",
	"css",
	"javascript",
	"json",
	"lua",
	"markdown",
	"python",
	"typescript",
	"tsx",
	"styled",
	"vue",
	"svelte",
	"bash",
	"ruby",
	"embedded_template",
	"proto",
}

local config = require("nvim-treesitter.config")
local already_installed = config.get_installed()
local parsers_to_install = {}

for _, parser in ipairs(ensure_installed) do
	if not vim.tbl_contains(already_installed, parser) then
		table.insert(parsers_to_install, parser)
	end
end

if #parsers_to_install > 0 then
	treesitter.install(parsers_to_install)
end

local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function(args)
		if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
			vim.treesitter.start(args.buf)
		end
	end,
})
