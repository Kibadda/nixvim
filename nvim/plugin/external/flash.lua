if vim.g.loaded_plugin_flash then
  return
end

vim.g.loaded_plugin_flash = 1

---@diagnostic disable-next-line:missing-fields
require("flash").setup {
  jump = {
    autojump = true,
    nohlsearch = true,
  },
}

vim.keymap.set("n", "<Leader>j", function()
  require("flash").jump()
end)
