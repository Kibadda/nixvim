local expand = vim.snippet.expand
---@diagnostic disable-next-line:duplicate-set-field
function vim.snippet.expand(...)
  local tab_map = {
    i = vim.fn.maparg("<Tab>", "i", false, true),
    s = vim.fn.maparg("<Tab>", "s", false, true),
  }
  local stab_map = {
    i = vim.fn.maparg("<S-Tab>", "i", false, true),
    s = vim.fn.maparg("<S-Tab>", "s", false, true),
  }

  expand(...)

  vim.schedule(function()
    vim.fn.mapset("i", false, tab_map.i)
    vim.fn.mapset("s", false, tab_map.s)
    vim.fn.mapset("i", false, stab_map.i)
    vim.fn.mapset("s", false, stab_map.s)
  end)
end
