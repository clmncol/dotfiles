return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")
			wk.setup({})
			wk.add({
				{ "<leader>b", group = "buffer" },
				{ "<leader>c", group = "code" },
				{ "<leader>d", group = "diagnostics" },
				{ "<leader>f", group = "find/format" },
				{ "<leader>g", group = "git" },
				{ "<leader>H", group = "hledger" },
				{ "<leader>l", group = "ledger" },
				{ "<leader>r", group = "rename" },
			})
		end,
	},
}
