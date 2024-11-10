if vim.g.loaded_plugin_fake then
  return
end

vim.g.loaded_plugin_fake = 1

---@type fake.config
vim.g.fake = {
  snippets = {
    {
      enabled = function(buf)
        return vim.bo[buf].filetype == "php"
      end,
      snippets = {
        debug = "Util::getLogger()->debug($0);",
        getset = function()
          return "public function get$2(): $3 {\n\treturn \\$this->$1;\n}\n\npublic function set$2($3 \\$$1): void {\n\t\\$this->$1 = \\$$1;\n}"
        end,
      },
    },
    {
      enabled = function(buf)
        return vim.bo[buf].filetype == "javascript"
      end,
      snippets = {
        log = "console.log($0);",
      },
    },
  },
  codelenses = {
    {
      enabled = function(buf)
        return vim.bo[buf].filetype == "nix" and vim.uri_from_bufnr(buf):match "flake%.nix"
      end,
      lenses = function(buf)
        local parser = vim.treesitter.get_parser(buf, "nix")

        if not parser then
          return {}
        end

        local query = vim.treesitter.query.parse(
          "nix",
          [[
            (binding
              attrpath: (attrpath
                attr: (identifier) @_identifier
                (#eq? @_identifier "url")
              )
              expression: (string_expression
                (string_fragment) @url
              )
            )
          ]]
        )

        local urls = {}

        for _, match in query:iter_matches(parser:trees()[1]:root(), buf, 0, -1) do
          for id, nodes in pairs(match) do
            local name = query.captures[id]
            if name == "url" then
              for _, node in ipairs(nodes) do
                local sline, srow, eline, erow = vim.treesitter.get_node_range(node)
                local url = vim.treesitter.get_node_text(node, buf)

                local split = vim.split(url, "/")

                ---@type lsp.CodeLens
                local lens = {
                  range = {
                    start = {
                      line = sline,
                      character = srow,
                    },
                    ["end"] = {
                      line = eline,
                      character = erow,
                    },
                  },
                  command = {
                    title = "open",
                    command = "open_url",
                    arguments = {
                      url = split[1]:gsub("github%:", "https://github.com/") .. "/" .. split[2],
                    },
                  },
                }

                table.insert(urls, lens)
              end
            end
          end
        end

        return urls
      end,
    },
  },
  commands = {
    update_input = function(args)
      if not args then
        return
      end

      local cmd = { "nix", "flake", "update" }

      if args.input then
        table.insert(cmd, args.input)
      end

      vim.system(cmd, nil, function(out)
        vim.schedule(function()
          if out.stderr ~= "" then
            vim.notify("error when updating input '" .. args.input .. "': " .. out.stderr, vim.log.levels.ERROR)
          else
            vim.notify("updated input '" .. args.input .. "'", vim.log.levels.WARN)
          end
        end)
      end)
    end,
  },
  codeactions = {
    {
      enabled = function(buf)
        return vim.bo[buf].filetype == "nix" and vim.uri_from_bufnr(buf):match "flake%.nix"
      end,
      codeactions = function(buf)
        local parser = vim.treesitter.get_parser(buf, "nix")

        if not parser then
          return {}
        end

        local query = vim.treesitter.query.parse(
          "nix",
          [[
            (binding
              (attrpath
                (identifier) @_inputs
                (#eq? @_inputs "inputs")
              )
              (attrset_expression
                (binding_set
                  (binding
                    (attrpath
                      .
                      (identifier) @input)
                    )
                  )
                )
              )
          ]]
        )

        ---@type lsp.CodeAction[]
        local inputs = {
          {
            title = "update all inputs",
            command = {
              title = "update all inputs",
              command = "update_input",
              arguments = {},
            },
          },
        }

        for _, match in query:iter_matches(parser:trees()[1]:root(), buf, 0, -1) do
          for id, nodes in pairs(match) do
            local name = query.captures[id]
            if name == "input" then
              for _, node in ipairs(nodes) do
                local input = vim.treesitter.get_node_text(node, buf)

                ---@type lsp.CodeAction
                local action = {
                  title = "update input '" .. input .. "'",
                  command = {
                    title = "update input",
                    command = "update_input",
                    arguments = {
                      input = input,
                    },
                  },
                }

                table.insert(inputs, action)
              end
            end
          end
        end

        return inputs
      end,
    },
  },
}
