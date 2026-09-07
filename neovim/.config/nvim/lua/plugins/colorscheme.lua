-- 配色は palette (vanadis の生成物) から読む。テーマ名と light / dark を直接書くと、
-- vanadis apply --variant dark を打っても nvim だけ light のまま残る。
local p = require("palette")
vim.opt.background = p.variant
vim.cmd.colorscheme(p.colorscheme)
vim.api.nvim_set_hl(0, "LineNr", { fg = p.brown, bg = p.bg })
