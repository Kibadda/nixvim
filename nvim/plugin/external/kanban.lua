if vim.g.loaded_plugin_kanban then
  return
end

vim.g.loaded_plugin_kanban = 1

---@type kanban.config
vim.g.kanban = {
  sources = {
    {
      type = "gitlab",
      name = "todo",
      data = {
        token = "GITLAB_ACCESS_TOKEN",
        project = "GITLAB_PROJECT_URL",
        boardId = 50,
      },
      initial_focus = function()
        return ({ "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag" })[tonumber(os.date "%w")]
      end,
    },
  },
}
