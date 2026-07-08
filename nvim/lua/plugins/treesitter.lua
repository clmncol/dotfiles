return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		init = function()
			-- Install parsers after plugin is loaded
			vim.api.nvim_create_autocmd("User", {
				pattern = "LazyDone",
				once = true,
				callback = function()
					require("nvim-treesitter").install({
						"bash",
						"go",
						"json",
						"ledger",
						"lua",
						"markdown",
						"markdown_inline",
						"python",
						"rust",
						"toml",
						"vim",
						"vimdoc",
						"yaml",
					})
				end,
			})
		end,
		config = function()
			-- Register hledger to use ledger treesitter parser
			vim.treesitter.language.register("ledger", "hledger")

			-- Enable highlighting for specific filetypes
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"bash",
					"go",
					"json",
					"lua",
					"markdown",
					"python",
					"rust",
					"toml",
					"vim",
					"yaml",
					"ledger",
					"hledger",
				},
				callback = function()
					vim.treesitter.start()
				end,
			})

			-- Enable ledger highlighting with vim regex
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "ledger", "hledger", "journal" },
				callback = function()
					vim.opt_local.syntax = "on"
				end,
			})
		end,
	},
}
