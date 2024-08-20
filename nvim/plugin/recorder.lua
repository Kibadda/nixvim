if vim.g.loaded_recorder then
  return
end

vim.g.loaded_recorder = 1

require("recorder").setup {
  lessNotifications = true,
}
