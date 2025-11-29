-- npm i -g vscode-langservers-extracted
-- You need to install this package for eslint to work properly.
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
    "saghen/blink.cmp",
    "j-hui/fidget.nvim",
  },

  config = function()
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    local servers = { "lua_ls", "gopls", "ts_ls", "html", "cssls", "tailwindcss", "eslint" }
    for _, name in ipairs(servers) do
      local opts = {
        capabilities = capabilities,
      }

      -- TypeScript - make it smarter
      if name == "ts_ls" then
        opts.settings = {
          typescript = {
            suggest = {
              completeFunctionCalls = true,
              autoImports = true,
            },
            preferences = {
              includeCompletionsForModuleExports = true,
              includeCompletionsWithSnippetText = true,
            },
          },
          javascript = {
            suggest = {
              completeFunctionCalls = true,
              autoImports = true,
            },
            preferences = {
              includeCompletionsForModuleExports = true,
              includeCompletionsWithSnippetText = true,
            },
          },
        }
      end

      if name == "eslint" then
        opts.settings = {
          codeActionOnSave = {
            enable = false,
            mode = "all",
          },
        }
      end

      vim.lsp.config(name, opts)
      vim.lsp.enable(name)
    end

    -- Attach logic
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        require("fidget").notify(client.name .. " attached", nil, { key = "lsp_attach_" .. client.name })

        local buf = args.buf
        local nmap = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = buf, desc = desc and ("LSP: " .. desc) })
        end

        nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
        nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
        nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
        nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
        nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
        nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
        nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        -- create the Command :CodeActionsAll
        vim.api.nvim_buf_create_user_command(buf, "CodeActionsAll", function()
          -- We use pcall to ensure the helper module is loaded safely
          local ok, helper = pcall(require, "helper")
          if ok then
            helper.code_actions_all()
          else
            vim.notify("Could not load lua/helper.lua", vim.log.levels.ERROR)
          end
        end, { desc = "Show ALL code actions from ALL sources for entire buffer" })

        --  Create the Keymap <leader>cA
        nmap("<leader>cA", "<cmd>CodeActionsAll<cr>", "[C]ode [A]ctions (Buffer)")
      end,
    })

    -- Diagnostics config
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN]  = " ",
          [vim.diagnostic.severity.INFO]  = " ",
          [vim.diagnostic.severity.HINT]  = "",
        },
      },
      virtual_text = false,
      update_in_insert = false,
      severity_sort = true,
    })
  end,
}
