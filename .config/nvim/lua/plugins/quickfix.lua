return {
  "kevinhwang91/nvim-bqf",
  ft = "qf",
  dependencies = {
    -- Optional: better fuzzy search in quickfix
    {
      "junegunn/fzf",
      build = function()
        vim.fn["fzf#install"]()
      end,
    },
  },
  opts = {
    auto_enable = true,
    auto_resize_height = true,
    magic_window = true,

    preview = {
      win_height = 15,
      win_vheight = 15,
      winblend = 0,
      border = "rounded",
      show_title = true,
      show_scroll_bar = false,
      delay_syntax = 50,
      wrap = false,
    },

    func_map = {
      open = "<CR>",
      openc = "o", -- open and close qf
      drop = "O",  -- open in previous window
      split = "<C-s>",
      vsplit = "<C-v>",
      tab = "t",
      tabb = "T",         -- open in new tab but stay in qf
      tabc = "<C-t>",
      ptogglemode = "zp", -- toggle preview mode (normal/max)
      ptoggleitem = "p",  -- toggle preview for item
      ptoggleauto = "P",  -- toggle auto preview
      pscrollup = "<C-u>",
      pscrolldown = "<C-d>",
      pscrollorig = "zo", -- scroll to original position
      prevfile = "<C-p>",
      nextfile = "<C-n>",
      prevhist = "<",
      nexthist = ">",
      lastleave = "'\"",
      stoggleup = "<S-Tab>", -- toggle sign and move up
      stoggledown = "<Tab>", -- toggle sign and move down
      stogglevm = "<Tab>",   -- toggle multiple signs in visual
      stogglebuf = "'<Tab>", -- toggle signs for same buffer
      sclear = "z<Tab>",     -- clear signs
      filter = "zn",         -- create new qf with signed items
      filterr = "zN",        -- create new qf with unsigned items
      fzffilter = "zf",      -- fzf filter mode
    },

    filter = {
      fzf = {
        action_for = {
          ["ctrl-s"] = "split",
          ["ctrl-v"] = "vsplit",
          ["ctrl-t"] = "tab drop",
        },
        extra_opts = { "--bind", "ctrl-o:toggle-all", "--delimiter", "│" },
      },
    },
  },
}
