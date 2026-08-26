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

-- nvim の split 内で動けなければ herdr の pane へ抜ける。herdr は pane の
-- 実行中コマンドを見てキーを分岐できないので、判定をこちら側に持つ。
local herdr_direction = { h = "left", j = "down", k = "up", l = "right" }
local function nav(key)
	return function()
		local from = vim.fn.winnr()
		vim.cmd.wincmd(key)
		if vim.fn.winnr() == from then
			vim.system({ "herdr", "pane", "focus", "--current", "--direction", herdr_direction[key] })
		end
	end
end

for key, direction in pairs(herdr_direction) do
	vim.keymap.set("n", "<A-" .. key .. ">", nav(key), { desc = "Move to " .. direction .. " window or pane" })
end

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

local function is_previewable_asset(path)
	local ext = path:match("%.(%w+)$")
	return ext ~= nil
		and vim.tbl_contains({ "svg", "png", "jpg", "jpeg", "gif", "webp", "avif", "ico", "pdf" }, ext:lower())
end

-- カーソル下の識別子の import 元がアセットなら、実ファイルパスに解決する
local function resolve_asset_import_under_cursor()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		return nil
	end
	local import_path
	for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
		import_path = line:match("import%s+" .. word .. '%s+from%s+["\']([^"\']+)["\']')
		if import_path then
			break
		end
	end
	if not import_path or not is_previewable_asset(import_path) then
		return nil
	end
	if import_path:sub(1, 1) == "." then
		local resolved = vim.fs.normalize(vim.fn.expand("%:p:h") .. "/" .. import_path)
		return (vim.uv or vim.loop).fs_stat(resolved) and resolved or nil
	end
	-- alias ("@images/foo.svg" 等) は tsconfig を読まず、末尾パス一致でプロジェクト内を検索する。
	-- alias 名はディレクトリ名に一致することが多いので "**/images/foo.svg" を優先し、外れたら "**/foo.svg" に緩める
	local alias, tail = import_path:match("^@([^/]+)/(.+)$")
	local root = vim.fs.root(0, { "package.json", ".git" }) or vim.fn.getcwd()
	if vim.fn.executable("rg") == 1 then
		local function rg_find(glob)
			return vim.fn.systemlist({ "rg", "--files", "--glob", glob, root })[1]
		end
		if alias then
			return rg_find("**/" .. alias .. "/" .. tail) or rg_find("**/" .. tail)
		end
		return rg_find("**/" .. import_path)
	end
	return vim.fs.find(vim.fs.basename(tail or import_path), { path = root, type = "file", limit = 1 })[1]
end

vim.keymap.set("n", "<leader>pv", function()
	local file
	if vim.bo.filetype == "oil" then
		local oil = require("oil")
		local entry = oil.get_cursor_entry()
		local dir = oil.get_current_dir()
		if entry and entry.type == "file" and dir then
			file = dir .. entry.name
		end
	else
		file = resolve_asset_import_under_cursor() or vim.fn.expand("%:p"):gsub("^%w+://", "")
	end
	if file and file:match("%.[a-zA-Z]+$") then
		vim.fn.jobstart({ "qlmanage", "-p", file })
	else
		vim.notify("No previewable file", vim.log.levels.WARN)
	end
end, { desc = "Preview file with Quick Look" })
