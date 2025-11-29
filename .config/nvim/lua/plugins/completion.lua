return {
  'saghen/blink.cmp',
  version = '1.*',
  opts = {
    keymap = {
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide" },
      ["<Tab>"] = { "select_and_accept" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },

    appearance = {
      nerd_font_variant = 'mono',
    },

    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = 'rounded' },
      },
      menu = {
        border = 'rounded',
        draw = {
          columns = {
            { 'kind_icon' },
            { 'label',    'label_description', gap = 1 },
          },
          treesitter = { 'lsp' },
        },
      },
      ghost_text = { enabled = true },

      -- KEY: Make completions smarter
      list = {
        -- Only show completions when LSP actually returns results
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },

      -- Don't trigger on every character - be more selective
      trigger = {
        -- Show completion after typing trigger characters (like '.')
        show_on_trigger_character = true,
        -- Don't auto-show for blocked filetypes
        show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
        -- Only show when there are actual results
        show_in_snippet = false,
      },
    },

    signature = {
      enabled = true,
      window = { border = 'rounded' },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      -- Prioritize LSP over buffer - this is important!
      providers = {
        lsp = {
          score_offset = 100, -- Higher priority
          fallbacks = {},     -- Don't fallback when LSP returns nothing
        },
        buffer = {
          score_offset = -50,     -- Lower priority
          min_keyword_length = 3, -- Only suggest buffer words 3+ chars
        },
        snippets = {
          score_offset = 80,
        },
        path = {
          score_offset = 90,
        },
      },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
