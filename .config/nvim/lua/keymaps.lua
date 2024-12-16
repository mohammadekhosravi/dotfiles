local keymap = vim.keymap.set

-- Telescope
keymap('n', '<leader>fd', '<cmd>Telescope find_files<cr>', { desc = 'Fuzzy search files' })
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Fuzzy search neovim help guides' })
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Fuzzy search neovim help guides' })

-- Quickfix List
keymap('n', '<M-j>', '<cmd>cnext<cr>', { desc = 'Go to next item in quickfix list' })
keymap('n', '<M-k>', '<cmd>cprev<cr>', { desc = 'Go to previous item in quickfix list' })
