local M = {
  ---@type KanbanIssue[]
  issues = {},
  labels = {},
}

local function get_issues(groups)
  local api = require "me.kanban.api"

  local all = api.issues()

  for _, issue in ipairs(all) do
    local group = "Open"
    local project = "Cortex"

    if issue.state == "opened" then
      for _, label in ipairs(issue.labels) do
        if vim.tbl_contains(groups, label) then
          group = label
        else
          project = label
        end
      end
    elseif issue.state == "closed" then
      group = "Closed"
      for _, label in ipairs(issue.labels) do
        project = label
      end
    end

    table.insert(M.issues, {
      id = issue.iid,
      title = issue.title,
      group = group,
      project = project,
      web_url = issue.web_url,
      api_url = issue._links.self,
      description = issue.description ~= vim.NIL and issue.description or nil,
      time = issue.time_stats.total_time_spent ~= vim.NIL and math.floor(issue.time_stats.total_time_spent / 60) or 0,
    })
  end

  table.sort(M.issues, function(a, b)
    return b.id < a.id
  end)
end

function M.get_issues(groups)
  if #M.issues == 0 then
    get_issues(groups)
  end

  return M.issues
end

local function get_labels(groups)
  local api = require "me.kanban.api"

  local all = api.labels()

  for _, label in ipairs(all) do
    if not vim.tbl_contains(groups, label.name) then
      table.insert(M.labels, label.name)
    end
  end

  table.sort(M.labels, function(a, b)
    return a < b
  end)
end

function M.get_labels(groups)
  if #M.labels == 0 then
    get_labels(groups)
  end

  return M.labels
end

return M
