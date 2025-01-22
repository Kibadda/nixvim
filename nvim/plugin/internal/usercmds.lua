if vim.g.loaded_plugin_usercmds then
  return
end

vim.g.loaded_plugin_usercmds = 1

local function delete(opts)
  opts = opts or {}

  local buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_call(buf, function()
    if vim.bo.modified and not opts.force then
      local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
      if choice == 0 or choice == 3 then
        return
      end
      if choice == 1 then
        vim.cmd.write()
      end
    end

    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
      vim.api.nvim_win_call(win, function()
        if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
          return
        end

        local alt = vim.fn.bufnr "#"
        if alt ~= buf and vim.fn.buflisted(alt) == 1 then
          vim.api.nvim_win_set_buf(win, alt)
          return
        end

        local has_previous = pcall(vim.cmd, "bprevious")
        if has_previous and buf ~= vim.api.nvim_win_get_buf(win) then
          return
        end

        local new_buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_win_set_buf(win, new_buf)
      end)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.cmd, (opts.wipe and "bwipeout! " or "bdelete! ") .. buf)
    end
  end)
end

vim.api.nvim_create_user_command("D", function(args)
  delete { force = args.bang }
end, {
  bang = true,
  nargs = 0,
  desc = "Bdelete",
})

vim.api.nvim_create_user_command("B", function(args)
  delete { force = args.bang, wipe = true }
end, {
  bang = true,
  nargs = 0,
  desc = "Bwipeout",
})

vim.api.nvim_create_user_command("Rename", function()
  local function real(path)
    return vim.fs.normalize(vim.uv.fs_realpath(path) or path)
  end
  local buf = vim.api.nvim_get_current_buf()
  local old = assert(real(vim.api.nvim_buf_get_name(buf)))
  local root = assert(real(vim.uv.cwd() or "."))

  if old:find(root, 1, true) ~= 1 then
    root = vim.fn.fnamemodify(old, ":p:h")
  end

  local extra = old:sub(#root + 2)

  vim.ui.input({
    prompt = "New filename: ",
    default = extra,
    completion = file,
  }, function(new)
    if not new or new == "" or new == extra then
      return
    end

    new = vim.fs.normalize(root .. "/" .. new)
    vim.fn.mkdir(vim.fs.dirname(new), "p")
    local changes = {
      files = {
        {
          oldUri = vim.uri_from_fname(old),
          newUri = vim.uri_from_fname(new),
        },
      },
    }

    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
      if client:supports_method(vim.lsp.protocol.Methods.workspace_willRenameFiles) then
        local response = client:request_sync(vim.lsp.protocol.Methods.workspace_willRenameFiles, changes, 1000, 0)
        if response and response.result then
          vim.lsp.util.apply_workspace_edit(response.result, client.offset_encoding)
        end
      end
    end

    vim.fn.rename(old, new)
    vim.cmd.edit(new)
    vim.api.nvim_buf_delete(buf, { force = true })
    vim.fn.delete(old)

    for _, client in ipairs(clients) do
      if client:supports_method(vim.lsp.protocol.Methods.workspace_didRenameFiles) then
        client:notify(vim.lsp.protocol.Methods.workspace_didRenameFiles, changes)
      end
    end
  end)
end, {
  nargs = 0,
  desc = "Rename file",
})
