if vim.g.loaded_plugin_autocmds then
  return
end

vim.g.loaded_plugin_autocmds = 1

local autocmd = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("Autocmds", { clear = true })

autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank()
  end,
})

autocmd("BufReadPost", {
  group = group,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("VimResized", {
  group = group,
  callback = function()
    vim.cmd.wincmd "="
  end,
})

autocmd("BufEnter", {
  group = group,
  callback = function()
    vim.opt_local.formatoptions:remove "t"
    vim.opt_local.formatoptions:remove "o"
    vim.opt_local.formatoptions:append "n"
  end,
})

autocmd("VimEnter", {
  group = group,
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 1 then
      vim.cmd.cd(data.file)
      vim.cmd.argdelete "*"
      vim.cmd.bdelete()
    end
  end,
})

autocmd("FileType", {
  group = group,
  pattern = {
    "help",
    "qf",
    "checkhealth",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})
