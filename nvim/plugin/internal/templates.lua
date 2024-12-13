if vim.g.loaded_plugin_templates then
  return
end

vim.g.loaded_plugin_templates = 1

vim.api.nvim_create_autocmd("BufNewFile", {
  group = vim.api.nvim_create_augroup("Templates", { clear = true }),
  callback = function(args)
    local templates = vim.api.nvim_get_runtime_file("template/*." .. vim.fn.fnamemodify(args.file, ":e"), true)

    if #templates == 0 then
      return
    end

    local function read(file)
      local f = io.open(file, "r")
      if f then
        local content = f:read "*a"
        vim.snippet.expand(content)
      end
    end

    if #templates == 1 then
      read(templates[1])
    else
      vim.ui.select(templates, {
        prompt = "Select template file:",
        format_item = function(item)
          return vim.fs.basename(item)
        end,
      }, function(choice)
        if choice then
          read(choice)
        end
      end)
    end
  end,
})
