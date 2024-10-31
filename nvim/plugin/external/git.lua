if vim.g.loaded_plugin_git then
  return
end

vim.g.loaded_plugin_git = 1

---@type git.config
vim.g.git = {
  extra = {
    uncommit = {
      cmd = { "uncommit" },
    },
  },
}
