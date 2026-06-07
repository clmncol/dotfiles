return {
	{
		"ledger/vim-ledger",
		ft = "ledger",
		init = function()
			vim.g.ledger_bin = "hledger"
			vim.g.ledger_align_at = 52
			vim.g.ledger_maxwidth = 80
		end,
	},
}
