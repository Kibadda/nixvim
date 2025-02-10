if vim.g.loaded_plugin_fake then
  return
end

vim.g.loaded_plugin_fake = 1

vim.g.fake = {
  {
    filetype = "php",
    snippets = {
      debug = "Util::getLogger()->debug($0);",
      getset = "public function get$2(): $3 {\n\treturn \\$this->$1;\n}\n\npublic function set$2($3 \\$$1): void {\n\t\\$this->$1 = \\$$1;\n}",
    },
  },
  {
    filetype = { "javascript", "typescript" },
    snippets = {
      log = "console.log($0);",
    },
  },
  {
    commands = {
      update_input = function(args)
        if not args then
          return
        end

        local cmd = { "nix", "flake" }

        if args.input then
          vim.list_extend(cmd, { "lock", "--update-input", args.input })
        else
          args.input = "all"
          vim.list_extend(cmd, { "update" })
        end

        vim.system(cmd, nil, function(out)
          vim.schedule(function()
            if out.code ~= 0 then
              vim.notify(
                "error when updating input '" .. args.input .. "': " .. (out.stderr or "n/a"),
                vim.log.levels.ERROR
              )
            else
              vim.notify("updated input '" .. args.input .. "'", vim.log.levels.WARN)
            end
          end)
        end)
      end,
    },
  },
  {
    filename = "flake.nix",
    codelenses = function(buf)
      local parser = vim.treesitter.get_parser(buf, "nix")

      if not parser then
        return {}
      end

      local query = vim.treesitter.query.get("nix", "flake_input_url")

      if not query then
        return {}
      end

      local urls = {}

      parser:parse()

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
    codeactions = function(buf)
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

      local parser = vim.treesitter.get_parser(buf, "nix")

      if not parser then
        return inputs
      end

      local query = vim.treesitter.query.get("nix", "flake_input_name")

      if not query then
        return inputs
      end

      parser:parse()

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
}
