---@type table<number, { buf: number, win: number, row: number, client?: vim.lsp.Client }>
local tokens = {}
local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("LspProgress", { clear = true }),
  callback = function(args)
    local token = args.data.params.token

    if args.file == "end" then
      vim.api.nvim_win_close(tokens[token].win, true)
      for _, t in pairs(tokens) do
        if t.row > tokens[token].row then
          t.row = t.row - 1
        end
      end
      tokens[token] = nil
    else
      if not tokens[token] then
        tokens[token] = {
          buf = vim.api.nvim_create_buf(false, true),
          row = vim.tbl_count(tokens),
          client = vim.lsp.get_client_by_id(args.data.client_id),
        }
      end

      local text = table.concat(
        vim.tbl_filter(function(part)
          return part and part ~= ""
        end, {
          tokens[token].client and tokens[token].client.name .. ":",
          args.data.params.value.title,
          args.data.params.value.percentage and string.format("(%s%%)", args.data.params.value.percentage),
          args.data.params.value.message,
          spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1],
        }),
        " "
      )

      local config = {
        relative = "editor",
        height = 1,
        row = tokens[token].row,
        col = vim.o.columns - #text,
        width = #text,
        style = "minimal",
      }

      vim.api.nvim_buf_set_lines(tokens[token].buf, 0, -1, false, { text })

      if not tokens[token].win then
        tokens[token].win = vim.api.nvim_open_win(tokens[token].buf, false, config)
      else
        vim.api.nvim_win_set_config(tokens[token].win, config)
      end
    end
  end,
})
