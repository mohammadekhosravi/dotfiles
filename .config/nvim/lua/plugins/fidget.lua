-- for showing lsp attach notifications
return {
  "j-hui/fidget.nvim",
  event = "LspAttach",
  opts = {
    notification = {
      override_vim_notify = true,
      configs = {
        default = {
          name = nil,        -- removes "Notification" header
          icon = nil,        -- removes ">>" icon
          info_annote = nil, -- removes "Info" label
          warn_annote = nil,
          error_annote = nil,
          debug_annote = nil,
        },
      },
      view = {
        group_separator = "",
      },
      window = {
        winblend = 0,
        relative = "editor",
      },
    },
  },
}
