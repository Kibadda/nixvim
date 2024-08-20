if vim.g.loaded_plugin_colorscheme then
  return
end

vim.g.loaded_plugin_colorscheme = 1

vim.cmd.colorscheme "gruvbox"
