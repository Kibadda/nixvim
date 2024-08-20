vim.cmd [[packadd cfilter]]
vim.wo.statusline = "%{%v:lua.require'me.statusline'()%}"
