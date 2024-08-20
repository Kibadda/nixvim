if vim.g.loaded_plugin_which_key then
  return
end

vim.g.loaded_plugin_which_key = 1

require("which-key").setup {
  preset = "classic",
  win = {
    border = "single",
  },
  spec = {
    { "<Leader>", group = "<Leader>" },
    { "<Leader>S", group = "Session" },
    { "<Leader>l", group = "Lsp" },
    { "<Leader>s", group = "Search" },
  },
}
