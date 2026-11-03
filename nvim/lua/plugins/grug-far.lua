return {
	"MagicDuck/grug-far.nvim",
	keys = {
		{
			"<leader>fr",
			function()
				require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
			end,
			desc = "Replace in file",
		},
		{
			"<leader>fR",
			function()
				require("grug-far").open()
			end,
			desc = "Replace in project",
		},
		{
			"<leader>fr",
			mode = "x",
			function()
				require("grug-far").with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
			end,
			desc = "Replace selection in file",
		},
	},
	config = function()
		require("grug-far").setup({
			engines = {
				ripgrep = {
					extraArgs = "--hidden --glob=!.git",
				},
			},
		})
	end,
}
