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

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Don't do anything when <space> is pressed
keymap({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Windows Navigation
-- See `:help windows` and/or `:help wincmd`
-- There are a lot more usefull command with CTRL-w but we are remapping this because there are frequently used
keymap("n", "<C-h>", "<C-w>h", { noremap = true, silent = true, desc = 'Navigate to left window' })
keymap("n", "<C-j>", "<C-w>j", { noremap = true, silent = true, desc = 'Navigate to bottom window' })
keymap("n", "<C-k>", "<C-w>k", { noremap = true, silent = true, desc = 'Navigate to top window' })
keymap("n", "<C-l>", "<C-w>l", { noremap = true, silent = true, desc = 'Navigate to right window' })

-- Buffers Navigation
keymap("n", "<S-l>", ":bnext<CR>", { noremap = true, silent = true, desc = 'Navigate to next buffer' })
keymap("n", "<S-h>", ":bprevious<CR>", { noremap = true, silent = true, desc = 'Navigate to previous buffer' })

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
keymap('n', '<M-j>', '<cmd>cnext<cr>', { noremap = true, silent = true, desc = 'Go to next item in quickfix list' })
keymap('n', '<M-k>', '<cmd>cprev<cr>', { noremap = true, silent = true, desc = 'Go to previous item in quickfix list' })

-- Builtin Terminal
keymap(
  'n',
  '<leader>st',
  function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd('J')
    vim.api.nvim_win_set_height(0, 8)
    vim.cmd.normal('A')
  end,
  { noremap = true, silent = true, desc = '' }
)
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = 'Navigate from terminal to left window', silent = true })
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = 'Navigate from terminal to buttom window', silent = true })
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = 'Navigate from terminal to top window', silent = true })
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = 'Navigate from terminal to right window', silent = true })

-- Telescope
keymap('n', '<leader>sf', '<cmd>Telescope find_files<cr>', { desc = '[S]earch [F]iles' })
keymap('n', '<leader>sh', '<cmd>Telescope help_tags<cr>', { desc = '[S]earch Neovim [H]elp' })
keymap('n', '<leader>sg', '<cmd>Telescope live_grep<cr>', { desc = '[S]earch by [G]rep' })
keymap('n', '<leader><space>', '<cmd>Telescope buffers<cr>', { desc = '[ ] Find existing buffers' })
-- TODO: make it search word under cursor
keymap('n', '<leader>sw', '<cmd>Telescope grep_string<cr>', { desc = '[S]earch current [W]ord' })
keymap('n', '<leader>sd', '<cmd>Telescope diagnostics<cr>', { desc = '[S]earch [D]iagnostics' })
