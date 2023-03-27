local opt = vim.opt

vim.cmd('autocmd!')

vim.scriptencoding = 'utf-8'
opt.encoding = 'utf-8'
opt.fileencoding = 'utf-8'

vim.wo.number = true

opt.textwidth = 100
opt.scrolloff = 7
opt.wildignore = {"*/node_modules/*"}
opt.wildmode = 'longest,full'
opt.inccommand = 'split'
opt.lazyredraw = true
opt.showmatch = true
opt.ignorecase = true
opt.smartcase = true
opt.autoindent = true
opt.tabstop = 2
opt.softtabstop = 0
opt.expandtab = true
opt.shiftwidth = 2
opt.number = true
opt.relativenumber = true
opt.smartindent = true
opt.laststatus = 3
opt.showmode = false
opt.shada = [['20,<50,s10,h,/100]]
opt.hidden = true
opt.joinspaces = false
opt.guicursor = [[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]]
opt.updatetime = 100
opt.conceallevel = 2
opt.concealcursor = 'nc'
opt.previewheight = 5
opt.undofile = true
opt.synmaxcol = 500
opt.display = 'msgsep'
opt.modeline = false
opt.mouse = 'nivh'
opt.signcolumn = 'yes:1'
opt.splitbelow = true
opt.splitright = true
opt.timeoutlen = 200
opt.fillchars = [[vert:|,horiz:-,eob: ]]
opt.wrap = false
opt.backspace = 'start,eol,indent'

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])
