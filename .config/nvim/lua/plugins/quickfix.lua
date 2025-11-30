-- ═══════════════════════════════════════════════════════════════════════════
-- NVIM-BQF: Better QuickFix
-- ═══════════════════════════════════════════════════════════════════════════
-- Enhances the native quickfix window with:
--   • Floating preview window for each item
--   • Better navigation and filtering
--   • Sign-based multi-select for bulk operations
--   • fzf integration for fuzzy filtering
--   • Magic window (keeps layout stable)
-- ═══════════════════════════════════════════════════════════════════════════

return {
  "kevinhwang91/nvim-bqf",

  -- Only load when a quickfix buffer is opened
  ft = "qf",

  dependencies = {
    -- Optional: enables fuzzy filtering within quickfix (zf keymap)
    {
      "junegunn/fzf",
      build = function()
        vim.fn["fzf#install"]()
      end,
    },
  },

  opts = {
    -- ═════════════════════════════════════════════════════════════════════
    -- CORE SETTINGS
    -- ═════════════════════════════════════════════════════════════════════

    -- Enable bqf enhancements for all quickfix windows
    auto_enable = true,

    -- Magic window: when jumping to an item, reuse the previous window
    -- instead of opening in the first available window
    -- This keeps your window layout stable
    magic_window = true,

    -- ═════════════════════════════════════════════════════════════════════
    -- HEIGHT CALCULATION WITH PADDING
    -- ═════════════════════════════════════════════════════════════════════
    -- When set to a function, bqf calls it to determine quickfix height
    -- Parameters:
    --   qf_count: number of items in quickfix list
    --   lcount:   number of lines (may differ from qf_count with wrapping)
    --
    -- Our logic:
    --   • Add 2 lines of padding (breathing room at bottom)
    --   • Minimum height: 5 lines (usable even with 1-2 items)
    --   • Maximum height: 15 lines (don't overwhelm the screen)
    -- ─────────────────────────────────────────────────────────────────────
    auto_resize_height = true,

    -- ═════════════════════════════════════════════════════════════════════
    -- PREVIEW WINDOW SETTINGS
    -- ═════════════════════════════════════════════════════════════════════
    -- The floating preview shows the context around each quickfix item
    -- without leaving the quickfix window
    -- ─────────────────────────────────────────────────────────────────────
    preview = {
      -- Height of preview window when quickfix is at bottom (horizontal split)
      win_height = 15,

      -- Height of preview window when quickfix is at side (vertical split)
      win_vheight = 15,

      -- Transparency: 0 = opaque, 100 = fully transparent
      -- 0 recommended for readability
      winblend = 0,

      -- Border style: "rounded", "single", "double", "shadow", "none"
      border = "rounded",

      -- Show filename in preview window title bar
      show_title = true,

      -- Hide scrollbar in preview (cleaner look)
      show_scroll_bar = false,

      -- Delay before applying syntax highlighting (ms)
      -- Lower = faster but may cause lag on large files
      delay_syntax = 50,

      -- Don't wrap long lines in preview
      wrap = false,
    },

    -- ═════════════════════════════════════════════════════════════════════
    -- KEY MAPPINGS (inside quickfix window)
    -- ═════════════════════════════════════════════════════════════════════
    -- These mappings only apply when cursor is in the quickfix window
    -- ─────────────────────────────────────────────────────────────────────
    func_map = {
      -- ─────────────────────────────────────────────────────────────────
      -- Opening items
      -- ─────────────────────────────────────────────────────────────────
      open = "<CR>",    -- Open item in previous window, keep qf open
      openc = "o",      -- Open item and CLOSE quickfix window
      drop = "O",       -- Open in previous window (reuse buffer if possible)
      split = "<C-s>",  -- Open in horizontal split
      vsplit = "<C-v>", -- Open in vertical split
      tab = "t",        -- Open in new tab, switch to it
      tabb = "T",       -- Open in new tab, stay in quickfix
      tabc = "<C-t>",   -- Open in new tab (alternative)

      -- ─────────────────────────────────────────────────────────────────
      -- Preview controls
      -- ─────────────────────────────────────────────────────────────────
      ptogglemode = "zp",    -- Toggle preview mode: normal ↔ maximized
      ptoggleitem = "p",     -- Toggle preview for current item on/off
      ptoggleauto = "P",     -- Toggle auto-preview (show on cursor move)
      pscrollup = "<C-u>",   -- Scroll preview window up
      pscrolldown = "<C-d>", -- Scroll preview window down
      pscrollorig = "zo",    -- Scroll preview to original error position

      -- ─────────────────────────────────────────────────────────────────
      -- Navigation
      -- ─────────────────────────────────────────────────────────────────
      prevfile = "<C-p>", -- Jump to previous FILE in list (skip same-file items)
      nextfile = "<C-n>", -- Jump to next FILE in list
      prevhist = "<",     -- Previous quickfix list in history
      nexthist = ">",     -- Next quickfix list in history
      lastleave = "'\"",  -- Jump to position when you last left quickfix

      -- ─────────────────────────────────────────────────────────────────
      -- Sign-based selection (for bulk operations)
      -- ─────────────────────────────────────────────────────────────────
      -- Signs let you mark multiple items, then filter to only those
      stoggleup = "<S-Tab>", -- Toggle sign on current item, move UP
      stoggledown = "<Tab>", -- Toggle sign on current item, move DOWN
      stogglevm = "<Tab>",   -- Toggle signs on visual selection
      stogglebuf = "'<Tab>", -- Toggle signs for ALL items in same buffer
      sclear = "z<Tab>",     -- Clear all signs

      -- ─────────────────────────────────────────────────────────────────
      -- Filtering (create new quickfix from subset)
      -- ─────────────────────────────────────────────────────────────────
      filter = "zn",    -- New quickfix with only SIGNED items
      filterr = "zN",   -- New quickfix with only UNSIGNED items
      fzffilter = "zf", -- Open fzf to fuzzy-filter quickfix items
    },

    -- ═════════════════════════════════════════════════════════════════════
    -- FZF FILTER SETTINGS
    -- ═════════════════════════════════════════════════════════════════════
    -- When pressing `zf`, fzf opens to fuzzy-search within quickfix items
    -- ─────────────────────────────────────────────────────────────────────
    filter = {
      fzf = {
        -- What happens when you select an item with these keys:
        action_for = {
          ["ctrl-s"] = "split",    -- Open selection in horizontal split
          ["ctrl-v"] = "vsplit",   -- Open selection in vertical split
          ["ctrl-t"] = "tab drop", -- Open selection in new tab
        },

        -- Extra fzf command-line options:
        --   --bind ctrl-o:toggle-all  → Ctrl+O selects/deselects all matches
        --   --delimiter │             → Column separator for alignment
        extra_opts = {
          "--bind", "ctrl-o:toggle-all",
          "--delimiter", "│",
        },
      },
    },
  },
}
