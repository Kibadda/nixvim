local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local clear = vim.api.nvim_clear_autocmds
local symbols = require "me.data.symbols"

local groups = {
  highlight = augroup("LspAttachHighlight", { clear = false }),
  codelens = augroup("LspAttachCodelens", { clear = false }),
  inlay = augroup("LspAttachInlay", { clear = false }),
  completion = augroup("LspAttachCompletion", { clear = false }),
}

autocmd("LspAttach", {
  group = augroup("LspAttach", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if not client then
      return
    end

    ---@param opts vim.lsp.LocationOpts.OnList
    local function on_list(opts)
      if #opts.items == 0 then
        vim.notify("No location found", vim.log.levels.WARN)
      elseif #opts.items == 1 then
        vim.lsp.util.jump_to_location(opts.items[1].user_data, client.offset_encoding)
      else
        require("mini.pick").registry.lsp {
          title = "Lsp " .. vim.split(opts.title, " ")[1],
          items = opts.items,
        }
      end
    end

    local methods = vim.lsp.protocol.Methods

    ---@type table<string, { method?: string, lhs?: string, rhs?: function, mode?: string, desc?: string, extra?: function, expr?: boolean }>
    local maps = {
      {
        method = methods.textDocument_definition,
        lhs = "gd",
        rhs = function()
          vim.lsp.buf.definition { on_list = on_list }
        end,
        desc = "Definition",
      },
      {
        method = methods.textDocument_references,
        lhs = "grr",
        rhs = function()
          vim.lsp.buf.references({
            includeDeclaration = false,
          }, { on_list = on_list })
        end,
        desc = "References",
      },
      {
        method = methods.textDocument_implementation,
        lhs = "gI",
        rhs = function()
          vim.lsp.buf.implementation { on_list = on_list }
        end,
        desc = "Implementations",
      },
      {
        method = methods.textDocument_declaration,
        lhs = "gD",
        rhs = function()
          vim.lsp.buf.declaration { on_list = on_list }
        end,
        desc = "Declaration",
      },
      {
        method = methods.textDocument_documentSymbol,
        lhs = "gs",
        rhs = function()
          vim.lsp.buf.document_symbol { on_list = on_list }
        end,
        desc = "Document Symbols",
      },
      {
        method = methods.workspace_symbol,
        lhs = "gS",
        rhs = function()
          vim.lsp.buf.workspace_symbol(nil, { on_list = on_list })
        end,
        desc = "Workspace Symbols",
      },
      {
        method = methods.textDocument_codeLens,
        lhs = "grl",
        rhs = function()
          vim.lsp.codelens.run()
        end,
        desc = "Run Codelens",
        extra = function()
          clear { group = groups.codelens, buffer = bufnr }
          autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            group = groups.codelens,
            buffer = bufnr,
            callback = function()
              vim.lsp.codelens.refresh { bufnr = bufnr }
            end,
          })
        end,
      },
      {
        method = methods.textDocument_documentHighlight,
        extra = function()
          clear { group = groups.highlight, buffer = bufnr }
          autocmd({ "CursorHold", "InsertLeave", "BufEnter" }, {
            group = groups.highlight,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
          })
          autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
            group = groups.highlight,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
          })
        end,
      },
      {
        method = methods.textDocument_inlayHint,
        lhs = "gri",
        rhs = function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }, { bufnr = bufnr })
        end,
        desc = "Toggle Inlay Hint",
      },
      {
        method = methods.textDocument_formatting,
        extra = function()
          if not vim.b[bufnr].formatter then
            vim.b[bufnr].formatter = vim.lsp.buf.format
          end
        end,
      },
      {
        method = methods.textDocument_completion,
        extra = function()
          vim.lsp.completion.enable(true, client.id, bufnr, {
            autotrigger = true,
            convert = function(item)
              return {
                kind_hlgroup = "Yellow",
                abbr = item.label:gsub("%b()", ""),
                kind = symbols[vim.lsp.protocol.CompletionItemKind[item.kind]],
                info = "",
              }
            end,
          })

          clear { group = groups.completion, buffer = bufnr }
          autocmd("CompleteDone", {
            group = groups.completion,
            buffer = bufnr,
            callback = function()
              vim.cmd.pclose { bang = true }
            end,
          })
        end,
      },
      -- {
      --   method = methods.textDocument_completion,
      --   mode = "i",
      --   lhs = "<CR>",
      --   rhs = function()
      --     -- TODO: check if something is selected
      --     return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
      --   end,
      --   expr = true,
      -- },
      {
        method = methods.textDocument_completion,
        mode = "i",
        lhs = "<C-Space>",
        rhs = function()
          vim.lsp.completion.trigger()
        end,
      },
      {
        method = methods.textDocument_completion,
        mode = "i",
        lhs = "<Tab>",
        rhs = function()
          return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
        end,
        expr = true,
      },
      {
        method = methods.textDocument_completion,
        mode = "i",
        lhs = "<S-Tab>",
        rhs = function()
          return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
        end,
        expr = true,
      },
    }

    for _, mapping in ipairs(maps) do
      if not mapping.method or client.supports_method(mapping.method) then
        if mapping.lhs then
          vim.keymap.set(mapping.mode or "n", mapping.lhs, mapping.rhs, {
            buffer = bufnr,
            desc = mapping.desc,
            expr = mapping.expr,
          })
        end

        if mapping.extra then
          mapping.extra()
        end
      end
    end
  end,
})
