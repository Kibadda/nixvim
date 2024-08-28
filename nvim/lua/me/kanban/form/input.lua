local Base = require "me.kanban.form.base"

local Input = Base:extend "Input"

function Input:init(options, form)
  Input.super.init(self, options, form)
end

function Input:events()
  self:on(
    "BufEnter",
    vim.schedule_wrap(function()
      if self._props.height <= 3 or not self._props.value or #vim.trim(self._props.value) == 0 then
        vim.cmd.startinsert { bang = true }
      else
        vim.cmd.stopinsert { bang = true }
      end
    end)
  )
end

function Input:mappings()
  if self._props.height <= 3 then
    self:map("i", "<CR>", function() end)
  else
    self:map("i", "<CR>", "\n")
  end
end

function Input:mount()
  Input.super.mount(self)

  vim.api.nvim_buf_attach(self.bufnr, false, {
    on_lines = function()
      self._props.value = table.concat(vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false), "\n")
    end,
  })

  if self._props.default then
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, vim.split(self._props.default, "\n"))
  end
end

return Input
