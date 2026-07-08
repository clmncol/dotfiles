return {
	"karb94/neoscroll.nvim",
	config = function()
		require("neoscroll").setup({
			mappings = {},
			cursor_scrolls_alone = false,
			stop_eof = false,
		})

		local neoscroll = require("neoscroll")
		vim.keymap.set({ "n", "v" }, "<C-d>", function()
			neoscroll.ctrl_d({ duration = 135 })
		end)
		vim.keymap.set({ "n", "v" }, "<C-u>", function()
			neoscroll.ctrl_u({ duration = 135 })
		end)

		-- Scrollwheel
		vim.keymap.set({ "n", "v" }, "<ScrollWheelUp>", function()
			neoscroll.scroll(-3, { move_cursor = true, duration = 50})
		end)

		vim.keymap.set({ "n", "v" }, "<ScrollWheelDown>", function()
			neoscroll.scroll(3, { move_cursor = true, duration = 50 })
		end)
	end,
}
