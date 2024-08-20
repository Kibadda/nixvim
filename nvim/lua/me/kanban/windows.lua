local M = {
  ---@type KanbanGroup[]
  groups = {},
  mappings = {},
  current = nil,
  labels = {},
}

local groups = {
  "Montag",
  "Dienstag",
  "Mittwoch",
  "Donnerstag",
  "Freitag",
}

local ns = vim.api.nvim_create_namespace "Kanban"

local api = require "me.kanban.api"

local highlights = {
  Border = { name = "KanbanBorder", hl = { fg = vim.g.colors.white } },
  BorderWeek = { name = "KanbanBorderWeek", hl = { fg = vim.g.colors.cyan } },
  BorderCurrent = { name = "KanbanBorderCurrent", hl = { fg = vim.g.colors.red } },
  Title = { name = "KanbanTitle", hl = { fg = vim.g.colors.red } },
  Time = { name = "KanbanTime", hl = { fg = vim.g.colors.blue } },
}

for _, hl in pairs(highlights) do
  vim.api.nvim_set_hl(0, hl.name, hl.hl)
end

---@param data KanbanData
---@return KanbanGroup
local function create_group(data)
  local buf = vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    border = "single",
    title = " " .. data.name .. " ",
    title_pos = "center",
    height = data.height,
    width = data.width,
    row = 1,
    col = data.col,
  })

  vim.wo[win].signcolumn = "no"
  vim.wo[win].statuscolumn = nil
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].cursorline = false
  vim.wo[win].fillchars = "eob: "
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].showbreak = "  "
  vim.wo[win].winhighlight = "FloatBorder:" .. data.border

  vim.bo[buf].modifiable = false

  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
  end

  map("gH", function()
    vim.ui.open(vim.env.GITLAB_BOARD_URL)
  end, "Open Board")

  map("q", function()
    require("me.kanban").close()
  end, "Close")

  map("h", function()
    vim.api.nvim_set_current_win(M.groups[data.i > 1 and data.i - 1 or #M.groups].win)
  end, "Focus Prev Group")

  map("l", function()
    vim.api.nvim_set_current_win(M.groups[data.i < #M.groups and data.i + 1 or 1].win)
  end, "Focus Next Group")

  map("j", function()
    local lines = M.groups[data.i].lines

    local row = vim.api.nvim_win_get_cursor(win)[1]

    for i = row + 1, #lines do
      if lines[i]:find "^ - " then
        vim.api.nvim_win_set_cursor(win, { i, 1 })
        break
      end
    end
  end, "Focus Next Issue")

  map("k", function()
    local lines = M.groups[data.i].lines

    local row = vim.api.nvim_win_get_cursor(win)[1]

    for i = row - 1, 1, -1 do
      if lines[i]:find "^ - " then
        vim.api.nvim_win_set_cursor(win, { i, 1 })
        break
      end
    end
  end, "Focus Prev Issue")

  map("c", function()
    require "me.kanban.form" {
      fields = {
        labels = {
          items = require("me.kanban.cache").get_labels(groups),
        },
      },
      submit = function(result)
        if vim.tbl_contains(groups, data.name) then
          result.labels = result.labels or {}
          table.insert(result.labels, data.name)
        end

        api.create(result)

        vim.api.nvim_set_current_win(win)

        vim.schedule(function()
          M.issues(true)
        end)
      end,
      close = function()
        vim.api.nvim_set_current_win(win)
      end,
    }
  end)

  ---@param callback function
  local function with_issue(callback)
    return function()
      local row = vim.api.nvim_win_get_cursor(win)[1]

      local issue = M.groups[data.i].line_to_issues[row]

      if issue then
        callback(issue)
      end
    end
  end

  map(
    "o",
    with_issue(function(issue)
      vim.ui.open(issue.web_url)
    end),
    "Open In Browser"
  )

  map(
    "e",
    with_issue(function(issue)
      require "me.kanban.form" {
        fields = {
          title = issue.title,
          description = issue.description,
          labels = {
            items = require("me.kanban.cache").get_labels(groups),
            selected = {
              issue.project,
            },
          },
        },
        submit = function(result)
          if vim.tbl_contains(groups, data.name) then
            result.labels = result.labels or {}
            table.insert(result.labels, data.name)
          end

          api.update(issue, result)

          vim.api.nvim_set_current_win(win)

          vim.schedule(function()
            M.issues(true)
          end)
        end,
        close = function()
          vim.api.nvim_set_current_win(win)
        end,
      }
    end),
    "Edit Issue"
  )

  map(
    "d",
    with_issue(function(issue)
      if vim.fn.confirm("Delete issue '" .. issue.title .. "'?", "&Yes\n&No", 2) == 1 then
        api.delete(issue)

        vim.schedule(function()
          M.issues(true)
        end)
      end
    end),
    "Delete Issue"
  )

  map(
    "m",
    with_issue(function(issue)
      local gs = vim.deepcopy(groups)

      table.insert(gs, 1, "Open")
      table.insert(gs, "Closed")

      vim.ui.select(gs, { prompt = "Move to: " }, function(choice)
        if not choice then
          return
        end

        local closed
        local labels = { issue.project }
        if choice == "Open" then
          closed = false
        elseif choice == "Closed" then
          closed = true
        else
          table.insert(labels, choice)
        end

        api.update(issue, { closed = closed, labels = labels })

        vim.schedule(function()
          M.issues(true)
        end)
      end)
    end),
    "Move"
  )

  map(
    "H",
    with_issue(function(issue)
      local n = data.i > 0 and data.i - 1 or #M.groups

      local opts = {
        closed = n == #M.groups,
        labels = { issue.project },
      }

      if n ~= 1 and n ~= #M.groups then
        table.insert(opts.labels, M.groups[n].name)
      end

      api.update(issue, opts)

      vim.schedule(function()
        M.issues(true)
      end)
    end),
    "Move To Prev Group"
  )

  map(
    "L",
    with_issue(function(issue)
      local n = data.i < #M.groups and data.i + 1 or 1

      local opts = {
        closed = n == #M.groups,
        labels = { issue.project },
      }

      if n ~= 1 and n ~= #M.groups then
        table.insert(opts.labels, M.groups[n].name)
      end

      api.update(issue, opts)

      vim.schedule(function()
        M.issues(true)
      end)
    end),
    "Move To Next Group"
  )

  map(
    "t",
    with_issue(function(issue)
      vim.ui.input({ prompt = "Time in minutes: ", default = issue.time }, function(input)
        if not input then
          return
        end

        api.time(issue, input)

        vim.schedule(function()
          M.issues(true)
        end)
      end)
    end),
    "Edit Time"
  )

  return {
    win = win,
    buf = buf,
    name = data.name,
    line_to_issues = {},
    lines = {},
  }
end

function M.create()
  local gs = vim.deepcopy(groups)

  table.insert(gs, 1, "Open")
  table.insert(gs, "Closed")

  M.current = tonumber(os.date "%w") + 1

  local amount = #gs

  local height = vim.o.lines - 5
  local width = math.floor(vim.o.columns / amount)
  local remaining = vim.o.columns % amount

  for i, group in ipairs(gs) do
    local col_offset = 0
    local width_offset = 0
    if i >= amount - remaining + 1 then
      col_offset = (i - (amount - remaining + 1))
      width_offset = 1
    end

    local border = highlights.Border.name
    if i == M.current then
      border = highlights.BorderCurrent.name
    elseif vim.tbl_contains(groups, group) then
      border = highlights.BorderWeek.name
    end

    M.groups[i] = create_group {
      i = i,
      name = group,
      height = height,
      width = width + width_offset - 2,
      col = (i - 1) * width + col_offset,
      border = border,
    }

    M.mappings[group] = i
  end
end

function M.destroy()
  for _, group in pairs(M.groups) do
    vim.api.nvim_win_close(group.win, true)
  end
end

function M.remove()
  for _, group in pairs(M.groups) do
    for _, extmark in ipairs(vim.api.nvim_buf_get_extmarks(group.buf, ns, 0, -1, {})) do
      vim.api.nvim_buf_del_extmark(group.buf, ns, extmark[1])
    end

    vim.bo[group.buf].modifiable = true
    vim.api.nvim_buf_set_lines(group.buf, 0, -1, false, {})
    vim.bo[group.buf].modifiable = false

    group.line_to_issues = {}
    group.lines = {}
  end
end

function M.issues(force)
  local cache = require "me.kanban.cache"

  if force then
    M.remove()

    cache.issues = {}
  end

  ---@type table<string, table<string, integer[]>>
  local labels_per_group = {}

  local all_issues = cache.get_issues(groups)

  for i, issue in ipairs(all_issues) do
    labels_per_group[issue.group] = labels_per_group[issue.group] or {}

    labels_per_group[issue.group][issue.project] = labels_per_group[issue.group][issue.project] or {}
    table.insert(labels_per_group[issue.group][issue.project], i)
  end

  for group_name, projects in pairs(labels_per_group) do
    if M.mappings[group_name] then
      local group = M.groups[M.mappings[group_name]]

      local lines = {}
      ---@type {line: integer, start_col: integer, end_col: integer, hl: string}[]
      local extmarks = {}

      local p = vim.tbl_keys(projects)
      table.sort(p)

      for _, project in ipairs(p) do
        table.insert(lines, project)
        table.insert(extmarks, {
          line = #lines - 1,
          start_col = 0,
          end_col = #project,
          hl = highlights.Title.name,
        })

        for _, i in ipairs(labels_per_group[group_name][project]) do
          local line = " - " .. all_issues[i].title

          if all_issues[i].time > 0 then
            local time = " " .. all_issues[i].time .. "m"

            table.insert(extmarks, {
              line = #lines,
              start_col = #line,
              end_col = #line + #time,
              hl = highlights.Time.name,
            })

            line = line .. time
          end

          table.insert(lines, line)
          group.line_to_issues[#lines] = all_issues[i]
        end

        table.insert(lines, "")
      end

      group.lines = lines
      vim.bo[group.buf].modifiable = true
      vim.api.nvim_buf_set_lines(group.buf, 0, -1, false, lines)
      vim.bo[group.buf].modifiable = false

      if #lines > 0 then
        vim.api.nvim_win_set_cursor(group.win, { 2, 1 })
      end

      for _, extmark in ipairs(extmarks) do
        vim.api.nvim_buf_set_extmark(group.buf, ns, extmark.line, extmark.start_col, {
          end_row = extmark.line,
          end_col = extmark.end_col,
          hl_group = extmark.hl,
        })
      end
    end
  end
end

return M
