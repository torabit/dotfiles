local oxc = require("oxc")

-- oxfmt が扱える拡張子(JS/TS/JSON/CSS)は oxfmt に寄せる
local function oxfmt_or(fallback)
	return function(bufnr)
		return oxc.fmt_root(bufnr) and { "oxfmt" } or fallback
	end
end

-- oxfmt は Markdown を素通しするので、整形すると oxfmt --check を通る差分にならない
local function markdown_formatters(bufnr)
	return oxc.fmt_root(bufnr) and {} or { "prettierd" }
end

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		go = { "gofumpt" },
		javascript = oxfmt_or({ "prettierd" }),
		javascriptreact = oxfmt_or({ "prettierd" }),
		typescript = oxfmt_or({ "prettierd" }),
		typescriptreact = oxfmt_or({ "prettierd" }),
		vue = oxfmt_or({ "prettierd" }),
		svelte = oxfmt_or({ "prettierd" }),
		css = oxfmt_or({ "prettierd" }),
		html = { "prettierd" },
		markdown = markdown_formatters,
		json = oxfmt_or({ "fixjson" }),
		jsonc = oxfmt_or({ "fixjson" }),
		sh = { "shfmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		ruby = { "rubocop" },
		rust = { "rustfmt" },
		eruby = { "erb_format" },
	},
	format_on_save = {
		timeout_ms = 2000,
		lsp_format = "fallback",
	},
})
