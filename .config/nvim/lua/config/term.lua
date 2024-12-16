vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Set options for builtin terminal',
  group = vim.api.nvim_create_augroup('builtin-term-options', { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end
})
