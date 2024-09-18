if vim.g.loaded_plugin_statusline then
  return
end

vim.g.loaded_plugin_statusline = 1

local mode_mapping = {
  n = { text = "NORMAL", hl = "StatusLineNormal" },
  v = { text = "VISUAL", hl = "StatusLineVisual" },
  V = { text = "VISUAL", hl = "StatusLineVisual" },
  ["\22"] = { text = "VISUAL", hl = "StatusLineVisual" },
  s = { text = "SELECT", hl = "StatusLineSelect" },
  S = { text = "SELECT", hl = "StatusLineSelect" },
  ["\19"] = { text = "SELECT", hl = "StatusLineSelect" },
  i = { text = "INSERT", hl = "StatusLineInsert" },
  R = { text = "REPLACE", hl = "StatusLineReplace" },
  c = { text = "COMMAND", hl = "StatusLineCommand" },
  r = { text = "CONFIRM", hl = "StatusLineConfirm" },
  ["!"] = { text = "TERMINAL", hl = "StatusLineTerminal" },
  t = { text = "TERMINAL", hl = "StatusLineTerminal" },
}

local function mode()
  local mod = mode_mapping[vim.fn.mode()]

  return {
    section = "%#" .. mod.hl .. "# " .. mod.text .. " %#" .. mod.hl .. "Separator#%* ",
    length = #mod.text + 4,
  }
end

local function git()
  local function diff()
    local status = vim.b.git or {}

    local added = status.added or 0
    local removed = status.removed or 0
    local changed = status.changed or 0

    return {
      section = " %#Added#+" .. added .. "%#Removed#-" .. removed .. "%#Changed#~" .. changed,
      length = tostring(added):len() + tostring(removed):len() + tostring(changed):len() + 3,
    }
  end

  local data = {
    section = "%#StatusLineGitHead# " .. vim.g.git_head,
    length = #vim.g.git_head + 5,
    priority = 5,
  }

  if vim.g.git_head ~= "no git" then
    local diff_data = diff()

    local git_status = require("git.status").status()

    data.section = data.section .. diff_data.section .. "%*" .. (git_status ~= "" and " " or "") .. git_status
    data.length = data.length + diff_data.length
  end

  data.section = data.section .. " %#" .. mode_mapping[vim.fn.mode()].hl .. "Separator#%* "

  return data
end

local function diagnostics()
  local d = vim.diagnostic.count(0)

  local error = d[1] and (d[1] < 10 and d[1] or "#") or 0
  local warning = d[2] and (d[2] < 10 and d[2] or "#") or 0
  local info = d[3] and (d[3] < 10 and d[3] or "#") or 0
  local hint = d[4] and (d[4] < 10 and d[4] or "#") or 0

  return {
    section = "%#DiagnosticSignError#E"
      .. error
      .. "%#DiagnosticSignWarn#W"
      .. warning
      .. "%#DiagnosticSignInfo#I"
      .. info
      .. "%#DiagnosticSignHint#H"
      .. hint
      .. " %#"
      .. mode_mapping[vim.fn.mode()].hl
      .. "Separator#%* ",
    length = tostring(error):len() + tostring(warning):len() + tostring(info):len() + tostring(hint):len() + 8,
    priority = 3,
  }
end

local function filename()
  local fname = vim.fs.basename(vim.api.nvim_buf_get_name(0))

  return {
    section = fname,
    length = fname:len(),
  }
end

local function filetype()
  local ok, devicons = pcall(require, "nvim-web-devicons")

  local icon, hl

  local data = {
    section = vim.bo.filetype,
    length = #vim.bo.filetype,
  }

  if ok then
    icon, hl = devicons.get_icon_by_filetype(vim.bo.filetype)

    if icon then
      data.section = "%#" .. hl .. "#" .. icon .. "%* " .. data.section
      data.length = data.length + icon:len() + 1
    end
  end

  return data
end

local function clients()
  local names = {}

  for _, client in pairs(vim.lsp.get_clients { bufnr = 0 }) do
    table.insert(names, client.name .. "[" .. client.id .. "]")
  end

  local ok, conform = pcall(require, "conform")

  if ok then
    for _, source in ipairs(conform.list_formatters(0)) do
      table.insert(names, source.name)
    end
  end

  local list = #names > 0 and table.concat(names, ", ") or "LS inactive"

  return {
    section = " %#" .. mode_mapping[vim.fn.mode()].hl .. "Separator# %#StatusLineClients#" .. list .. "%*",
    length = list:len() + 4,
    priority = 2,
  }
end

local function format()
  return {
    section = " %#"
      .. mode_mapping[vim.fn.mode()].hl
      .. "Separator# %#"
      .. (vim.g.AutoFormat == 1 and "StatusLineFormatOn" or "StatusLineFormatOff")
      .. "#"
      .. (vim.g.AutoFormat == 1 and "✓" or "✗")
      .. "%*",
    length = 5,
    priority = 1,
  }
end

local function position()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local total = vim.api.nvim_buf_line_count(0)
  local percentage

  if cursor[1] == 1 then
    percentage = "Top"
  elseif cursor[1] == total then
    percentage = "Bot"
  else
    percentage = ("%02d"):format(math.floor((cursor[1] / total) * 100)) .. "%%"
  end

  local ruler = (" %03d:%03d | %s "):format(cursor[1], cursor[2] + 1, percentage)

  local mod = mode_mapping[vim.fn.mode()]

  return {
    section = " %#" .. mod.hl .. "Separator#%#" .. mod.hl .. "#" .. ruler .. "%*",
    length = ruler:len() + 2,
  }
end

function Statusline()
  local data = {
    mode(),
    git(),
    diagnostics(),
    filename(),
    filetype(),
    clients(),
    format(),
    position(),
  }

  local function calculate(level)
    level = level or 0

    local length = 0
    local max_priority = 0

    for _, d in ipairs(data) do
      max_priority = math.max(max_priority, d.priority or 0)
      if not d.priority or d.priority > level then
        length = length + d.length
      end
    end

    if length > vim.o.columns and level ~= max_priority + 1 then
      return calculate(level + 1)
    end

    return vim.tbl_map(function(d)
      return (not d.priority or d.priority > level) and d.section or ""
    end, data)
  end

  return ("%s%s%s%s%%=%s%s%s%s"):format(unpack(calculate()))
end

vim.o.statusline = "%{%v:lua.Statusline()%}"
