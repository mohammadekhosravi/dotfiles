local group = vim.api.nvim_create_augroup("nvim_popupmenu_custom", { clear = true })

vim.api.nvim_create_autocmd("MenuPopup", {
  pattern = "*",
  group = group,
  desc = "Customize default popup menu",
  callback = function()
    pcall(vim.cmd, [[aunmenu PopUp.How-to\ disable\ mouse]])
  end,
})
