vim.lsp.config["typescript-language-server"] = {
  cmd = { "typescript-language-server", "--stdio" },
  root_markers = { "package.json" },
  filetypes = { "javascript", "typescript" },
}
