return {
	{
		"sainnhe/everforest",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("everforest")
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = true,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "everforest",
					globalstatus = true,
				},
			})
		end,
	},
	{
		"akinsho/bufferline.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup()
		end,
	},
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup({
				default_file_explorer = true,
				view_options = {
					show_hidden = true,
				},
			})
		end,
	},
}
