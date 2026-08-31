-- Auto-close and auto-rename JSX/HTML tags (React / React Native / Next.js friendly)
return {
	"windwp/nvim-ts-autotag",
	event = "InsertEnter",
	ft = { "javascriptreact", "typescriptreact" },
	opts = {},
	config = function()
		require("nvim-ts-autotag").setup({})
	end,
}