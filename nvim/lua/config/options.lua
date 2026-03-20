local opt = vim.opt

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.cursorlineopt = "number"
opt.showmatch = true

opt.autoindent = true
opt.expandtab = true

opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.backspace = { "indent", "eol", "start" }
opt.scrolloff = 8
opt.swapfile = false
opt.backup = false
opt.clipboard = "unnamed"

opt.wildmenu = true
opt.wildmode = { "list:longest", "full" }

opt.autoread = true
opt.encoding = "utf-8"
