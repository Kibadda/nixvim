if vim.g.loaded_plugin_kitty_navigator then
  return
end

vim.g.loaded_plugin_kitty_navigator = 1

vim.keymap.set("n", "<C-h>", "<Cmd>KittyNavigateLeft<CR>", { desc = "Kitty Left" })
vim.keymap.set("n", "<C-j>", "<Cmd>KittyNavigateDown<CR>", { desc = "Kitty Down" })
vim.keymap.set("n", "<C-k>", "<Cmd>KittyNavigateUp<CR>", { desc = "Kitty Up" })
vim.keymap.set("n", "<C-l>", "<Cmd>KittyNavigateRight<CR>", { desc = "Kitty Right" })
