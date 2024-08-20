if vim.g.loaded_plugin_formatter then
  return
end

vim.g.loaded_plugin_formatter = 1

vim.g.AutoFormat = vim.g.AutoFormat or 0

vim.keymap.set("n", "<Leader>lt", function()
  vim.g.AutoFormat = vim.g.AutoFormat == 0 and 1 or 0
end, { desc = "Toggle Auto Format" })

vim.keymap.set("n", "<Leader>lf", function()
  if vim.b.formatter then
    vim.b.formatter()
  end
end, { desc = "Format" })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("AutoFormatter", { clear = true }),
  callback = function()
    if vim.g.AutoFormat == 1 and vim.b.formatter then
      vim.b.formatter()
    end
  end,
})
