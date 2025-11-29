return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },

  opts = {
    on_attach = function(client, bufnr)
      -- Disable formatting (let prettier/eslint handle it)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false

      -- TypeScript specific keymaps
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "TS: " .. desc })
      end

      map("<leader>ai", "<cmd>TSToolsAddMissingImports<cr>", "Add Missing Imports")
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
        includeInlayParameterNameHints = "none",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = false,
        includeInlayVariableTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = false,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayEnumMemberValueHints = false,

        -- IMPORTANT: These enable auto-imports
        includeCompletionsForModuleExports = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithSnippetText = true,
        includeCompletionsWithInsertText = true,
        includeAutomaticOptionalChainCompletions = true,

        -- Import organization
        importModuleSpecifierPreference = "shortest",
        importModuleSpecifierEnding = "auto",
        allowTextChangesInNewFiles = true,
        providePrefixAndSuffixTextForRename = true,

        quotePreference = "auto",
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
