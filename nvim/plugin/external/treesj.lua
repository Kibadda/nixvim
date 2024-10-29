if vim.g.loaded_plugin_treesj then
  return
end

vim.g.loaded_plugin_treesj = 1

vim.keymap.set("n", "gJ", "<Cmd>TSJToggle<CR>", { desc = "Join/Split Lines" })

require("treesj").setup {
  use_default_keymaps = false,
  max_join_length = 1000,
}
