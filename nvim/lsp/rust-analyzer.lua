vim.lsp.config["rust-analyzer"] = {
  cmd = { "rust-analyzer" },
  root_markers = { "Cargo.toml" },
  filetypes = { "rust" },
  settings = {
    checkOnSave = false,
  },
}
