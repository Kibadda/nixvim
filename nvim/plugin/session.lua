if vim.g.loaded_session_1 then
  return
end

vim.g.loaded_session_1 = 1

vim.keymap.set("n", "<Leader>Sn", "<Plug>(SessionNew)", { desc = "New" })
vim.keymap.set("n", "<Leader>Sd", "<Plug>(SessionDelete)", { desc = "Delete" })
vim.keymap.set("n", "<Leader>Sl", "<Plug>(SessionLoad)", { desc = "Load" })

local function kitty(title)
  vim.system {
    "kitty",
    "@",
    "--to",
    vim.env.KITTY_LISTEN_ON,
    "set-tab-title",
    title and "nvim " .. title or "",
  }
end

local group = vim.api.nvim_create_augroup("Session", { clear = true })

vim.api.nvim_create_autocmd({ "VimLeavePre", "FocusLost" }, {
  group = group,
  callback = function()
    kitty()
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "SessionLoadPost" }, {
  group = group,
  callback = function()
    if vim.v.this_session and vim.v.this_session ~= "" then
      kitty(vim.fs.basename(vim.v.this_session))
    end
  end,
})
