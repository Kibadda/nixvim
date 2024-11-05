if vim.g.loaded_plugin_fake then
  return
end

vim.g.loaded_plugin_fake = 1

---@type fake.config
vim.g.fake = {
  snippets = {
    filetypes = {
      php = {
        debug = "Util::getLogger()->debug($0);",
        getset = function()
          return "public function get$2(): $3 {\n\treturn \\$this->$1;\n}\n\npublic function set$2($3 \\$$1): void {\n\t\\$this->$1 = \\$$1;\n}"
        end,
      },

      javascript = {
        log = "console.log($0);",
      },
    },
  },
}
