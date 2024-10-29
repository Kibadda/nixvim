if vim.g.loaded_plugin_conform then
  return
end

vim.g.loaded_plugin_conform = 1

local conform = require "conform"

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("ConformAutoFormat", { clear = true }),
  callback = function(args)
    if #conform.list_formatters(args.buf) > 0 then
      vim.b[args.buf].formatter = conform.format
      vim.bo[args.buf].formatexpr = "v:lua.require'conform'.formatexpr()"
    end
  end,
})

conform.setup {
  formatters_by_ft = {
    lua = { "stylua" },
  },
  notify_on_error = false,
}
