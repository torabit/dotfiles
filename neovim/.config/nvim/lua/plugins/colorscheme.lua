local p = require("palette")
vim.opt.background = "light"
vim.cmd.colorscheme("PaperColor")
vim.api.nvim_set_hl(0, "LineNr", { fg = p.brown, bg = p.bg })
