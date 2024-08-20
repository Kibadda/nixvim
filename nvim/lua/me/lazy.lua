local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim
    .system({
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "https://github.com/folke/lazy.nvim.git",
      lazypath,
    })
    :wait()
end
vim.opt.runtimepath:prepend(lazypath)

vim.keymap.set("n", "<Leader>L", "<Cmd>Lazy<CR>", { desc = "Lazy" })

require("lazy").setup({
  {
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    { "ku1ik/vim-pasta", lazy = false },
    { "kylechui/nvim-surround", event = "VeryLazy" },
  },
  { import = "plugins" },
}, {
  defaults = {
    lazy = true,
  },
  concurrency = 8,
  dev = {
    patterns = { "Kibadda" },
    path = "~/Projects/Personal",
    fallback = false,
  },
  install = {
    missing = false,
  },
  ui = {
    title = " Lazy ",
    border = "single",
  },
  change_detection = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "netrw",
        "rplugin",
        "tarPlugin",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
