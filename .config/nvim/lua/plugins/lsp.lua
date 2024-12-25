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
		"saghen/blink.cmp",
	},
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()
		local lspconfig = require("lspconfig")

		lspconfig["lua_ls"].setup({ capabilities = capabilities })
		lspconfig["gopls"].setup({ capabilities = capabilities })
		lspconfig["ts_ls"].setup({ capabilities = capabilities })

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				-- check to see if client exist
				if not client then
					return
				end

				local nmap = function(keys, func, desc)
					if desc then
						desc = "LSP: " .. desc
					end

					---@diagnostic disable-next-line: missing-fields
					vim.keymap.set("n", keys, func, { buffer = args.buf, desc = desc })
				end

				-- keybinds
				-- default keybinds:
				-- 1. `K` maps to `vim.lsp.buf.hover()` in Normal mode.
				-- 2. `[d` and `]d` map to `vim.diagnostic.goto_prev()` and `vim.diagnostic.goto_next()`, respectively.
				-- 3. `<C-W>d` maps to `vim.diagnostic.open_float()`.

				-- NOTE: You can press `K` to go inside of opened popup in any of lsp stuff.
				-- NOTE: for example `K` show you hover text and you can press `K` again to go inside of popup text.

				-- NOTE: builtin lsp operate on tagstack and jumplist (see :h tagstach & :h jump-motions so you can use builtin shortcut with them
				-- NOTE: i.e: <CTRL-T> after go to definition returns you to original position.
				nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

				nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
				nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
				nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
				nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
				nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
				nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
				nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

				-- Lesser used LSP functionality
				nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
				nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
				nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
				nmap("<leader>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, "[W]orkspace [L]ist Folders")

				-- define formatting on save only if client supports formatting
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = args.buf,
						callback = function()
							vim.lsp.buf.format({
								-- Never request typescript-language-server for formatting
								filter = function(c)
									return c.name ~= "tsserver" and c.name ~= "ts_ls"
								end,
								bufnr = args.buf,
								id = client.id,
							})
						end,
					})
				end
			end,
		})
	end,
}
