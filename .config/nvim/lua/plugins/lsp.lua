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

		local servers =
			{ "bashls", "lua_ls", "gopls", "html", "cssls", "tailwindcss", "eslint", "ts_ls", "pyright", "clangd" }

		for _, name in ipairs(servers) do
			local opts = {
				capabilities = capabilities,
			}

			if name == "bashls" then
				opts.filetypes = { "sh", "bash", "zsh" }
				opts.settings = {
					bashIde = {
						-- recursive scanning for shell scripts
						globPattern = "**/*@(.sh|.inc|.bash|.command)",
					},
				}
			end

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

			if name == "pyright" then
				opts.settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace", -- "openFilesOnly" is faster for large repos
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

			if name == "ts_ls" then
				opts.settings = {
					-- We apply the same settings to both javascript and typescript
					javascript = {
						inlayHints = {
							includeInlayEnumMemberValueHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayParameterNameHints = "all", -- "none" | "literals" | "all"
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayVariableTypeHintsWhenTypeMatchesName = false,
						},
					},
					typescript = {
						inlayHints = {
							includeInlayEnumMemberValueHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayParameterNameHints = "all", -- "none" | "literals" | "all"
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayVariableTypeHintsWhenTypeMatchesName = false,
						},
					},
				}

				-- Ported generic preferences to init_options (standard for ts_ls)
				opts.init_options = {
					preferences = {
						importModuleSpecifierPreference = "non-relative",
						importModuleSpecifierEnding = "auto",
						quotePreference = "auto",
						jsxAttributeCompletionStyle = "auto",
						allowTextChangesInNewFiles = true,
						providePrefixAndSuffixTextForRename = true,
						includeCompletionsForModuleExports = true,
						includeCompletionsForImportStatements = true,
						includeCompletionsWithInsertText = true,
						includeAutomaticOptionalChainCompletions = true,
					},
				}
			end

			if name == "clangd" then
				opts.cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
				}
			end

			if name == "tailwindcss" then
				opts.settings = {
					tailwindCSS = {
						-- Recognize Mantine's `classNames` prop in addition to the
						-- default class/className/classList/ngClass/class:list.
						classAttributes = {
							"class",
							"className",
							"classNames",
							"classList",
							"class:list",
							"ngClass",
						},
						experimental = {
							-- Resolve classes inside `classNames={{ key: '...' }}`
							-- object values. Outer regex: capture the object body.
							-- Inner regex: capture each quoted class string.
							classRegex = {
								{
									"classNames\\s*=\\s*\\{\\s*\\{([\\s\\S]*?)\\}\\s*\\}",
									"[\"'`]([^\"'`]*)[\"'`]",
								},
							},
						},
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
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.INFO] = " ",
					[vim.diagnostic.severity.HINT] = "󰌵 ",
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
				if not client then
					return
				end

				require("fidget").notify(client.name .. " attached", nil, { key = "lsp_attach_" .. client.name })

				local buf = args.buf

				local map = function(mode, keys, func, desc)
					vim.keymap.set(mode, keys, func, { buffer = buf, desc = desc })
				end

				-- ═══════════════════════════════════════════════════════════════════
				-- ADDED: SPECIFIC TYPESCRIPT SETUP (Previously in typescript-tools)
				-- ═══════════════════════════════════════════════════════════════════
				if client.name == "ts_ls" then
					-- Disable formatting (let prettier/eslint handle it)
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false

					-- Replicate "Add Missing Imports" functionality
					-- TSToolsAddMissingImports is not available, so we use the native code action
					map("n", "<leader>ai", function()
						vim.lsp.buf.code_action({
							apply = true,
							context = {
								only = { "source.addMissingImports.ts" },
								diagnostics = {},
							},
						})
					end, "TS: Add Missing Imports")

					-- Replicate "Toggle Inlay Hints" specifically for TS if needed,
					-- though your global toggle below handles it fine.

					-- Inlay hints (start disabled as per your previous config)
					if vim.lsp.inlay_hint then
						vim.lsp.inlay_hint.enable(false, { bufnr = buf })
					end
				end

				if client.name == "pyright" then
					-- DISABLE FORMATTING
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
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
				if client.name == "clangd" then
					map("n", "K", "<cmd>norm! K<cr>", "Open Man Page")
				else
					map("n", "K", function()
						vim.lsp.buf.hover({
							max_width = math.floor(vim.o.columns * 0.7),
							max_height = math.floor(vim.o.lines * 0.4),
						})
					end, "LSP: Hover Documentation")
				end

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
				--    Use cases:
				--    • Before refactoring: see all usages that might break
				--    • Before deleting: ensure nothing depends on this code
				--    • Debugging: find what parent component triggers re-renders
				--    Example: Cursor on <Button> → shows ProductCard, Modal, Header use it
				--
				-- Outgoing Calls: "What does this function/component call?"
				--    Use cases:
				--    • Understanding unfamiliar code: see all dependencies at a glance
				--    • Performance audit: see what expensive operations get triggered
				--    • Tracing data flow: follow function calls through the codebase
				--    Example: Cursor on ProductCard → shows it uses Button, formatPrice, etc.
				-- ─────────────────────────────────────────────────────────────────────
				map(
					"n",
					"<leader>grc",
					require("telescope.builtin").lsp_incoming_calls,
					"LSP: Incoming [C]alls (who calls this?)"
				)
				map(
					"n",
					"<leader>grC",
					require("telescope.builtin").lsp_outgoing_calls,
					"LSP: Outgoing [C]alls (what does this call?)"
				)

				-- ─────────────────────────────────────────────────────────────────────
				-- Inlay Hints (Moved here to be global for all LSPs)
				-- ─────────────────────────────────────────────────────────────────────
				if vim.lsp.inlay_hint then
					-- Toggle inlay hints for current buffer
					map("n", "<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
						local status = vim.lsp.inlay_hint.is_enabled({ bufnr = buf }) and "enabled" or "disabled"
						vim.notify("Inlay hints " .. status, vim.log.levels.INFO)
					end, "Toggle Inlay Hints (buffer)")

					-- Toggle inlay hints globally
					map("n", "<leader>tH", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
						local status = vim.lsp.inlay_hint.is_enabled() and "enabled" or "disabled"
						vim.notify("Inlay hints " .. status .. " (global)", vim.log.levels.INFO)
					end, "Toggle Inlay Hints (global)")
				end

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
