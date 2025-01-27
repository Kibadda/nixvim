vim.lsp.config["nil"] = {
  cmd = { "nil" },
  root_markers = { "flake.nix" },
  filetypes = { "nix" },
  settings = {
    ["nil"] = {
      formatting = {
        command = { "nixfmt" },
      },
      flake = {
        autoArchive = true,
        autoEvalInputs = true,
      },
    },
  },
}
