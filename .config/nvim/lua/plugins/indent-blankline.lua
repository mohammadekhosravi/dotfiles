return {
  -- Add indentation guides even on blank lines
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  config = function()
    require("ibl").setup({
      indent = { char = "┊" },
      scope = { enabled = false },
    })
  end,
}
