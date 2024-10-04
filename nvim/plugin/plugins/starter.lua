if vim.g.loaded_plugin_starter then
  return
end

vim.g.loaded_plugin_starter = 1

---@type starter.config
vim.g.starter = {
  items = function()
    return vim.tbl_map(function(session)
      return {
        text = session,
        action = function()
          require("session").load(session)
        end,
      }
    end, require("session").list())
  end,
}
