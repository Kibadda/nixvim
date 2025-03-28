if vim.g.loaded_plugin_lsp then
  return
end

vim.g.loaded_plugin_lsp = 1

vim.lsp.set_log_level(vim.lsp.log_levels.WARN)

vim.diagnostic.config {
  severity_sort = true,
  jump = {
    float = true,
  },
  signs = {
    severity = { min = vim.diagnostic.severity.ERROR },
  },
  underline = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
  virtual_text = true,
}

vim.keymap.set("n", "<Leader>ld", function()
  vim.diagnostic.config {
    virtual_lines = not vim.diagnostic.config().virtual_lines and { current_line = true } or false,
  }
end)

require "me.lsp.attach"
require "me.lsp.progress"

vim.lsp.enable "lua-language-server"
vim.lsp.enable "nil"
vim.lsp.enable "intelephense"
vim.lsp.enable "typescript-language-server"
vim.lsp.enable "rust-analyzer"
vim.lsp.enable "tinymist"
