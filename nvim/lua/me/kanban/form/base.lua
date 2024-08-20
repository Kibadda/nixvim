local Popup = require "nui.popup"

---@diagnostic disable-next-line:undefined-field
local Base = Popup:extend "Base"

function Base:init(options, form)
  self._form = form
  self._props = options

  function self.submit()
    local result = {}
    for _, c in ipairs(form.components) do
      result[c._props.key] = c._props.value
    end

    form.layout:unmount()

    form.submit(result)
  end

  function self.close()
    form.layout:unmount()

    form.close()
  end

  function self.focus(dir)
    return function()
      local index
      for i, c in ipairs(form.components) do
        if c._props.key == self._props.key then
          index = i
          break
        end
      end

      if not index then
        return
      end

      local e
      if dir == "next" then
        e = form.components[index + 1] and form.components[index + 1] or form.components[1]
      else
        e = form.components[index - 1] and form.components[index - 1] or form.components[#form.components]
      end

      if not e then
        return
      end

      vim.api.nvim_set_current_win(e.winid)
    end
  end

  Base.super.init(self, {
    enter = false,
    focusable = true,
    size = {
      width = 80,
      height = self._props.height or 1,
    },
    win_options = {
      winblend = 0,
      winhighlight = "FloatBorder:FloatBorder",
    },
    border = {
      style = "single",
    },
    buf_options = {
      filetype = options.filetype,
    },
  })
end

function Base:mount()
  Base.super.mount(self)

  self:map("i", "<C-c>", self.close)
  self:map("i", "<C-CR>", self.submit)
  self:map("n", "<C-CR>", self.submit)
  self:map("n", "<ESC>", self.close)
  self:map("n", "q", self.close)
  self:map("i", "<TAB>", self.focus "next")
  self:map("n", "<TAB>", self.focus "next")
  self:map("i", "<S-TAB>", self.focus "prev")
  self:map("n", "<S-TAB>", self.focus "prev")

  self:events()
  self:mappings()

  if self._props.focus then
    vim.api.nvim_set_current_win(self.winid)
  end

  vim.api.nvim_win_set_config(
    self.winid,
    vim.tbl_extend("keep", {
      title = " " .. self._props.label .. " ",
      title_pos = "left",
    }, vim.api.nvim_win_get_config(self.winid))
  )

  vim.wo[self.winid].scrolloff = 1
end

function Base:unmount()
  Base.super.unmount(self)
  vim.schedule(function()
    vim.cmd.stopinsert { bang = true }
  end)
end

return Base
