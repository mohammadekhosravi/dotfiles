return {
  "j-hui/fidget.nvim",
  event = "LspAttach",
  opts = {
    progress = {
      poll_rate = 0,
      suppress_on_insert = true,
      ignore_done_already = true,
      ignore_empty_message = true,
      display = {
        render_limit = 5,
        done_ttl = 2,
        progress_ttl = math.huge,
      },
    },
    notification = {
      override_vim_notify = true,
      configs = {
        default = {
          name = nil,
          icon = nil,
          info_annote = nil,
          warn_annote = nil,
          error_annote = nil,
          debug_annote = nil,
        },
      },
      view = {
        group_separator = "",
        stack_upwards = false,
      },
      window = {
        winblend = 0,
        relative = "editor",
        max_width = 50,
      },
    },
  },
}
