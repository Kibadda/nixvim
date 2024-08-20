if vim.g.loaded_terminal then
  return
end

vim.g.loaded_terminal = 1

local autocmd = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("Terminal", { clear = true })

autocmd("TermOpen", {
  group = group,
  callback = function(args)
    vim.bo.filetype = "term"
    vim.wo.winbar = nil

    local function map(lhs, rhs)
      vim.keymap.set("t", lhs, rhs, { buffer = args.buf })
    end

    map("<C-h>", "<C-\\><C-n><C-w>h")
    map("<C-j>", "<C-\\><C-n><C-w>j")
    map("<C-k>", "<C-\\><C-n><C-w>k")
    map("<C-l>", "<C-\\><C-n><C-w>l")

    vim.cmd.startinsert()
  end,
})

autocmd("BufEnter", {
  group = group,
  pattern = "term://*",
  callback = function()
    vim.cmd.startinsert()
  end,
})

local term_buffer = nil
local function toggle_term_buffer()
  if not term_buffer or not vim.api.nvim_buf_is_valid(term_buffer) then
    term_buffer = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_call(term_buffer, function()
      vim.fn.termopen(vim.o.shell, {
        on_exit = function()
          vim.api.nvim_buf_delete(term_buffer, { force = true })
        end,
      })
    end)
  else
    local term_wins = vim.tbl_filter(function(win)
      return vim.api.nvim_win_get_buf(win) == term_buffer
    end, vim.api.nvim_tabpage_list_wins(0))

    if next(term_wins) ~= nil then
      for _, win in pairs(term_wins) do
        vim.api.nvim_win_close(win, true)
      end

      return
    end
  end

  local winheight = math.min(math.floor(vim.o.lines * 0.3 + 0.5), 32)

  vim.api.nvim_open_win(term_buffer, true, {
    win = -1,
    split = "below",
    height = winheight,
  })
end

vim.keymap.set({ "n", "t" }, "<C-t>", toggle_term_buffer)
