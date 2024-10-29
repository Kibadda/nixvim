if vim.g.loaded_plugin_winbar then
  return
end

vim.g.loaded_plugin_winbar = 1

local function icon()
  local ok, devicons = pcall(require, "nvim-web-devicons")

  if not ok then
    return ""
  end

  local ico, hl = devicons.get_icon_by_filetype(vim.bo.filetype)

  if not ico then
    return ""
  end

  return "%#" .. hl .. "#" .. ico .. "%* "
end

local function filepath(path)
  local filename = vim.fs.basename(path)
  path = vim.fs.dirname(path)

  if path:sub(1, 1) ~= "/" and path ~= "." then
    path = "./" .. path
  end

  return path .. "/%#WinBarFilename#" .. filename .. "%*"
end

local function modified()
  return vim.bo.modified and " %#WinBarModified#●︎%*" or ""
end

function Winbar()
  if vim.bo.buftype ~= "" then
    return ""
  end

  local path = vim.fn.fnamemodify(vim.fn.expand "%", ":.")

  if path:len() == 0 then
    return ""
  end

  return (" %s%s:%%L%s"):format(icon(), filepath(path), modified())
end

vim.o.winbar = "%{%v:lua.Winbar()%}"
