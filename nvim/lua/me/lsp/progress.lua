---@type table<integer, { win: integer, buf: integer, row: integer, client: vim.lsp.Client? }>
local progress_windows = {}

local function show_progress(win, buf, data)
  local ttext = {}

  local client
  if not progress_windows[data.params.token] then
    client = vim.lsp.get_client_by_id(data.client_id)
  else
    client = progress_windows[data.params.token].client
  end

  if data.params.token and client then
    table.insert(ttext, client.name .. ":")
  end

  if data.params.value.title then
    table.insert(ttext, data.params.value.title)
  end

  if data.params.value.percentage and data.params.value.percentage > 0 then
    table.insert(ttext, ("(%s%%)"):format(data.params.value.percentage))
  end

  if data.params.value.message then
    table.insert(ttext, data.params.value.message)
  end

  local text = table.concat(ttext, " ")
  local text_width = string.len(text) + 4
  local col = vim.o.columns - text_width

  local row
  if progress_windows[data.params.token] then
    row = progress_windows[data.params.token].row
  else
    row = vim.tbl_count(progress_windows)
  end

  ---@type vim.api.keyset.win_config
  local win_options = {
    relative = "editor",
    height = 1,
    row = row,
    col = col,
    width = text_width,
  }

  if not win or not vim.api.nvim_win_is_valid(win) then
    win = vim.api.nvim_open_win(buf, false, win_options)

    progress_windows[data.params.token] = {
      win = win,
      buf = buf,
      row = row,
      client = client,
    }
  else
    vim.api.nvim_win_set_config(win, win_options)
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
end

vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("LspProgress", { clear = true }),
  callback = function(args)
    local token = args.data.params.token

    if args.file == "begin" then
      show_progress(nil, vim.api.nvim_create_buf(false, true), args.data)
    elseif args.file == "report" then
      if progress_windows[token] then
        show_progress(progress_windows[token].win, progress_windows[token].buf, args.data)
      end
    elseif args.file == "end" then
      if progress_windows[token] then
        vim.api.nvim_win_close(progress_windows[token].win, false)
        local row = progress_windows[token].row
        progress_windows[token] = nil
        for _, r in pairs(progress_windows) do
          if r.row < row then
            r.row = r.row - 1
          end
        end
      end
    end
  end,
})
