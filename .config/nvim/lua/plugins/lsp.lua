return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
    'saghen/blink.cmp',
  },
  config = function()
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    local lspconfig = require('lspconfig')

    lspconfig['lua_ls'].setup({ capabilities = capabilities })
    lspconfig['gopls'].setup({ capabilities = capabilities })
    lspconfig['ts_ls'].setup({ capabilities = capabilities })

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        -- check to see if client exist
        if not client then return end

        -- define formatting on save only if client supports formatting
        if client.supports_method('textDocument/formatting') then
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format {
                -- Never request typescript-language-server for formatting
                filter = function(c) return c.name ~= "tsserver" and c.name ~= "ts_ls" end,
                bufnr = args.buf,
                id = client.id,
              }
            end
          })
        end
      end,
    })
  end
}
