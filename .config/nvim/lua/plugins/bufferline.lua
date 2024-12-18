return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = { 'nvim-tree/nvim-web-devicons', 'moll/vim-bbye' },
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",
        close_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
        max_name_length = 30,
        max_prefix_length = 30,        -- prefix used when a buffer is de-duplicated
      },
    })
  end
}
