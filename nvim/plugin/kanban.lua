if vim.g.loaded_plugin_kanban then
  return
end

vim.g.loaded_plugin_kanban = 1

vim.keymap.set("n", "<Leader>k", function()
  require("me.kanban").toggle()
end, { desc = "Kanban" })
