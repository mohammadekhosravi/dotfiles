return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		-- Filetypes that should never use LSP formatting
		local disable_filetypes = {
			c = true,
			cpp = true,
			javascript = true,
			typescript = true,
			javascriptreact = true,
			typescriptreact = true,
		}

		-- Shared format function with notification
		local function format_with_notify(bufnr, async)
			local ft = vim.bo[bufnr].filetype
			local lsp_format_opt = disable_filetypes[ft] and "never" or "fallback"

			conform.format({
				bufnr = bufnr,
				lsp_format = lsp_format_opt,
				async = async,
				timeout_ms = 500,
			}, function(err)
				if err then
					require("fidget").notify("Format failed", vim.log.levels.ERROR, { key = "format" })
				else
					require("fidget").notify("Formatted", nil, { key = "format", ttl = 2 })
				end
			end)
		end

		conform.setup({
			-- No format_on_save here - we handle it manually below
			formatters_by_ft = {
				lua = { "stylua" },

				c = { "clang-format" },
				cpp = { "clang-format" },

				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },

				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },

				css = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },

				htmldjango = { "djlint" },

				json = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
			},

			formatters = {
				djlint = {
					command = "djlint",
					args = { "-", "--reformat", "--indent", "2" },
					stdin = true,
				},
			},
			-- SHFMT CONFIGURATION
			shfmt = {
				-- -i 4 : Indent with 4 spaces
				-- -bn  : Binary operators (like && or |) start a new line
				-- -ci  : Switch cases are indented
				prepend_args = { "-i", "4", "-bn", "-ci" },
			},

			["clang-format"] = {
				prepend_args = { "-style=file", "--fallback-style=LLVM" },
			},
		})

		-- Format on save with notification
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("ConformFormatOnSave", { clear = true }),
			callback = function(args)
				if vim.bo[args.buf].filetype == "htmldjango" then
					return -- no auto format for Django
				end
				format_with_notify(args.buf, false)
			end,
		})

		-- Manual format keymap with notification
		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			format_with_notify(vim.api.nvim_get_current_buf(), true) -- async = true for keymap
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
