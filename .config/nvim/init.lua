require("config.lazy")
require("options")

-- format go files when save a file
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("formatGoCode", { clear = true }),
  pattern = "*.go",
  command = "silent exec '!gofmt -w %'",
})
