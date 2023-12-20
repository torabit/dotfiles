local util = require("torabit.init")
util.cowboy()
-- Keybindings
local silent = { silent = true, noremap = true }
local keymap = vim.keymap

-- Quit, close buffer, etc.
keymap.set("n", "<leader>q", ":qa<cr>", silent)
keymap.set("n", "<leader>x", ":x!<cr>", silent)

-- Save buffer
keymap.set("i", "<c-s>", "<esc>:w<cr>a", silent)
keymap.set("n", "<leader>w", ":w<cr>", silent)

-- New tab
keymap.set("n", "te", ":tabedit<cr>", silent)

-- Spilit Window
keymap.set("n", "ss", ":split<cr><c-w>w", silent)
keymap.set("n", "sv", ":vsplit<cr><c-w>w", silent)

-- Window movement
keymap.set("n", "<c-h>", "<c-w>h", silent)
keymap.set("n", "<c-j>", "<c-w>j", silent)
keymap.set("n", "<c-k>", "<c-w>k", silent)
keymap.set("n", "<c-l>", "<c-w>l", silent)

-- Tab movement
keymap.set("n", "<tab>", ":tabnext<cr>", silent)
keymap.set("n", "<s-tab>", ":tabpre<cr>", silent)

-- Buffer list movement
keymap.set("n", "[b", ":bprevious<cr>", silent)
keymap.set("n", "]b", ":bnext<cr>", silent)
keymap.set("n", "[B", ":bfirst<cr>", silent)
keymap.set("n", "]B", ":blast<cr>", silent)

-- Rename
keymap.set("n", "<leader>rn", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })

-- Disable key
-- TODO : <c-z> is assigned when Pause/Break key is pressed, probably due to Tmux.
keymap.set("n", "<c-z>", "<nop>", {})
keymap.set("", "<left>", "<nop>", silent)
keymap.set("", "<down>", "<nop>", silent)
keymap.set("", "<up>", "<nop>", silent)
keymap.set("", "<right>", "<nop>", silent)

-- TODO: Cowboy と 競合起こしている
-- 相対ブリンクしたときに、開始位置を記録する関数
-- '' で開始位置に戻る
-- keymap.set("n", "k", function()
--   if vim.v.count > 1 then
--     return [[m']] .. vim.v.count .. "k"
--   end
--   return "k"
-- end, { expr = true, silent = true })
-- keymap.set("n", "j", function()
--   if vim.v.count > 1 then
--     return [[m']] .. vim.v.count .. "j"
--   end
--   return "j"
-- end, { expr = true, silent = true })
