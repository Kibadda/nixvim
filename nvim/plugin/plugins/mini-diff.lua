if vim.g.loaded_plugin_mini_diff then
  return
end

vim.g.loaded_plugin_mini_diff = 1

require("mini.diff").setup {
  mappings = {
    textobject = "ih",
  },
  options = {
    wrap_goto = true,
  },
}
