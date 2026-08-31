-- Text objects around things: add/delete/replace surrounding chars (JSX tags,
-- quotes, C braces). `sa` add, `sd` delete, `sr` replace — see :h mini.surround.
return {
	"echasnovski/mini.surround",
	version = "*",
	opts = {},
	config = function()
		require("mini.surround").setup()
	end,
}