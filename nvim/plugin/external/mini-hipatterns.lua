if vim.g.loaded_plugin_mini_hipatterns then
  return
end

vim.g.loaded_plugin_mini_hipatterns = 1

local hipatterns = require "mini.hipatterns"

hipatterns.setup {
  highlighters = {
    hex_color = hipatterns.gen_highlighter.hex_color(),
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "HipatternsTodo" },
    crtx = { pattern = "%f[%w]()CRTX()%f[%W]", group = "HipatternsCrtx" },
  },
}
