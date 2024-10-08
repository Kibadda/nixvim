if vim.g.loaded_plugin_lsp then
  return
end

vim.g.loaded_plugin_lsp = 1

vim.lsp.set_log_level(vim.lsp.log_levels.WARN)

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(vim.lsp.handlers["textDocument/publishDiagnostics"], {
    signs = {
      severity = { min = vim.diagnostic.severity.ERROR },
    },
    underline = {
      severity = { min = vim.diagnostic.severity.WARN },
    },
    virtual_text = true,
  })

vim.diagnostic.config {
  severity_sort = true,
  jump = {
    float = true,
  },
}

require "me.lsp.attach"
require "me.lsp.progress"
require "me.lsp.servers"
