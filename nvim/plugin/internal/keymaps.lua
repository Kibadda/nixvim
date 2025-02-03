if vim.g.loaded_plugin_keymaps then
  return
end

vim.g.loaded_plugin_keymaps = 1

local function map(mode, lhs, rhs, opts)
  if type(opts) == "string" then
    opts = { desc = opts }
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function jump(direction)
  return function()
    local count = vim.v.count

    if count == 0 then
      vim.cmd.normal { ("g%s"):format(direction), bang = true }

      return
    end

    if count > 5 then
      vim.cmd.normal { "m'", bang = true }
    end

    vim.cmd.normal { ("%d%s"):format(count, direction), bang = true }
  end
end

---@param direction 1 | -1
local function snippet(direction)
  return function()
    if vim.snippet.active { direction = direction } then
      vim.snippet.jump(direction)
    end
  end
end

map("n", "<ESC>", "<CMD>nohlsearch<CR><ESC>")
map({ "n", "x" }, "j", jump "j", "Down")
map({ "n", "x" }, "k", jump "k", "Down")
map({ "x", "n", "o" }, "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map({ "x", "n", "o" }, "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("n", "yA", "<Cmd>%y+<CR>", "Yank Whole File")
map("n", "<C-S-j>", "<Cmd>m .+1<CR>==", "Move Line Down")
map("n", "<C-S-k>", "<Cmd>m .-2<CR>==", "Move Line Up")
map("n", "U", "<C-r>", "Redo")
map("x", "y", "myy`y")
map("x", "Y", "myY`y")
map("x", "<", "<gv")
map("x", ">", ">gv")
map("x", "<C-S-j>", ":m '>+1<CR>gv=gv", "Move Lines Down")
map("x", "<C-S-k>", ":m '<-2<CR>gv=gv", "Move Lines Up")
map("x", "x", '"_d')
map("x", ".", ":normal .<CR>", "Dot repeat")
map("x", "@", ":normal Q<CR>", "Repeat macro")
map("i", "<S-CR>", "<C-o>o", "New Line Top")
map("i", "<C-CR>", "<C-o>O", "New Line Bottom")
map("i", "<C-BS>", "<C-w>")
map("i", ",", ",<C-g>u")
map("i", ";", ";<C-g>u")
map("i", ".", ".<C-g>u")
map({ "i", "c" }, "<C-h>", "<C-Left>", "Move word backwards")
map({ "i", "c" }, "<C-l>", "<C-Right>", "Move word forwards")
map("n", "gQ", "mzgggqG`z<Cmd>delmark z<CR>zz", "Format Buffer")
map("n", "]q", "<Cmd>cnext<CR>", "Next quickfix item")
map("n", "[q", "<Cmd>cprevious<CR>", "Previous quickfix item")
map({ "i", "s" }, "<C-l>", snippet(1))
map({ "i", "s" }, "<C-h>", snippet(-1))
map({ "n", "v", "x" }, "<Leader>y", '"+y', "Yank to clipboard")
map({ "n", "v", "x" }, "<Leader>p", '"+p', "Paste from clipboard")
map("c", "/", function()
  if vim.tbl_contains({ "/", "?" }, vim.fn.getcmdtype()) then
    return vim.api.nvim_replace_termcodes("<C-c><Esc>/\\%V", true, false, true)
  else
    return "/"
  end
end, { expr = true })
map("n", "ZZ", function()
  if vim.g.is_zoomed == 1 then
    vim.g.is_zoomed = 0
    vim.cmd.tabclose()
  else
    vim.g.is_zoomed = 1
    vim.cmd.tabedit(vim.fn.expand "%")
  end
end, "Zoom current window")
