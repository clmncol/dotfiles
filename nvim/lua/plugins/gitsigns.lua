return {
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				on_attach = function(bufnr)
					local gs = require("gitsigns")
					local opts = { buffer = bufnr, silent = true }
					local extend = function(desc)
						return vim.tbl_extend("force", opts, { desc = desc })
					end

					vim.keymap.set("n", "]h", gs.next_hunk, extend("Next hunk"))
					vim.keymap.set("n", "[h", gs.prev_hunk, extend("Prev hunk"))
					vim.keymap.set("n", "<leader>gs", gs.stage_hunk, extend("Stage hunk"))
					vim.keymap.set("n", "<leader>gr", gs.reset_hunk, extend("Reset hunk"))
					vim.keymap.set("n", "<leader>gp", gs.preview_hunk, extend("Preview hunk"))
					vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, extend("Toggle blame"))
					vim.keymap.set("n", "<leader>gd", gs.diffthis, extend("Diff this"))
				end,
			})
		end,
	},
}
