--[[ if it wasn't working check `:messages`
on this maching(archem) i went to .local/share/nvim/lazy/markdown-preview/app and execute install.sh  ]]
-- install with yarn or npm
return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
}
