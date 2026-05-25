return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main", -- Crucial for Neovim v0.12 compatibility
	build = ":TSUpdate",
	lazy = false,
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		local ts = require("nvim-treesitter")

		-- Initialize core system directories
		ts.setup()
		vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")

		--  Modern replacement for 'ensure_installed'
		ts.install({
			"bash",
			"comment",
			"cpp",
			"css",
			"csv",
			"diff",
			"dockerfile",
			"gitcommit",
			"go",
			"goctl",
			"gomod",
			"gosum",
			"gotmpl",
			"gowork",
			"html",
			"htmldjango",
			"javascript",
			"jq",
			"jsdoc",
			"json",
			"json5",
			"make",
			"python",
			"typescript",
			"scss",
			"sql",
			"styled",
			"tsx",
			"xml",
			"xresources",
			"yaml",
			"c",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"markdown",
			"markdown_inline",
		})

		-- Highlighting Engine with Custom Large-File Bypass Logic
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local buf = args.buf
				local max_filesize = 100 * 1024 -- 100 KB
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))

				-- Skip highlighters if the file is too beefy
				if ok and stats and stats.size > max_filesize then
					return
				end

				-- Start the native Neovim v0.12 Treesitter engine
				pcall(vim.treesitter.start, buf)

				-- Set layout-aware indentation
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		-- Incremental Node Selection Keymaps (Native v0.12)
		-- Normal mode: enter visual mode ('v') and select the current node ('an')
		vim.keymap.set("n", "<C-space>", "van", { remap = true, desc = "TS: Init Selection" })

		-- Visual mode: expand selection to the parent node ('an')
		vim.keymap.set("x", "<C-space>", "an", { remap = true, desc = "TS: Increment Node" })

		-- Visual mode: shrink selection to the child node ('in')
		vim.keymap.set("x", "<bs>", "in", { remap = true, desc = "TS: Decrement Node" })
	end,
}
