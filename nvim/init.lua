--  _  __ _  _               _     _
-- | |/ /(_)| |__   __ _  __| | __| | __ _
-- | ' / | || ´_ \ / _` |/ _` |/ _` |/ _` |
-- | . \ | || |_) | (_| | (_| | (_| | (_| |
-- |_|\_\|_||_⹁__/ \__,_|\__,_|\__,_|\__,_|

vim.g.mapleader = vim.keycode "<Space>"

vim.cmd.colorscheme "gruvbox"

local set = vim.keymap.set
---@diagnostic disable-next-line:duplicate-set-field
function vim.keymap.set(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  set(mode, lhs, rhs, opts)
end
