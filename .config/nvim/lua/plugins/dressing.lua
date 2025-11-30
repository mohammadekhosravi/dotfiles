-- lua/plugins/dressing.lua
return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  opts = {
    input = {
      enabled = true,
      border = "rounded",
      relative = "cursor",
    },
    select = {
      enabled = true,
      backend = { "telescope", "builtin" },
      telescope = require("telescope.themes").get_cursor({
        layout_config = {
          width = 0.5,
          height = 0.4,
        },
      }),
      builtin = {
        border = "rounded",
        relative = "cursor",
      },
    },
  },
}
