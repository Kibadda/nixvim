vim.lsp.config["lua-language-server"] = {
  cmd = { "lua-language-server" },
  root_markers = { ".luarc.json", "stylua.toml", ".stylua.toml" },
  filetypes = { "lua" },
  before_init = function(params, config)
    if not params.rootPath or type(params.rootPath) ~= "string" then
      return
    end

    config.settings.Lua.workspace.library = config.settings.Lua.workspace.library or {}

    -- for own external plugins
    if params.rootPath:find ".nvim" then
      table.insert(config.settings.Lua.workspace.library, vim.env.VIMRUNTIME .. "/lua")
    end

    if vim.fn.isdirectory(params.rootPath .. "/lua") == 1 then
      table.insert(config.settings.Lua.workspace.library, params.rootPath .. "/lua")
    end
  end,
  settings = {
    Lua = {
      format = {
        enable = false,
      },
      workspace = {
        checkThirdParty = false,
      },
      hint = {
        enable = true,
        arrayIndex = "Disable",
      },
      completion = {
        callSnippet = "Replace",
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
