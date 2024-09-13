-- Based on mfussenegger/gruvbox-material

vim.cmd.highlight "clear"
if vim.g.syntax_on then
  vim.cmd.syntax "reset"
end
vim.g.colors_name = "gruvbox"

local colors = {
  black = "#363531",
  red = "#ea6962",
  green = "#a9b665",
  yellow = "#d8a657",
  blue = "#7daea3",
  magenta = "#d3869b",
  cyan = "#89b482",
  white = "#d4be98",
  orange = "#e78a4e",
  grey = "#928374",
  darkgrey = "#4f5258",
}

vim.g.colors = colors
vim.g.terminal_color_0 = colors.black
vim.g.terminal_color_1 = colors.red
vim.g.terminal_color_2 = colors.green
vim.g.terminal_color_3 = colors.yellow
vim.g.terminal_color_4 = colors.blue
vim.g.terminal_color_5 = colors.magenta
vim.g.terminal_color_6 = colors.cyan
vim.g.terminal_color_7 = colors.white
vim.g.terminal_color_8 = colors.black
vim.g.terminal_color_9 = colors.red
vim.g.terminal_color_10 = colors.green
vim.g.terminal_color_11 = colors.yellow
vim.g.terminal_color_12 = colors.blue
vim.g.terminal_color_13 = colors.magenta
vim.g.terminal_color_14 = colors.cyan
vim.g.terminal_color_15 = colors.white

for name, hl in pairs {
  Normal = { fg = colors.white },
  NormalFloat = { fg = colors.white, bg = colors.black },
  FloatBorder = { fg = colors.grey, bg = colors.black },
  FloatTitle = { fg = colors.orange, bg = colors.black, bold = true },
  FloatFooter = { fg = colors.orange, bg = colors.black, bold = true },
  StatusLine = { fg = colors.white },
  StatusLineNC = { fg = colors.grey },
  CursorLineNr = { fg = colors.yellow, bold = true },
  LineNr = { fg = colors.grey },
  SignColumn = { fg = colors.white },
  SpecialKey = { fg = colors.black },
  EndOfBuffer = { fg = colors.black },
  NonText = { fg = colors.black },
  Search = { fg = colors.black, bg = colors.green },
  CurSearch = { fg = colors.black, bg = colors.yellow },
  Error = { fg = colors.red },
  MatchParen = { bold = true, underline = true },
  WinSeparator = { fg = colors.blue },
  Visual = { bg = colors.darkgrey },
  DiffAdd = { bg = colors.cyan },
  DiffChange = { bg = colors.grey },
  DiffDelete = { bg = colors.red },
  DiffText = { bg = colors.blue },
  Folded = { fg = colors.grey },
  Conceal = { fg = colors.black },
  CursorLine = { bg = colors.darkgrey },
  CursorColumn = { bg = colors.darkgrey },
  ColorColumn = { bg = colors.darkgrey },
  QuickFixLine = { fg = colors.magenta, bold = true },
  Todo = { fg = colors.magenta, italic = true },
  Question = { fg = colors.yellow },

  Operator = { fg = colors.orange },
  String = { fg = colors.green },
  Number = { fg = colors.magenta },
  Directory = { fg = colors.green },
  Function = { fg = colors.cyan },
  Keyword = { fg = colors.red },
  Constant = { fg = colors.magenta },
  Delimiter = { fg = colors.white },
  Title = { fg = colors.orange, bold = true },
  StorageClass = { fg = colors.orange },
  Structure = { fg = colors.orange },
  Character = { fg = colors.green },
  Float = { fg = colors.magenta },
  Identifier = { fg = colors.blue },
  Conditional = { fg = colors.red },
  Statement = { fg = colors.red },
  Repeat = { fg = colors.red },
  Label = { fg = colors.orange },
  Exception = { fg = colors.red },
  Include = { fg = colors.magenta },
  PreProc = { fg = colors.magenta },
  Define = { fg = colors.magenta },
  Macro = { fg = colors.cyan },
  Typedef = { fg = colors.red },
  Tag = { fg = colors.orange },
  Special = { fg = colors.yellow },
  SpecialChar = { fg = colors.yellow },
  SpecialComment = { fg = colors.grey, italic = true },
  Debug = { fg = colors.orange },
  Comment = { fg = colors.grey },
  Boolean = { fg = colors.magenta },
  Type = { fg = colors.yellow },

  SpellBad = { undercurl = true, special = colors.red },
  SpellCap = { undercurl = true, special = colors.blue },
  SpellRare = { undercurl = true, special = colors.magenta },
  SpellLocal = { undercurl = true, special = colors.cyan },

  DiagnosticError = { fg = colors.red },
  DiagnosticWarn = { fg = colors.yellow },
  DiagnosticInfo = { fg = colors.blue },
  DiagnosticHint = { fg = colors.green },
  DiagnosticFloatingError = { fg = colors.red, bg = colors.blavk },
  DiagnosticFloatingWarn = { fg = colors.yellow, bg = colors.black },
  DiagnosticFloatingInfo = { fg = colors.blue, bg = colors.black },
  DiagnosticFloatingHint = { fg = colors.green, bg = colors.black },
  DiagnosticUnderlineError = { underline = true, special = colors.red },
  DiagnosticUnderlineWarn = { underline = true, special = colors.yellow },
  DiagnosticUnderlineInfo = { underline = true, special = colors.blue },
  DiagnosticUnderlineHint = { underline = true, special = colors.green },

  LspCodeLens = { fg = colors.blue },
  LspInlayHint = { fg = colors.blue },

  ErrorMsg = { fg = colors.red, bold = true },
  WarningMsg = { fg = colors.yellow, bold = true },
  MoreMsg = { fg = colors.yellow, bold = true },

  Pmenu = { fg = colors.white, bg = colors.black },
  PmenuMatch = { fg = colors.white, bg = colors.black, bold = true, underline = true },
  PmenuSel = { fg = colors.yellow, bg = colors.black },
  PmenuMatchSel = { fg = colors.yellow, bg = colors.black, bold = true, underline = true },
  PmenuKind = { fg = colors.yellow, bg = colors.black },

  ["@markup.emphasis"] = { fg = colors.cyan, italic = true },
  ["@markup.link"] = { fg = colors.yellow, bold = true },
  ["@markup.link.uri"] = { fg = colors.magenta, italic = true },
  ["@markup.list"] = { fg = colors.cyan },
  ["@markup.raw"] = { fg = colors.green },
  ["@markup.strong"] = { fg = colors.red, bold = true },
  ["@markup.underline"] = { underline = true },
  ["@variable.member"] = { fg = colors.blue },
  ["@lsp.mod.defaultLibrary"] = { fg = colors.yellow },
  ["@lsp.mod.global"] = { fg = colors.magenta },
  ["@lsp.typemod.property"] = { fg = colors.blue },
  ["@lsp.typemod.member"] = { fg = colors.blue },
  ["@lsp.typemod.function"] = { fg = colors.cyan },
  ["@lsp.typemod.function.defaultLibrary"] = { fg = colors.yellow },
  ["@tag"] = { fg = colors.red },
  ["@tag.attribute"] = { fg = colors.yellow },
  ["@tag.delimiter"] = { fg = colors.grey },

  Added = { fg = colors.green },
  Removed = { fg = colors.red },
  Changed = { fg = colors.blue },
} do
  vim.api.nvim_set_hl(0, name, hl)
end
