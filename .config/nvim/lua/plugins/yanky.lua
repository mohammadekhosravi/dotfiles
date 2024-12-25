return {
  "gbprod/yanky.nvim",
  dependencies = { { "kkharji/sqlite.lua", enabled = not jit.os:find("Windows") } },
  opts = function()
    local mapping = require("yanky.telescope.mapping")
    local mappings = mapping.get_defaults()
    mappings.i["<c-p>"] = nil
    return {
      highlight = { timer = 200 },
      ring = { storage = jit.os:find("Windows") and "shada" or "sqlite" },
      picker = {
        telescope = {
          use_default_mappings = false,
          mappings = mappings,
        },
      },
    }
  end,
  keys = {
    -- stylua: ignore
    {
      "<leader>p",
      function() require("telescope").extensions.yank_history.yank_history({}) end,
      desc =
      "Open Yank History"
    },
    {
      "y",
      "<Plug>(YankyYank)",
      mode = { "n", "x" },
      desc = "Yank text",
    },
    {
      "p",
      "<Plug>(YankyPutAfter)",
      mode = { "n", "x" },
      desc = "Put yanked text after cursor",
    },
    {
      "P",
      "<Plug>(YankyPutBefore)",
      mode = { "n", "x" },
      desc = "Put yanked text before cursor",
    },
  },
}
