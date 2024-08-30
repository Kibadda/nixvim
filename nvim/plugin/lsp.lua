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

local group = vim.api.nvim_create_augroup("LspServers", { clear = true })

---@class me.lsp.ServerConfig
---@field filetypes string[]
---@field root_markers string[]
---@field config vim.lsp.ClientConfig

---@param server me.lsp.ServerConfig
local function register(server)
  server.config.name = server.config.name or server.config.cmd[1]

  server.config.capabilities =
    vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), server.config.capabilities or {})

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = server.filetypes,
    callback = function(args)
      vim.lsp.start(vim.tbl_deep_extend("keep", {
        root_dir = vim.fs.root(args.buf, server.root_markers),
      }, server.config))
    end,
  })
end

for _, server in ipairs(require "me.lsp.servers") do
  register(server)
end
