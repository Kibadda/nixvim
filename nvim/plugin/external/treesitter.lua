if vim.g.loaded_plugin_treesitter then
  return
end

vim.g.loaded_plugin_treesitter = 1

---@class me.treesitter.ParserInfo : ParserInfo
---@field name string

---@type (string|me.treesitter.ParserInfo)[]
local parsers = {
  "gitcommit",
  "git_rebase",
  "html",
  "hyprlang",
  "javascript",
  "lua",
  "markdown",
  "markdown_inline",
  "php",
  "php_only",
  "regex",
  "rust",
  "sql",
  "toml",
  "typescript",
  "c",
  "nix",
  "yaml",
  "bash",
  "typst",

  {
    name = "smarty",
    ---@diagnostic disable-next-line:missing-fields
    install_info = {
      path = vim.fn.expand "$HOME/Projects/Personal/tree-sitter-smarty",
      files = { "src/parser.c", "src/scanner.c" },
    },
    tier = 3,
  },

  {
    name = "blade",
    ---@diagnostic disable-next-line:missing-fields
    install_info = {
      url = "https://github.com/EmranMR/tree-sitter-blade",
      files = { "src/parser.c" },
      branch = "main",
    },
    tier = 3,
  },
}

local function add_parsers()
  local treesitter_parsers = require "nvim-treesitter.parsers"

  for _, config in ipairs(parsers) do
    if type(config) == "table" then
      treesitter_parsers[config.name] = config

      if config.install_info.path and not vim.tbl_contains(vim.opt.runtimepath:get(), config.install_info.path) then
        vim.opt.runtimepath:append(config.install_info.path)
      end
    end
  end
end

local group = vim.api.nvim_create_augroup("Treesitter", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "TSUpdate",
  callback = add_parsers,
})

add_parsers()

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = vim.tbl_map(function(parser)
    return type(parser) == "string" and parser or parser.name
  end, parsers),
  callback = function(args)
    vim.treesitter.start()
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

require("nvim-treesitter").setup {
  ensure_install = vim
    .iter(parsers)
    :filter(function(parser)
      return type(parser) == "string"
    end)
    :totable(),
}
