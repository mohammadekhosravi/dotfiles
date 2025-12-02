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
        auto_show = false,
        auto_show_delay_ms = 200,
        window = { border = 'rounded' },
      },
      menu = {
        border = 'rounded',
        draw = {
          columns = {
            { 'kind_icon' },
            { 'label',      'label_description', gap = 1 },
            { 'source_name' },
          },
          treesitter = { 'lsp' },
        },
      },
      ghost_text = { enabled = false },

      list = {
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },

      trigger = {
        show_on_trigger_character = true,
        show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
        show_in_snippet = true,
      },

      -- IMPORTANT: This makes auto-imports work!
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
    },

    -- This would help you when calling a function, we disable automatic sianature_help, but you can still invoke it with a keymap
    signature = {
      enabled = false,
      window = { border = 'rounded' },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lsp = {
          score_offset = 100,
          fallbacks = {},
        },
        buffer = {
          score_offset = -100,
          min_keyword_length = 4,
          max_items = 5,
        },
        snippets = {
          score_offset = 90,
        },
        path = {
          score_offset = 95,
        },
      },
    },

    fuzzy = {
      implementation = "prefer_rust_with_warning",
      -- Better fuzzy matching
      frecency = {
        -- Whether to enable the frecency feature
        enabled = true,
      },
      use_proximity = true,
    },
  },
  opts_extend = { "sources.default" },
}
