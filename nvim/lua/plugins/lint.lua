return {
	{
		"mfussenegger/nvim-lint",
		config = function()
			require("lint").linters_by_ft = {
				yaml = { "actionlint" },
			}

			-- Only run actionlint on GitHub Actions workflow files
			require("lint").linters.actionlint = vim.tbl_deep_extend("force", require("lint").linters.actionlint, {
				condition = function(ctx)
					return ctx.filename:match("%.github/workflows/") ~= nil
				end,
			})

			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
}
