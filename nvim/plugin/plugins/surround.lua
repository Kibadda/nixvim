if vim.g.loaded_plugin_surround then
  return
end

vim.g.loaded_plugin_surround = 1

require("nvim-surround").setup()
