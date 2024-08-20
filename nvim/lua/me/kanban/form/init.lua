local Layout = require "nui.layout"
local Input = require "me.kanban.form.input"
local Select = require "me.kanban.form.select"

return function(options)
  local form = {
    components = {},
    submit = options.submit,
    close = options.close,
  }

  table.insert(
    form.components,
    Input({
      label = "Title",
      key = "title",
      height = 3,
      focus = true,
      default = options.fields.title,
      filetype = "markdown",
    }, form)
  )
  table.insert(
    form.components,
    Input({
      label = "Description",
      key = "description",
      height = 10,
      default = options.fields.description,
      filetype = "markdown",
    }, form)
  )
  table.insert(
    form.components,
    Select({
      label = "Labels",
      key = "labels",
      height = 10,
      items = options.fields.labels.items,
      default = options.fields.labels.selected,
      multi = true,
    }, form)
  )

  local total_height = 23

  local components = {}
  for i, component in ipairs(form.components) do
    components[i] = Layout.Box(component, { size = math.ceil(component._props.height / total_height * 100) .. "%" })
  end

  form.layout = Layout({
    position = "50%",
    relative = "editor",
    size = {
      width = 80,
      height = total_height,
    },
  }, Layout.Box(components, { dir = "col" }))

  form.layout:mount()
end
