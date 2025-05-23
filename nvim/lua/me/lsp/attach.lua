local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local clear = vim.api.nvim_clear_autocmds
local symbols = {
  Text = "󰉿",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰜢",
  Variable = "󰀫",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "󰑭",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "󰈇",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "󰙅",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "",
}

local should_confirm = false
local get = vim.lsp.completion.get
---@diagnostic disable-next-line:duplicate-set-field
function vim.lsp.completion.get()
  should_confirm = false
  get()
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
        vim.lsp.util.show_document(opts.items[1].user_data, client.offset_encoding)
      else
        require("mini.pick").registry.lsp {
          title = "Lsp " .. vim.split(opts.title, " ")[1],
          items = opts.items,
        }
      end
    end

    local methods = vim.lsp.protocol.Methods

    ---@type table<string, ({ lhs: string, rhs: function, desc: string, mode?: string|string[] }|function)[]>
    local maps = {
      [methods.textDocument_definition] = {
        {
          lhs = "gd",
          rhs = function()
            vim.lsp.buf.definition { on_list = on_list }
          end,
          desc = "Definition",
        },
        {
          lhs = "gD",
          rhs = function()
            local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
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
      },
      [methods.textDocument_references] = {
        {
          lhs = "grr",
          rhs = function()
            vim.lsp.buf.references({
              includeDeclaration = false,
            }, { on_list = on_list })
          end,
          desc = "References",
        },
      },
      [methods.textDocument_implementation] = {
        {
          lhs = "gI",
          rhs = function()
            vim.lsp.buf.implementation { on_list = on_list }
          end,
          desc = "Implementations",
        },
      },
      [methods.textDocument_documentSymbol] = {
        {
          lhs = "gs",
          rhs = function()
            vim.lsp.buf.document_symbol { on_list = on_list }
          end,
          desc = "Document Symbols",
        },
      },
      [methods.workspace_symbol] = {
        {
          lhs = "gS",
          rhs = function()
            vim.lsp.buf.workspace_symbol(nil, { on_list = on_list })
          end,
          desc = "Workspace Symbols",
        },
      },
      [methods.textDocument_codeLens] = {
        {
          lhs = "grl",
          rhs = function()
            vim.lsp.codelens.run()
          end,
          desc = "Run Codelens",
        },
        function()
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
      [methods.textDocument_documentHighlight] = {
        function()
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
      [methods.textDocument_inlayHint] = {
        {
          lhs = "gri",
          rhs = function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }, { bufnr = bufnr })
          end,
          desc = "Toggle Inlay Hint",
        },
      },
      [methods.textDocument_documentColor] = {
        function()
          require("mini.hipatterns").disable(bufnr)
          vim.lsp.document_color.enable(true, bufnr)
        end,
      },
      [methods.textDocument_formatting] = {
        function()
          if not vim.b[bufnr].formatter then
            vim.b[bufnr].formatter = vim.lsp.buf.format
          end
        end,
      },
      [methods.textDocument_completion] = {
        function()
          vim.lsp.completion.enable(true, client.id, bufnr, {
            autotrigger = true,
            convert = function(item)
              local word = item.label

              if item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet then
                word = (item.insertText or item.label):gsub("%b()", "")
              elseif item.textEdit then
                word = item.textEdit.newText:match "^(%S*)" or item.textEdit.newText
              elseif item.insertText and item.insertText ~= "" then
                word = item.insertText
              end

              return {
                kind = symbols[vim.lsp.protocol.CompletionItemKind[item.kind]],
                abbr = item.label:gsub("%b()", ""),
                word = word,
              }
            end,
          })
        end,
        {
          mode = "i",
          lhs = "<C-Space>",
          rhs = function()
            vim.lsp.completion.get()
          end,
        },
        {
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
          mode = { "i", "s" },
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
              vim.lsp.completion.get()
            else
              keys = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
            end

            if keys then
              vim.api.nvim_feedkeys(keys, "n", false)
            end
          end,
        },
        {
          mode = { "i", "s" },
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
      },
      _ = {
        {
          mode = { "i", "s" },
          lhs = "<C-l>",
          rhs = function()
            if vim.snippet.active { direction = 1 } then
              vim.snippet.jump(1)
            end
          end,
        },
        {
          mode = { "i", "s" },
          lhs = "<C-h>",
          rhs = function()
            if vim.snippet.active { direction = -1 } then
              vim.snippet.jump(-1)
            end
          end,
        },
      },
    }

    for method, mappings in pairs(maps) do
      if method == "_" or client:supports_method(method) then
        for _, mapping in ipairs(mappings) do
          if type(mapping) == "table" then
            vim.keymap.set(mapping.mode or "n", mapping.lhs, mapping.rhs, {
              buffer = bufnr,
              desc = mapping.desc,
            })
          else
            mapping()
          end
        end
      end
    end
  end,
})
