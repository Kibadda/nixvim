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
