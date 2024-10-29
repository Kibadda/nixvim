if vim.g.loaded_plugin_recorder then
  return
end

vim.g.loaded_plugin_recorder = 1

require("recorder").setup {
  lessNotifications = true,
}
