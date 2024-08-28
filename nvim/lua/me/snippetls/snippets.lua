local function get_filename()
  local bufname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
  return vim.split(bufname, "%.")[1]
end

return {
  _ = {
    date = function()
      return os.date "%Y-%m-%d"
    end,
  },

  php = {
    debug = "Util::getLogger($0)->debug($1);",
    warn = "Util::getLogger($0)->warn($1);",
    info = "Util::getLogger($0)->info($1);",
    error = "Util::getLogger($0)->error($1);",

    class = function()
      return string.format("${1|abstract ,final |}class %s$2 {\n\t$0\n}", get_filename())
    end,
    enum = function()
      return string.format("enum %s$1 {\n\t$0\n}", get_filename())
    end,
    interface = function()
      return string.format("interface %s$1 {\n\t$0\n}", get_filename())
    end,
    trait = function()
      return string.format("trait %s$1 {\n\t$0\n}", get_filename())
    end,

    getset = function()
      -- local property
      --
      -- vim.ui.input({
      --   prompt = "Property name: ",
      -- }, function(choice)
      --   property = choice
      -- end)
      --
      -- if not property or property == "" then
      --   return ""
      -- end
      --
      -- return string.format(
      --   "public function get%s(): $1 {\n\treturn \\$this->%s;\n}\n\npublic function set%s($1 \\$%s): void {\n\t\\$this->%s = \\$%s;\n}",
      --   property:gsub("^%l", string.upper),
      --   property,
      --   property:gsub("^%l", string.upper),
      --   property,
      --   property,
      --   property
      -- )

      return "public function get$1(): $2 {\n\treturn \\$this->$3;\n}\n\npublic function set$1($2 \\$$3): void {\n\t\\$this->$3 = \\$$3;\n}"
    end,
  },

  javascript = {
    log = "console.${0:log}($1);",
  },
}
