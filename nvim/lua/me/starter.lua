if vim.fn.argc() > 0 then
  return
end

local group = vim.api.nvim_create_augroup("StarterScreen", { clear = true })
local ns = vim.api.nvim_create_namespace "StarterScreen"
local box_width = #"│"

local settings = { timeoutlen = 1, listchars = "", cursorline = false }

local function setup_options()
  for key in pairs(settings) do
    settings[key], vim.o[key] = vim.o[key], settings[key]
  end
end

local function restore_options()
  for key, value in pairs(settings) do
    vim.o[key] = value
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function()
    setup_options()

    local header = require("me.data.weekdays").get()
    local prompt_offset = #header + 6
    local list_offset = 2

    local sessions = require("session").list()
    local selected = 1
    local shown = #sessions
    local prompt = ""

    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].modifiable = false

    local function set_lines()
      local extmarks = {}
      local width = vim.fn.strdisplaywidth(header[1])
      local lines = {}

      table.insert(lines, "┌" .. ("─"):rep(width + 4) .. "┐")
      table.insert(lines, "│" .. (" "):rep(width + 4) .. "│")
      for _, line in ipairs(header) do
        table.insert(lines, "│  " .. line .. "  │")
        table.insert(extmarks, { line = #lines - 1, col = box_width, end_col = box_width + #line, hl = "Red" })
      end
      local date = os.date "%d.%m.%Y"
      local date_offset = (width - #date) / 2
      table.insert(
        lines,
        "│  " .. (" "):rep(math.floor(date_offset)) .. date .. (" "):rep(math.ceil(date_offset)) .. "  │"
      )
      local v = vim.version()
      local version = ("NVIM v%d.%d.%d-%s"):format(v.major, v.minor, v.patch, v.prerelease)
      local version_offset = (width - #version) / 2
      table.insert(
        lines,
        "│  " .. (" "):rep(math.floor(version_offset)) .. version .. (" "):rep(math.ceil(version_offset)) .. "  │"
      )
      table.insert(lines, "│" .. (" "):rep(width + 4) .. "│")
      table.insert(lines, "├" .. ("─"):rep(width + 4) .. "┤")
      table.insert(lines, "│  " .. prompt .. (" "):rep(width - #prompt) .. "  │")
      table.insert(lines, "├" .. ("─"):rep(width + 4) .. "┤")

      local matches = { sessions }
      if #prompt > 0 then
        matches = vim.fn.matchfuzzypos(sessions, prompt)
      end
      shown = #matches[1]

      if selected > shown then
        selected = math.max(shown, 1)
      end

      for i = 1, #matches[1] do
        local prefix = "  "
        if i == selected then
          prefix = "> "
          table.insert(extmarks, { line = #lines, col = box_width, end_col = box_width + 1, hl = "Blue" })
        end
        if matches[2] then
          for _, pos in ipairs(matches[2][i]) do
            table.insert(
              extmarks,
              { line = #lines, col = box_width + pos + 2, end_col = box_width + pos + 3, hl = "Bold" }
            )
          end
        end
        table.insert(lines, "│" .. prefix .. matches[1][i] .. (" "):rep(width - #matches[1][i]) .. "  │")
      end

      for _ = 1, #sessions - shown do
        table.insert(lines, "│" .. (" "):rep(width + 4) .. "│")
      end

      table.insert(lines, "└" .. ("─"):rep(width + 4) .. "┘")

      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.bo[buf].modifiable = false
      vim.bo[buf].modified = false
      vim.api.nvim_win_set_cursor(0, { prompt_offset + 1, 5 + #prompt })

      for _, extmark in ipairs(extmarks) do
        vim.api.nvim_buf_set_extmark(buf, ns, extmark.line, extmark.col, {
          end_line = extmark.line,
          end_col = extmark.end_col,
          hl_group = extmark.hl,
        })
      end
    end

    local function update_prompt(data)
      if type(data) == "string" then
        prompt = prompt .. data
      elseif type(data) == "number" then
        prompt = prompt:sub(1, #prompt - data)
      end
    end

    set_lines()

    local function map(lhs, rhs)
      vim.keymap.set("n", lhs, rhs, { buffer = buf })
    end

    for key in ("abcdefghijklmnopqrstuvwxyz"):gmatch "." do
      map(key, function()
        update_prompt(key)
        set_lines()
      end)
    end

    map("<BS>", function()
      update_prompt(1)
      set_lines()
    end)
    map("<C-w>", function()
      update_prompt(#prompt)
      set_lines()
    end)
    map("<CR>", function()
      local line = vim.api.nvim_buf_get_lines(
        buf,
        prompt_offset + list_offset + selected - 1,
        prompt_offset + list_offset + selected,
        false
      )[1]

      local session = line:match "> (%S+)"

      if session then
        require("session").load(session)
      end
    end)
    map("<C-j>", function()
      if selected == shown then
        selected = 1
      else
        selected = selected + 1
      end
      set_lines()
    end)
    map("<C-k>", function()
      if selected == 1 then
        selected = shown
      else
        selected = selected - 1
      end
      set_lines()
    end)

    vim.api.nvim_create_autocmd("BufLeave", {
      group = group,
      buffer = buf,
      callback = restore_options,
    })
  end,
})
