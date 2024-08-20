local Base = require "me.kanban.form.base"

local Select = Base:extend "Select"

local ns = vim.api.nvim_create_namespace "FormSelect"

function Select:init(options, form)
  Select.super.init(self, options, form)

  self._props.value = {}
end

function Select:events()
  self:on(
    "BufEnter",
    vim.schedule_wrap(function()
      vim.cmd.stopinsert { bang = true }
    end)
  )
end

function Select:highlight()
  for _, extmark in ipairs(vim.api.nvim_buf_get_extmarks(self.bufnr, ns, 0, -1, {})) do
    vim.api.nvim_buf_del_extmark(self.bufnr, ns, extmark[1])
  end

  local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)

  for row, line in ipairs(lines) do
    if vim.tbl_contains(self._props.value, line) then
      vim.api.nvim_buf_set_extmark(self.bufnr, ns, row - 1, 0, {
        end_col = #line,
        end_line = row - 1,
        hl_group = "Keyword",
      })
    end
  end
end

function Select:mappings()
  self:map("n", "<SPACE>", function()
    local row = vim.api.nvim_win_get_cursor(self.winid)[1]
    local line = vim.api.nvim_buf_get_lines(self.bufnr, row - 1, row, false)[1]

    if self._props.multi then
      local index
      for i, value in ipairs(self._props.value) do
        if value == line then
          index = i
          break
        end
      end

      if index then
        table.remove(self._props.value, index)
      else
        table.insert(self._props.value, line)
      end
    else
      self._props.value = { line }
    end

    self:highlight()
  end)
end

function Select:mount()
  Select.super.mount(self)

  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self._props.items)

  if self._props.default then
    self._props.value = self._props.default

    self:highlight()
  end
end

return Select
