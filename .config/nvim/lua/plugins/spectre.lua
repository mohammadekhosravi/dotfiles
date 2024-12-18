return {
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  opts = { open_cmd = "noswapfile vnew" },
  -- stylua: ignore
  keys = {
    {
      "<leader>sr",
      function() require("spectre").open() end,
      desc =
      "Replace in files (Spectre)"
    },
    {
      "<leader>sp",
      function() require("spectre").open_file_search({ select_word = true }) end,
      desc =
      "Replace on current file (Spectre)"
    },
  },
}
