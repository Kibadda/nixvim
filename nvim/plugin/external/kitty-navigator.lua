if vim.g.loaded_plugin_kitty_navigator then
  return
end

vim.g.loaded_plugin_kitty_navigator = 1

local kitty_is_last_pane = false

vim.api.nvim_create_autocmd("WinEnter", {
  group = vim.api.nvim_create_augroup("KittyNavigate", { clear = true }),
  callback = function()
    kitty_is_last_pane = false
  end,
})

local function navigate(direction)
  return function()
    local win = vim.api.nvim_get_current_win()

    vim.cmd.wincmd(direction)

    local at_edge = win == vim.api.nvim_get_current_win()

    if kitty_is_last_pane or at_edge then
      vim.system {
        "kitty",
        "@",
        "focus-window",
        "--match",
        "neighbor:" .. ({ h = "left", j = "bottom", k = "top", l = "right" })[direction],
      }
      kitty_is_last_pane = true
    else
      kitty_is_last_pane = false
    end
  end
end

vim.keymap.set("n", "<C-h>", navigate "h", { desc = "Kitty Left" })
vim.keymap.set("n", "<C-j>", navigate "j", { desc = "Kitty Down" })
vim.keymap.set("n", "<C-k>", navigate "k", { desc = "Kitty Up" })
vim.keymap.set("n", "<C-l>", navigate "l", { desc = "Kitty Right" })
