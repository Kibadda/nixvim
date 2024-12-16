vim.cmd [[packadd cfilter]]
vim.wo.statusline = "%{%v:lua.Statusline()%}"
