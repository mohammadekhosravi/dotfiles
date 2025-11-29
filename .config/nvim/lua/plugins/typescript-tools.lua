return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },

  opts = {
    on_attach = function(client, bufnr)
      -- Disable formatting (let prettier/eslint handle it)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false

      -- keymaps helper
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "TS: " .. desc })
      end

      map("<leader>ai", "<cmd>TSToolsAddMissingImports<cr>", "Add Missing Imports")

      -- Inlay hints toggle (default: OFF for cleaner look)
      if vim.lsp.inlay_hint then
        -- Start with inlay hints disabled
        vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })

        -- Toggle inlay hints for current buffer
        map("<leader>th", function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
          local status = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }) and "enabled" or "disabled"
          vim.notify("Inlay hints " .. status, vim.log.levels.INFO)
        end, "Toggle Inlay Hints (buffer)")

        -- Toggle inlay hints globally
        map("<leader>tH", function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          local status = vim.lsp.inlay_hint.is_enabled() and "enabled" or "disabled"
          vim.notify("Inlay hints " .. status .. " (global)", vim.log.levels.INFO)
        end, "Toggle Inlay Hints (global)")
      end
    end,

    settings = {
      -- Spawn tsserver separately for better performance
      separate_diagnostic_server = true,

      -- Publish diagnostics on insert leave
      publish_diagnostic_on = "insert_leave",

      -- Expose ALL code actions
      expose_as_code_action = "all",

      -- tsserver settings
      tsserver_path = nil,
      tsserver_plugins = {},
      tsserver_max_memory = "auto",
      tsserver_format_options = {},

      tsserver_file_preferences = {
        includeInlayParameterNameHints = "all", -- "none" | "literals" | "all"
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,

        -- IMPORTANT: These enable auto-imports
        includeCompletionsForModuleExports = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithSnippetText = true,
        includeCompletionsWithInsertText = true,
        includeAutomaticOptionalChainCompletions = true,
        includeCompletionsWithObjectLiteralMethodSnippets = true,

        -- Import organization
        importModuleSpecifierPreference = "non-relative",
        importModuleSpecifierEnding = "auto",
        allowTextChangesInNewFiles = true,
        providePrefixAndSuffixTextForRename = true,

        quotePreference = "auto",             -- "auto" | "single" | "double"
        -- JSX
        jsxAttributeCompletionStyle = "auto", -- "auto" | "braces" | "none"
      },

      -- CRITICAL: Complete function calls with parentheses
      complete_function_calls = true,

      -- Include completions for module exports from packages
      include_completions_with_insert_text = true,
    },

    -- Inject capabilities from blink.cmp
    capabilities = require("blink.cmp").get_lsp_capabilities(),
  },
}
