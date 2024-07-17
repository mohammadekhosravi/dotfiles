vim.cmd "set number"
vim.cmd "colorscheme habamax"
vim.cmd "set expandtab"
vim.cmd "set shiftwidth=2"
vim.cmd "set tabstop=2"
vim.cmd "set smartcase"
vim.cmd "set smartindent"

vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("formatGoCode", { clear = true }),
  pattern = "*.go",
  command = "silent exec '!gofmt -w %'",
})
