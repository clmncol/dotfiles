vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"

vim.filetype.add({
	extension = {
		journal = "ledger",
		hledger = "ledger",
		ledger = "ledger",
		zsh = "sh", -- lets bashls attach for basic shell support
	},
	filename = {
		["main.journal"] = "ledger",
		["hledger.journal"] = "ledger",
	},
})
