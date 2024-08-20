local M = {}

---@class KanbanIssue
---@field id number
---@field title string
---@field group string
---@field project string
---@field web_url string
---@field api_url string
---@field description ?string
---@field time number

---@class KanbanGroup
---@field win number
---@field buf number
---@field name string
---@field line_to_issues table<number, KanbanIssue>
---@field lines string[]

---@class KanbanData
---@field i number
---@field name string
---@field height number
---@field width number
---@field col number
---@field border string

local shown = false
---@type integer?
local tabpage = nil

local windows = require "me.kanban.windows"

function M.create()
  vim.cmd.tabnew()
  local tab = vim.api.nvim_get_current_tabpage()
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].bufhidden = "delete"
  vim.bo[buf].buflisted = false

  windows.create()

  vim.schedule(function()
    windows.issues()
  end)

  return tab
end

function M.toggle()
  if shown then
    M.close()
  else
    M.show()
  end
end

function M.show()
  if shown then
    return
  end

  if not tabpage or not vim.api.nvim_tabpage_is_valid(tabpage) then
    tabpage = M.create()
  end

  vim.api.nvim_set_current_tabpage(tabpage)

  vim.api.nvim_set_current_win(windows.groups[windows.current].win)

  shown = true
end

function M.close()
  if not tabpage or not vim.api.nvim_tabpage_is_valid(tabpage) then
    tabpage = nil

    return
  end

  windows.destroy()

  vim.cmd.tabclose()

  tabpage = nil
  shown = false
end

return M
