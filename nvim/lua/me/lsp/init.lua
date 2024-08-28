local M = {
  ---@type table<string, me.lsp.ServerConfig>
  servers = {},
  augroup = vim.api.nvim_create_augroup("LspServers", { clear = true }),
}

---@class me.lsp.ServerConfig
---@field filetypes string[]
---@field root_markers string[]
---@field config vim.lsp.ClientConfig
---@field clients? vim.lsp.Client[]

---@param server me.lsp.ServerConfig
local function start(server, buf)
  local id = vim.lsp.start(vim.tbl_deep_extend("keep", {
    root_dir = vim.fs.root(buf, server.root_markers),
  }, server.config))

  if id then
    server.clients = server.clients or {}

    if not server.clients[id] then
      server.clients[id] = vim.lsp.get_client_by_id(id)
    end
  end
end

---@param server me.lsp.ServerConfig
function M.register(server)
  server.config.name = server.config.name or server.config.cmd[1]

  server.config.capabilities =
    vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), server.config.capabilities or {})

  M.servers[server.config.name] = server

  vim.api.nvim_create_autocmd("FileType", {
    group = M.augroup,
    pattern = server.filetypes,
    callback = function(args)
      start(server, args.buf)
    end,
  })
end

return M
