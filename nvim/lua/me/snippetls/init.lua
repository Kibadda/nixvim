local M = {
  ---@type vim.lsp.Client
  client = nil,
}

local config = {
  name = "snippetls",
  cmd = function()
    local message_id = 0

    ---@type vim.lsp.rpc.PublicClient
    return {
      is_closing = function()
        return false
      end,
      terminate = function() end,
      notify = function(method)
        return method == vim.lsp.protocol.Methods.initialized
      end,
      request = function(method, params, callback)
        local function handle(data)
          if data then
            callback(nil, data)
            message_id = message_id + 1
            return true, message_id
          else
            callback(vim.lsp.rpc_response_error(vim.lsp.protocol.ErrorCodes.MethodNotFound))
            return false
          end
        end

        if method == vim.lsp.protocol.Methods.initialize then
          return handle {
            capabilities = {
              completionProvider = {},
            },
          }
        elseif method == vim.lsp.protocol.Methods.textDocument_completion then
          ---@cast params lsp.CompletionParams

          local items = {}

          local bufnr = vim.uri_to_bufnr(params.textDocument.uri)
          local previous_word = vim.api
            .nvim_buf_get_text(bufnr, params.position.line, 0, params.position.line, params.position.character, {})[1]
            :match "(%S*)$"

          local function add_snippet(name, snippet)
            local text = type(snippet) == "function" and snippet() or snippet

            if vim.startswith(text, previous_word) then
              ---@type lsp.CompletionItem
              local item = {
                label = name,
                kind = vim.lsp.protocol.CompletionItemKind.Snippet,
                insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
                insertText = type(snippet) == "function" and snippet() or snippet,
                sortText = "0",
              }

              table.insert(items, item)
            end
          end

          local snippets = require "me.snippetls.snippets"

          for name, snippet in pairs(snippets._) do
            add_snippet(name, snippet)
          end

          local filetype = vim.filetype.match { buf = bufnr }

          if filetype and snippets[filetype] then
            for name, snippet in pairs(snippets[filetype]) do
              add_snippet(name, snippet)
            end
          end

          return handle(items)
        end

        return handle()
      end,
    }
  end,
}

function M.register()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("SnippetLs", { clear = true }),
    callback = function(args)
      if not M.client then
        local id = vim.lsp.start_client(config)

        if id then
          M.client = vim.lsp.get_client_by_id(id)
        end
      end

      if M.client then
        vim.lsp.buf_attach_client(args.buf, M.client.id)
      end
    end,
  })
end

return M
