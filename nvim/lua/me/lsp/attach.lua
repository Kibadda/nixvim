local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local clear = vim.api.nvim_clear_autocmds
local symbols = require "me.data.symbols"

local should_confirm = false
local trigger = vim.lsp.completion.trigger
---@diagnostic disable-next-line:duplicate-set-field
function vim.lsp.completion.trigger()
  should_confirm = false
  trigger()
end

local groups = {
  highlight = augroup("LspAttachHighlight", { clear = false }),
  codelens = augroup("LspAttachCodelens", { clear = false }),
  inlay = augroup("LspAttachInlay", { clear = false }),
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

    ---@type table<string, { method?: string, lhs?: string, rhs?: function, mode?: string, desc?: string, extra?: function }>
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
        method = methods.textDocument_definition,
        lhs = "gD",
        rhs = function()
          local params = vim.lsp.util.make_position_params()
          vim.lsp.buf_request(bufnr, vim.lsp.protocol.Methods.textDocument_definition, params, function(_, result)
            if not result or vim.tbl_isempty(result) then
              return nil
            end
            local buf = vim.lsp.util.preview_location(result[1], {})
            if buf then
              local cur_buf = vim.api.nvim_get_current_buf()
              local filetype = vim.bo[cur_buf].filetype
              if filetype == "php" then
                filetype = "php_only"
              end
              vim.bo[buf].filetype = filetype
            end
          end)
        end,
        desc = "Peek definition",
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
              local word = item.label

              if item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet then
                word = item.label:gsub("%b()", "")
              elseif item.textEdit then
                word = item.textEdit.newText:match "^(%S*)" or item.textEdit.newText
              elseif item.insertText and item.insertText ~= "" then
                word = item.insertText
              end

              return {
                kind_hlgroup = "Yellow",
                kind = symbols[vim.lsp.protocol.CompletionItemKind[item.kind]],
                abbr = item.label:gsub("%b()", ""),
                word = word,
              }
            end,
          })
        end,
      },
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
        lhs = "<CR>",
        rhs = function()
          local keys
          if vim.fn.pumvisible() == 1 then
            local info = vim.fn.complete_info()

            if info.selected == -1 or not should_confirm then
              keys = vim.api.nvim_replace_termcodes("<C-e>", true, false, true)
                .. require("nvim-autopairs").autopairs_cr()
            else
              keys = vim.api.nvim_replace_termcodes("<C-y>", true, false, true)
            end
          else
            keys = require("nvim-autopairs").autopairs_cr()
          end

          vim.api.nvim_feedkeys(keys, "n", false)
        end,
      },
      {
        method = methods.textDocument_completion,
        mode = "i",
        lhs = "<Tab>",
        rhs = function()
          local function has_words_before()
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and not vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s"
          end

          local keys
          if vim.fn.pumvisible() == 1 then
            should_confirm = true
            keys = vim.api.nvim_replace_termcodes("<C-n>", true, false, true)
          elseif has_words_before() then
            vim.lsp.completion.trigger()
          else
            keys = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
          end

          if keys then
            vim.api.nvim_feedkeys(keys, "n", false)
          end
        end,
      },
      {
        method = methods.textDocument_completion,
        mode = "i",
        lhs = "<S-Tab>",
        rhs = function()
          local keys
          if vim.fn.pumvisible() == 1 then
            should_confirm = true
            keys = vim.api.nvim_replace_termcodes("<C-p>", true, false, true)
          else
            keys = vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true)
          end

          vim.api.nvim_feedkeys(keys, "n", false)
        end,
      },
    }

    for _, mapping in ipairs(maps) do
      if not mapping.method or client.supports_method(mapping.method) then
        if mapping.lhs then
          vim.keymap.set(mapping.mode or "n", mapping.lhs, mapping.rhs, {
            buffer = bufnr,
            desc = mapping.desc,
          })
        end

        if mapping.extra then
          mapping.extra()
        end
      end
    end
  end,
})
