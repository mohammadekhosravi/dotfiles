return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
		"saghen/blink.cmp",
	},
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- Use new vim.lsp.config interface
		vim.lsp.config.lua_ls = { capabilities = capabilities }
		vim.lsp.config.gopls = { capabilities = capabilities }
		vim.lsp.config.ts_ls = { capabilities = capabilities }
		vim.lsp.config.html = { capabilities = capabilities }
		vim.lsp.config.cssls = { capabilities = capabilities }
		vim.lsp.config.tailwindcss = { capabilities = capabilities }

		-- Start servers
		for name, cfg in pairs(vim.lsp.config) do
			local def = require("lspconfig.configs")[name]
			if def and def.default_config and def.default_config.cmd then
				vim.lsp.start({
					name = name,
					cmd = def.default_config.cmd,
					config = cfg,
				})
			end
		end


		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client then return end

				local nmap = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = args.buf, desc = desc and ("LSP: " .. desc) })
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
				nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
				nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
				nmap("<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, "[W]orkspace [L]ist Folders")

				-- format on save if supported
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = args.buf,
						callback = function()
							vim.lsp.buf.format({
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
