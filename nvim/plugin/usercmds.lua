if vim.g.loaded_plugin_usercmds then
  return
end

vim.g.loaded_plugin_usercmds = 1

vim.api.nvim_create_user_command("D", function(args)
  vim.cmd.bprevious()
  vim.cmd.split()
  vim.cmd.bnext()
  vim.cmd.bdelete { bang = args.bang }
end, {
  bang = true,
  nargs = 0,
  desc = "Bdelete",
})
