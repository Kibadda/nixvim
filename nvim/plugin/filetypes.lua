if vim.g.loaded_filetypes then
  return
end

vim.g.loaded_filetypes = 1

vim.filetype.add {
  pattern = {
    [".*/kitty/.*%.conf"] = "kitty",
    [".*/nginx/.*"] = "nginx",
    [".*/hypr/.*%.conf"] = "hyprlang",
  },
}
