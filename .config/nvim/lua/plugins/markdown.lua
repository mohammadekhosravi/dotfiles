--[[ if it wasn't working check `:messages`
on this maching(archer) i went to .local/share/nvim/lazy/markdown-preview/app and execute install.sh  ]]
return {
  "iamcco/markdown-preview.nvim",
  ft = { "markdown" },
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
}
