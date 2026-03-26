local lint = require("lint")

lint.linters_by_ft = {
	lua = { "luacheck" },
	python = { "flake8" },
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	vue = { "eslint_d" },
	svelte = { "eslint_d" },
	json = { "eslint_d" },
	jsonc = { "eslint_d" },
	sh = { "shellcheck" },
	c = { "cpplint" },
	cpp = { "cpplint" },
	go = { "revive" },
	ruby = { "rubocop" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	callback = function()
		lint.try_lint()
		lint.try_lint("typos")
	end,
})
