--  _  __ _  _               _     _
-- | |/ /(_)| |__   __ _  __| | __| | __ _
-- | ' / | || ´_ \ / _` |/ _` |/ _` |/ _` |
-- | . \ | || |_) | (_| | (_| | (_| | (_| |
-- |_|\_\|_||_⹁__/ \__,_|\__,_|\__,_|\__,_|

vim.g.mapleader = vim.keycode "<Space>"

local set = vim.keymap.set
---@diagnostic disable-next-line:duplicate-set-field
function vim.keymap.set(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  set(mode, lhs, rhs, opts)
end

vim.g.loaded_netrw = 0
vim.g.loaded_netrwPlugin = 0
vim.g.loaded_gzip = 0
vim.g.loaded_tarPlugin = 0
vim.g.loaded_tutor_mode_plugin = 0
vim.g.loaed_zipPlugin = 0
