local p = require("palette")
-- background と colorscheme はパレットから引く。ここに名前を書くと vanadis が
-- テーマを切り替えても PaperColor の light 側が出続ける。
vim.opt.background = p.variant
vim.cmd.colorscheme(p.colorscheme)
vim.api.nvim_set_hl(0, "LineNr", { fg = p.brown, bg = p.bg })
