if vim.g.loaded_plugin_git_diff then
  return
end

vim.g.loaded_plugin_git_diff = 1

vim.g.git = {
  extra = {
    uncommit = {
      cmd = { "uncommit" },
    },
  },
}
