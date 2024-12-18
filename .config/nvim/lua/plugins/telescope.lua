return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    }
  },
  config = function()
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
    vim.keymap.set(
      "n",
      "<leader>fg",
      "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
      { desc = "Live Grep" }
    )
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help Tags" })
    vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find Word under Cursor" })
    vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find Keymaps" })

    require('telescope').setup {
      pickers = {
        find_files = {
          theme = 'ivy',
        },
        live_grep = {
          theme = 'ivy',
        },
        help_tags = {
          theme = 'ivy',
        },
        buffers = {
          theme = 'ivy',
        },
        grep_string = {
          theme = 'ivy'
        },
        keymaps = {
          theme = 'ivy'
        }
      },
      extensions = {
        fzf = {},
      }
    }

    -- To get fzf loaded and working with telescope, you need to call
    -- load_extension, somewhere after setup function:
    require('telescope').load_extension('fzf')
    -- load multigrep picker that we wrote
    require('config.multigrep').setup()
  end,
}
