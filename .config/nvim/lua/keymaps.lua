local keymap = vim.keymap.set

-- Telescope
keymap('n', '<leader>fd', '<cmd>Telescope find_files<cr>', { desc = 'Fuzzy search files' })
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Fuzzy search neovim help guides' })
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Fuzzy search neovim help guides' })
