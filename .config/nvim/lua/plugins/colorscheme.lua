return {
  "navarasu/onedark.nvim",
  priority = 1000,
  config = function()
    require('onedark').setup {
      style = 'cool'
    }
    require('onedark').load()

    vim.api.nvim_set_hl(0, "LspInlayHint", {
      fg = "#5c6370", -- Dim gray color
      bg = "NONE",
      italic = true,
    })
  end
}
