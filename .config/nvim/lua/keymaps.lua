local keymap = vim.keymap.set

-- Telescope
keymap('n', '<leader>fd', '<cmd>Telescope find_files<cr>', { desc = 'Fuzzy search files' })
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Fuzzy search neovim help guides' })
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Fuzzy search neovim help guides' })

-- Quickfix List
keymap('n', '<M-j>', '<cmd>cnext<cr>', { desc = 'Go to next item in quickfix list' })
keymap('n', '<M-k>', '<cmd>cprev<cr>', { desc = 'Go to previous item in quickfix list' })

-- Builtin Terminal
keymap(
  'n',
  '<leader>st',
  function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd('J')
    vim.api.nvim_win_set_height(0, 8)
  end,
  { desc = '' }
)
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = 'Navigate from terminal to left window' })
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = 'Navigate from terminal to buttom window' })
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = 'Navigate from terminal to top window' })
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = 'Navigate from terminal to right window' })
