if vim.g.loaded_mini_ai then
  return
end

vim.g.loaded_mini_ai = 1

require("mini.ai").setup()
