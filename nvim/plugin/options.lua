if vim.g.loaded_plugin_options then
  return
end

vim.g.loaded_plugin_options = 1

local o = vim.o
o.autowrite = true
o.breakindent = true
o.completeopt = "menu,menuone,noinsert,fuzzy,noselect"
o.confirm = true
o.cursorline = true
o.diffopt = "internal,filler,closeoff,hiddenoff,algorithm:minimal,linematch:50"
o.expandtab = true
o.fillchars = "eob: "
o.foldenable = false
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldmethod = "expr"
o.foldtext = ""
o.grepformat = "%f:%l:%c:%m"
o.grepprg = "rg --vimgrep"
o.ignorecase = true
o.laststatus = 3
o.linebreak = true
o.list = true
o.mouse = "nv"
o.number = true
o.pumblend = 0
o.relativenumber = true
o.scrolloff = 8
o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,terminal,globals"
o.shada = "!,'1000,<50,s10,h"
o.shiftround = true
o.shiftwidth = 4
o.shortmess = "filmnxtToOWAIcCFS"
-- o.showbreak = "|-> "
o.showmode = false
o.showtabline = 0
o.sidescrolloff = 8
o.signcolumn = "no"
o.smartcase = true
o.smoothscroll = true
o.softtabstop = 4
o.swapfile = false
o.tabstop = 4
o.termguicolors = true
o.textwidth = 120
o.timeoutlen = 1000
o.undofile = true
o.updatetime = 250
o.wildmode = "longest:full,full"
