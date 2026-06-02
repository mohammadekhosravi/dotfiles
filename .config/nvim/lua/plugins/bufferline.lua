return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons", "moll/vim-bbye" },
	config = function()
		require("bufferline").setup({
			options = {
				mode = "buffers",
				close_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
				max_name_length = 30,
				max_prefix_length = 30, -- prefix used when a buffer is de-duplicated
			},
		})

		-- move buffer position
		vim.keymap.set("n", "<A-,>", "<Cmd>BufferLineMovePrev<CR>", { desc = "Move buffer left" })
		vim.keymap.set("n", "<A-.>", "<Cmd>BufferLineMoveNext<CR>", { desc = "Move buffer right" })

		-- cycle in visual bufferline order
		vim.keymap.set("n", "H", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
		vim.keymap.set("n", "L", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
	end,
}
