local M = {}

local curl = require "plenary.curl"

---@param str string
local function urlencode(str)
  str = str:gsub("\n", "\r\n")
  str = str:gsub("([^%wäöüß %-%_%.%~])", function(c)
    return ("%%%02X"):format(c:byte())
  end)
  str = str:gsub(" ", "+")

  return str
end

local function request(method, url, data)
  local query = {}
  for k, v in pairs(data) do
    if v ~= nil then
      table.insert(query, k .. "=" .. v)
    end
  end

  if #query > 0 then
    url = url .. "?" .. table.concat(query, "&")
  end

  return curl.request {
    method = method,
    url = url,
    headers = {
      ["PRIVATE-TOKEN"] = vim.env.GITLAB_ACCESS_TOKEN,
    },
  }
end

function M.issues()
  local max = 100
  local page = 1
  local all = {}
  local count

  repeat
    local response = request("get", vim.env.GITLAB_PROJECT_URL .. "issues", {
      per_page = max,
      page = page,
    })

    if not response or response.status ~= 200 then
      break
    end

    local issues = vim.json.decode(response.body)

    if not issues then
      break
    end

    count = vim.tbl_count(issues)
    page = page + 1

    vim.list_extend(all, issues)
  until count < max

  return all
end

function M.create(opts)
  if not opts.title or #opts.title == 0 then
    return
  end

  local data = {
    title = urlencode(opts.title),
    description = opts.description and urlencode(opts.description) or nil,
  }

  if opts.labels and #opts.labels > 0 then
    local labels = {}

    for _, v in ipairs(opts.labels) do
      table.insert(labels, urlencode(v))
    end

    data.labels = table.concat(labels, ",")
  end

  return request("post", vim.env.GITLAB_PROJECT_URL .. "issues", data)
end

function M.update(issue, opts)
  local data = {
    title = opts.title and urlencode(opts.title) or nil,
    description = opts.description and urlencode(opts.description) or nil,
    state_event = opts.closed ~= nil and (opts.closed and "close" or "reopen") or nil,
  }

  if opts.labels and #opts.labels > 0 then
    local labels = {}

    for _, v in ipairs(opts.labels) do
      table.insert(labels, urlencode(v))
    end

    data.labels = table.concat(labels, ",")
  end

  if vim.tbl_count(data) == 0 then
    return
  end

  return request("put", issue.api_url, data)
end

function M.delete(issue)
  return request("delete", issue.api_url)
end

function M.labels()
  local response = request("get", vim.env.GITLAB_PROJECT_URL .. "labels", {
    per_page = 100,
  })

  if not response or response.status ~= 200 then
    return {}
  end

  local labels = vim.json.decode(response.body)

  if not labels then
    return {}
  end

  return labels
end

function M.time(issue, time)
  time = time == "" and 0 or tonumber(time)

  if time == 0 then
    return request("post", issue.api_url .. "/reset_spent_time")
  end

  local diff = time - issue.time

  if diff == 0 then
    return
  end

  return request("post", issue.api_url .. "/add_spent_time", {
    duration = diff .. "m",
  })
end

return M
