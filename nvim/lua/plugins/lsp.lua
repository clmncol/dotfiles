return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"j-hui/fidget.nvim",
		opts = {},
	},
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua",
					"ruff",
					"goimports",
					"shfmt",
					"yamlfmt",
					"prettier",
				},
				auto_update = true,
				run_on_start = true,
			})
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"gopls",
					"pyright",
					"bashls",
					"jsonls",
					"yamlls",
					"marksman",
					"rust_analyzer",
					"harper_ls",
				},
				automatic_enable = true,
			})
		end,
	},

	{
		"b0o/schemastore.nvim",
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp", "b0o/schemastore.nvim" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local set_lsp_keymaps = function(bufnr)
				local opts = { buffer = bufnr, silent = true }
				local function extend(desc)
					return vim.tbl_extend("force", opts, { desc = desc })
				end
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, extend("Go to definition"))
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, extend("Go to declaration"))
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, extend("Go to implementation"))
				vim.keymap.set("n", "gr", vim.lsp.buf.references, extend("Go to references"))
				vim.keymap.set("n", "K", vim.lsp.buf.hover, extend("LSP Hover / Docs"))
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, extend("Rename symbol"))
				vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, extend("Code action"))
				vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, extend("Line diagnostic"))
				vim.keymap.set("n", "<leader>dc", function()
					vim.diagnostic.open_float({ scope = "cursor" })
				end, extend("Cursor diagnostic"))
				vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, extend("Signature help"))
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					set_lsp_keymaps(args.buf)
				end,
			})

			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			})

			vim.lsp.config("bashls", {
				capabilities = capabilities,
				filetypes = { "sh", "bash", "zsh" },
			})

			vim.lsp.config("rust_analyzer", {
				capabilities = capabilities,
				settings = {
					["rust-analyzer"] = {
						check = {
							command = "clippy",
						},
					},
				},
			})

			vim.lsp.config("yamlls", {
				capabilities = capabilities,
				settings = {
					yaml = {
						schemaStore = { enable = false, url = "" },
						schemas = require("schemastore").yaml.schemas(),
						validate = true,
						completion = true,
						hover = true,
					},
				},
			})

			vim.lsp.config("harper_ls", {
				capabilities = capabilities,
				settings = {
					["harper-ls"] = {
						markdown = {
							IgnoreLinkTitle = false,
						},
						linters = {
							SpellCheck = true,
							WrongApostrophe = false,
							LongSentences = true,
							RepeatedWords = true,
						},
					},
				},
			})

			vim.lsp.config("marksman", {
				capabilities = capabilities,
				filetypes = { "markdown" },
				root_dir = function(bufnr, on_dir)
					local root = vim.fs.root(bufnr, { ".marksman.toml", ".git" }) or vim.fn.getcwd()
					on_dir(root)
				end,
			})
		end,
	},
}
