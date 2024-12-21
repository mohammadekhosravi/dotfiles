vim.cmd([[
  aunmenu PopUp
  anoremenu PopUp.Inspect        <cmd>Inspect<CR>
  amenu PopUp.-1-                <NOP>
  anoremenu PopUp.Definition     <cmd>lua vim.lsp.buf.definition()<CR>
  anoremenu PopUp.References     <cmd>Telescope lsp_references<CR>
  anoremenu PopUp.Back           <C-t>
  amenu PopUp.-2-                <NOP>
  amenu PopUp.URL                gx
]])

local function check_line_for_url()
  local current_line = unpack(vim.api.nvim_win_get_cursor(0))
  local current_line_content = vim.api.nvim_buf_get_lines(0, current_line - 1, current_line, false)[1]
  local url_pattern = "https?://[^%s\"'<>%#]*[^.,;%s]"
  local url_match = current_line_content:match(url_pattern)

  if url_match then
    return true
  else
    return false
  end
end

local group = vim.api.nvim_create_augroup("nvim_popupmenu", { clear = true })
vim.api.nvim_create_autocmd("MenuPopup", {
  pattern = "*",
  group = group,
  desc = "Custom Popup Menu Setup",
  callback = function()
    vim.cmd([[
      amenu disable PopUp.Definition
      amenu disable PopUp.References
      amenu disable PopUp.URL
    ]])

    if vim.lsp.get_clients({ bufnr = 0 })[1] then
      vim.cmd([[
        amenu enable PopUp.Definition
        amenu enable PopUp.References
      ]])
    end

    if check_line_for_url() then
      vim.cmd([[
        amenu enable PopUp.URL
      ]])
    end
  end,
})
