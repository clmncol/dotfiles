return {
	{
		"mfussenegger/nvim-dap",
		keys = {
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
			{ "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional breakpoint" },
			{ "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
			{ "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
			{ "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
			{ "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
			{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
			{ "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
			{ "<leader>dui", function() require("dapui").toggle() end, desc = "DAP UI" },
			{ "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Hover value" },
		},
		config = function()
			local dap = require("dap")

			dap.adapters.delve = {
				type = "server",
				port = "${port}",
				executable = {
					command = "dlv",
					args = { "dap", "-l", "127.0.0.1:${port}" },
				},
			}

			-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
			dap.configurations.go = {
				{
					type = "delve",
					name = "Debug",
					request = "launch",
					program = "${file}",
				},
				{
					type = "delve",
					name = "Debug test",
					request = "launch",
					mode = "test",
					program = "${file}",
				},
				{
					type = "delve",
					name = "Debug test (go.mod)",
					request = "launch",
					mode = "test",
					program = "./${relativeFileDirname}",
				},
				{
					type = "delve",
					name = "Attach to process",
					mode = "local",
					request = "attach",
					processId = require("dap.utils").pick_process,
				},
				{
					type = "delve",
					name = "Debug package",
					request = "launch",
					mode = "debug",
					program = "${fileDirname}",
				},
				{
					type = "delve",
					name = "Debug (args + terminal)",
					request = "launch",
					mode = "debug",
					program = "${workspaceFolder}",
					args = function()
						local args_str = vim.fn.input("Args: ")
						return vim.split(args_str, " ", { trimempty = true })
					end,
					console = "integratedTerminal",
				},
			}

			-- DAP UI
			require("dapui").setup()

			dap.listeners.before.attach.dapui_config = function()
				require("dapui").open()
			end
			dap.listeners.before.launch.dapui_config = function()
				require("dapui").open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				require("dapui").close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				require("dapui").close()
			end

			-- Virtual text
			require("nvim-dap-virtual-text").setup()
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "nvim-neotest/nvim-nio" },
	},
	{
		"theHamsta/nvim-dap-virtual-text",
	},
}
