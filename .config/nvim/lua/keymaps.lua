-- See `:help vim.keymap.set()`
-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Modifier Keys
-- 'C' = 'CTRL'
-- 'S' = 'Shift'
-- 'A' = 'Alt'
-- '<leader>' = <Space>

-- NOTE: you can `:map {lhs}`(or nmap, vmap and ...) to see keybinding for specific shortcut.
-- NOTE: i.e: `:nmap K` shows you that it's mapped to `vim.lsp.buf.hover()`

-- NOTE: see `:h tagstack`, you can use <CTRL-T> to jump back to older entry in tagstack
-- NOTE: see `:h jump-motions`, you can use <CTRL-O>(go to older position) and <CTRL-I>(go to newer position)

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- Don't do anything when <space> is pressed
keymap({ "n", "v" }, "<Space>", "<Nop>", term_opts)

-- Windows Navigation
-- See `:help windows` and/or `:help wincmd`
-- There are a lot more usefull command with CTRL-w but we are remapping this because there are frequently used
keymap("n", "<C-h>", "<C-w>h", vim.tbl_deep_extend("force", opts, { desc = "Navigate to left window" }))
keymap("n", "<C-j>", "<C-w>j", vim.tbl_deep_extend("force", opts, { desc = "Navigate to bottom window" }))
keymap("n", "<C-k>", "<C-w>k", vim.tbl_deep_extend("force", opts, { desc = "Navigate to top window" }))
keymap("n", "<C-l>", "<C-w>l", { desc = "Navigate to right window" })

-- Buffers Navigation
keymap("n", "<S-l>", ":bnext<CR>", vim.tbl_deep_extend("force", opts, { desc = "Navigate to next buffer" }))
keymap("n", "<S-h>", ":bprevious<CR>", vim.tbl_deep_extend("force", opts, { desc = "Navigate to previous buffer" }))

-- Resize windows with CTRL + arrow keys
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Press `jk` or 'kj' to simulate <ESC> key
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)

-- You can yank things and then paste to replace.
keymap("v", "p", '"_dP', opts)

-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Quickfix List
keymap(
  "n",
  "<M-j>",
  "<cmd>cnext<cr>",
  vim.tbl_deep_extend("force", opts, { desc = "Go to next item in quickfix list" })
)
keymap(
  "n",
  "<M-k>",
  "<cmd>cprev<cr>",
  vim.tbl_deep_extend("force", opts, { desc = "Go to previous item in quickfix list" })
)

-- Builtin Terminal
keymap("n", "<leader>st", function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 8)
  vim.cmd.normal("A")
end, vim.tbl_deep_extend("force", opts, { desc = "Open builtin termainal" }))
keymap(
  "t",
  "<Esc><Esc>",
  "<C-\\><C-N>",
  vim.tbl_deep_extend("force", term_opts, { desc = "Navigate from terminal to left window" })
)
keymap(
  "t",
  "<C-h>",
  "<C-\\><C-N><C-w>h",
  vim.tbl_deep_extend("force", term_opts, { desc = "Navigate from terminal to left window" })
)
keymap(
  "t",
  "<C-j>",
  "<C-\\><C-N><C-w>j",
  vim.tbl_deep_extend("force", term_opts, { desc = "Navigate from terminal to bottom window" })
)
keymap(
  "t",
  "<C-k>",
  "<C-\\><C-N><C-w>k",
  vim.tbl_deep_extend("force", term_opts, { desc = "Navigate from terminal to top window" })
)
keymap(
  "t",
  "<C-l>",
  "<C-\\><C-N><C-w>l",
  vim.tbl_deep_extend("force", term_opts, { desc = "Navigate from terminal to right window" })
)

-- execute config
keymap("n", "<space><space>x", "<cmd>source %<CR>", { desc = "Source current buffer" })
keymap("v", "<space><space>x", ":lua<CR>", { desc = "Source highlighted segment" })
