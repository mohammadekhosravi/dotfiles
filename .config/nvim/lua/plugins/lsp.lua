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

    -- REMOVED ts_ls - using typescript-tools instead
    local servers = { "lua_ls", "gopls", "html", "cssls", "tailwindcss", "eslint" }

    for _, name in ipairs(servers) do
      local opts = {
        capabilities = capabilities,
      }

      if name == "lua_ls" then
        opts.settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            completion = { callSnippet = "Replace" },
          },
        }
      end

      if name == "gopls" then
        opts.settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
              unusedparams = true,
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

    -- ═══════════════════════════════════════════════════════════════════════
    -- DIAGNOSTIC CONFIGURATION
    -- ═══════════════════════════════════════════════════════════════════════
    -- Float settings match hover/signature_help for visual consistency
    -- ═══════════════════════════════════════════════════════════════════════
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN]  = " ",
          [vim.diagnostic.severity.INFO]  = " ",
          [vim.diagnostic.severity.HINT]  = "󰌵 ",
        },
      },
      virtual_text = false,
      update_in_insert = false,
      severity_sort = true,
      -- ─────────────────────────────────────────────────────────────────────
      -- Floating window styling (matches hover/signature_help)
      -- ─────────────────────────────────────────────────────────────────────
      float = {
        border = "rounded",
        source = true,
        header = "",
        prefix = "● ",
        focusable = true,
        max_width = math.floor(vim.o.columns * 0.7),
        max_height = math.floor(vim.o.lines * 0.4),
      },
    })

    -- ═══════════════════════════════════════════════════════════════════════
    -- LSP ATTACH CALLBACK
    -- ═══════════════════════════════════════════════════════════════════════
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        require("fidget").notify(client.name .. " attached", nil, { key = "lsp_attach_" .. client.name })

        local buf = args.buf

        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = buf, desc = desc })
        end

        -- ═══════════════════════════════════════════════════════════════════
        -- NEOVIM 0.11+ DEFAULT LSP KEYMAPS (with descriptions & customizations)
        -- ═══════════════════════════════════════════════════════════════════
        -- These override the defaults to add descriptions and our styling.
        -- Reference: :h lsp-defaults
        -- ═══════════════════════════════════════════════════════════════════

        -- ─────────────────────────────────────────────────────────────────────
        -- Hover & Signature Help
        -- ─────────────────────────────────────────────────────────────────────
        -- K (default) - Hover documentation
        map("n", "K", function()
          vim.lsp.buf.hover({
            max_width = math.floor(vim.o.columns * 0.7),
            max_height = math.floor(vim.o.lines * 0.4),
          })
        end, "LSP: Hover Documentation")

        -- <C-s> (default in insert mode) - Signature help
        map("i", "<C-s>", function()
          vim.lsp.buf.signature_help({
            max_width = math.floor(vim.o.columns * 0.7),
            max_height = math.floor(vim.o.lines * 0.4),
          })
        end, "LSP: Signature Help")

        -- ─────────────────────────────────────────────────────────────────────
        -- Navigation (defaults)
        -- ─────────────────────────────────────────────────────────────────────
        -- gd (default) - Go to definition
        map("n", "gd", vim.lsp.buf.definition, "LSP: [G]oto [D]efinition")

        -- gD (default) - Go to declaration
        map("n", "gD", vim.lsp.buf.declaration, "LSP: [G]oto [D]eclaration")

        -- gri (default) - Go to implementation
        map("n", "gri", vim.lsp.buf.implementation, "LSP: [G]oto [I]mplementation")

        -- grr (default) - Go to references
        map("n", "grr", vim.lsp.buf.references, "LSP: [G]oto [R]eferences")

        -- grt (default) - Go to type definition
        map("n", "grt", vim.lsp.buf.type_definition, "LSP: [G]oto [T]ype Definition")

        -- gO (default) - Document symbols
        map("n", "gO", vim.lsp.buf.document_symbol, "LSP: Document Symbols")

        -- ─────────────────────────────────────────────────────────────────────
        -- Code Actions & Refactoring (defaults)
        -- ─────────────────────────────────────────────────────────────────────
        -- grn (default) - Rename symbol
        map("n", "grn", vim.lsp.buf.rename, "LSP: [R]e[n]ame")

        -- gra (default) - Code action (works in normal and visual mode)
        map({ "n", "x" }, "gra", vim.lsp.buf.code_action, "LSP: Code [A]ction")

        -- ─────────────────────────────────────────────────────────────────────
        -- CTRL-] (default) - Jump to definition (tagfunc integration)
        -- ─────────────────────────────────────────────────────────────────────
        -- This is set via tagfunc by Neovim automatically, no need to remap

        -- ═══════════════════════════════════════════════════════════════════
        -- CUSTOM KEYMAPS (not Neovim defaults)
        -- ═══════════════════════════════════════════════════════════════════

        -- ─────────────────────────────────────────────────────────────────────
        -- Telescope-enhanced LSP (alternatives with better UI)
        -- ─────────────────────────────────────────────────────────────────────
        -- Pattern: <leader>gr* = enhanced version of gr* default

        -- References with Telescope UI (alternative to grr which uses quickfix)
        map("n", "<leader>grr", require("telescope.builtin").lsp_references, "LSP: References (Telescope)")

        -- ─────────────────────────────────────────────────────────────────────
        -- Call Hierarchy (understanding code flow)
        -- ─────────────────────────────────────────────────────────────────────
        -- These are invaluable for navigating and understanding codebases,
        -- especially in React where components call other components.
        --
        -- Incoming Calls: "Who calls this function/component?"
        --   Use cases:
        --   • Before refactoring: see all usages that might break
        --   • Before deleting: ensure nothing depends on this code
        --   • Debugging: find what parent component triggers re-renders
        --   Example: Cursor on <Button> → shows ProductCard, Modal, Header use it
        --
        -- Outgoing Calls: "What does this function/component call?"
        --   Use cases:
        --   • Understanding unfamiliar code: see all dependencies at a glance
        --   • Performance audit: see what expensive operations get triggered
        --   • Tracing data flow: follow function calls through the codebase
        --   Example: Cursor on ProductCard → shows it uses Button, formatPrice, etc.
        -- ─────────────────────────────────────────────────────────────────────
        map("n", "<leader>grc", require("telescope.builtin").lsp_incoming_calls,
          "LSP: Incoming [C]alls (who calls this?)")
        map("n", "<leader>grC", require("telescope.builtin").lsp_outgoing_calls,
          "LSP: Outgoing [C]alls (what does this call?)")

        -- ─────────────────────────────────────────────────────────────────────
        -- Diagnostics (floating windows matching hover style)
        -- ─────────────────────────────────────────────────────────────────────
        -- Show diagnostic float for current line
        map("n", "<leader>sd", function()
          vim.diagnostic.open_float({ scope = "line" })
        end, "LSP: [S]how [D]iagnostic (line)")

        -- Show diagnostic float for cursor position only
        map("n", "<leader>sD", function()
          vim.diagnostic.open_float({ scope = "cursor" })
        end, "LSP: [S]how [D]iagnostic (cursor)")

        -- Navigate diagnostics (all severities)
        map("n", "[d", function()
          vim.diagnostic.jump({ count = -1, float = false })
        end, "Previous Diagnostic")

        map("n", "]d", function()
          vim.diagnostic.jump({ count = 1, float = false })
        end, "Next Diagnostic")

        -- Navigate errors only (skip warnings/hints)
        map("n", "[e", function()
          vim.diagnostic.jump({
            count = -1,
            severity = vim.diagnostic.severity.ERROR,
            float = false,
          })
        end, "Previous Error")

        map("n", "]e", function()
          vim.diagnostic.jump({
            count = 1,
            severity = vim.diagnostic.severity.ERROR,
            float = false,
          })
        end, "Next Error")

        -- ─────────────────────────────────────────────────────────────────────
        -- Buffer-wide Code Actions
        -- ─────────────────────────────────────────────────────────────────────
        vim.api.nvim_buf_create_user_command(buf, "CodeActionsAll", function()
          local ok, helper = pcall(require, "helper")
          if ok then
            helper.code_actions_all()
          else
            vim.notify("Could not load lua/helper.lua", vim.log.levels.ERROR)
          end
        end, { desc = "Show ALL code actions from ALL sources for entire buffer" })

        map("n", "<leader>gra", "<cmd>CodeActionsAll<cr>", "LSP: [C]ode [A]ctions (Buffer)")
      end,
    })
  end,
}
