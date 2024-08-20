local M = {}

local default = {
  date = function()
    return os.date "%Y-%m-%d" --[[@as string]]
  end,
}

local function get_filename()
  local bufname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
  return vim.split(bufname, "%.")[1]
end

local snippets = {
  javascript = {
    log = "console.${0:log}($1);",
  },

  lua = {
    f = "local function ${1:name}($2)\n\t$0\nend",
    m = "function ${1:M}.${2:name}(${3})\n\t$0\nend",
  },

  php = {
    debug = "Util::getLogger($0)->debug($1);",
    warn = "Util::getLogger($0)->warn($1);",
    info = "Util::getLogger($0)->info($1);",
    error = "Util::getLogger($0)->error($1);",

    ["if"] = "if ($1) {\n\t$2\n}",
    ["elseif"] = "else if ($1) {\n\t$2\n}",
    ["else"] = "else {\n\t$0\n}",

    foreach = "foreach ($1 as $2) {\n\t$0\n}",

    try = "try {\n\t$0\n} catch ($1) {\n\t$2\n}",

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

    fun = "${1|public ,protected ,private |}${2|static |}function $3($4)$5 {\n\t$0\n}",

    getset = function()
      return "public function get$1(): $2 {\n\treturn \\$this->$3;\n}\n\npublic function set$1($2 \\$$3): void {\n\t\\$this->$3 = \\$$3;\n}"

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
    end,
  },
}

---@param params cmp.SourceCompletionApiParams
---@param callback function
function M:complete(params, callback)
  local result = {}

  for trigger in pairs(default) do
    table.insert(result, {
      word = trigger,
      label = trigger,
      kind = require("cmp").lsp.CompletionItemKind.Snippet,
    })
  end

  for trigger in pairs(snippets[params.context.filetype] or {}) do
    table.insert(result, {
      word = trigger,
      label = trigger,
      kind = require("cmp").lsp.CompletionItemKind.Snippet,
      data = {
        ft = params.context.filetype,
      },
    })
  end

  callback(result)
end

---@param item lsp.CompletionItem
---@param callback function
function M:execute(item, callback)
  if not item.word then
    return
  end

  ---@type string
  local word = item.word

  local snippet
  if item.data and item.data.ft and snippets[item.data.ft] then
    snippet = snippets[item.data.ft][word]
  else
    snippet = default[word]
  end

  if not snippet then
    return
  end

  if type(snippet) == "function" then
    snippet = snippet()
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  vim.api.nvim_buf_set_text(0, row - 1, col - #word, row - 1, col, {})
  vim.snippet.expand(snippet)
  callback(item)
end

return M
