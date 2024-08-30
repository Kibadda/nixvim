if vim.g.loaded_plugin_statuscolumn then
  return
end

vim.g.loaded_plugin_statuscolumn = 1

local diagnostic_mapping = {
  { symbol = "E ", highlight = "DiagnosticSignError" },
  { symbol = "W ", highlight = "DiagnosticSignWarn" },
  { symbol = "I ", highlight = "DiagnosticSignInfo" },
  { symbol = "H ", highlight = "DiagnosticSignHint" },
}

local function diagnostics()
  local signs = vim.diagnostic.get(0, { lnum = vim.v.lnum - 1 })

  if #signs == 0 then
    return "  "
  end

  local severity = diagnostic_mapping[signs[1].severity]

  return "%#" .. severity.highlight .. "#" .. severity.symbol .. "%*"
end

local function numbers()
  if vim.v.virtnum > 0 then
    return ""
  end

  if vim.v.relnum ~= 0 then
    return ("%02d"):format(vim.v.relnum)
  end

  return ("%02d"):format(vim.v.lnum)
end

local function git()
  local ns = vim.api.nvim_get_namespaces()["MiniDiffViz"]

  local hl = "@comment"
  if ns then
    local extmarks = vim.api.nvim_buf_get_extmarks(
      0,
      ns,
      { vim.v.lnum - 1, 0 },
      { vim.v.lnum - 1, 0 },
      { details = true }
    )

    if #extmarks > 0 then
      hl = extmarks[1][4].sign_hl_group
    end
  end

  return "%#" .. hl .. "# ▏%*"
end

function Statuscolumn()
  if vim.bo.buftype ~= "" then
    return ""
  end

  return ("%s%%=%s%s"):format(diagnostics(), numbers(), git())
end

vim.o.statuscolumn = "%{%v:lua.Statuscolumn()%}"
