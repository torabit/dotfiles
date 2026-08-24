-- oxc(oxlint / oxfmt)を採用したプロジェクトを設定ファイルの探索で見分ける。
-- eslint_d / prettierd の既定はプロジェクト側の規約と衝突するため、設定ファイルがある側を優先する。
local M = {}

---@param bufnr integer
---@param markers string[]
---@return string|nil
local function root(bufnr, markers)
	if vim.api.nvim_buf_get_name(bufnr) == "" then
		return nil
	end
	return vim.fs.root(bufnr, markers)
end

---@param bufnr integer
---@return string|nil oxlint の設定を持つディレクトリ
function M.lint_root(bufnr)
	return root(bufnr, { ".oxlintrc.json", ".oxlintrc.jsonc" })
end

---@param bufnr integer
---@return string|nil oxfmt の設定を持つディレクトリ
function M.fmt_root(bufnr)
	return root(bufnr, { ".oxfmtrc.json", ".oxfmtrc.jsonc" })
end

return M
