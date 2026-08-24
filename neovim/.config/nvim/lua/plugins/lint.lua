local lint = require("lint")
local oxc = require("oxc")

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

-- 既定の cmd は nvim の cwd 直下の node_modules しか見ないため、リポジトリ直下以外で
-- 開くと PATH の oxlint に落ちる。設定ファイルの位置から解決し直す。
lint.linters.oxlint = vim.tbl_extend("force", require("lint.linters.oxlint"), {
	cmd = function()
		local root = oxc.lint_root(vim.api.nvim_get_current_buf())
		local local_bin = root and (root .. "/node_modules/.bin/oxlint")
		if local_bin and vim.uv.fs_stat(local_bin) then
			return local_bin
		end
		return "oxlint"
	end,
})

local oxlint_fts = {
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
	vue = true,
	svelte = true,
}

-- oxlint が見るのは JS/TS だけ。JSON は eslint_d の担当から外すに留める
local oxc_fts = vim.tbl_extend("force", oxlint_fts, { json = true, jsonc = true })

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local root = oxc_fts[vim.bo[bufnr].filetype] and oxc.lint_root(bufnr) or nil
		if not root then
			lint.try_lint()
		elseif oxlint_fts[vim.bo[bufnr].filetype] then
			lint.try_lint("oxlint", { cwd = root })
		end
		lint.try_lint("typos")
	end,
})
