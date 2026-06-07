return {
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "ruff_format" },
					go = { "goimports", "gofmt" },
					rust = { "rustfmt" },
					sh = { "shfmt" },
					bash = { "shfmt" },
					zsh = { "shfmt" },
					json = { "jq" },
					yaml = { "yamlfmt" },
					markdown = { "prettier" },
				},
				-- format_on_save = {
				--	timeout_ms = 500,
				--	lsp_fallback = true,
				-- },
			})
		end,
	},
}
