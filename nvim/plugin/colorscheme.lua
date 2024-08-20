if vim.g.loaded_colorscheme then
  return
end

vim.g.loaded_colorscheme = 1

vim.cmd.colorscheme "gruvbox"
