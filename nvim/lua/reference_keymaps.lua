local M = {}

M.show = function()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local function pad_right(str, target_width)
		local width = vim.fn.strdisplaywidth(str)
		if width >= target_width then
			return str
		end
		return str .. string.rep(" ", target_width - width)
	end

	-- Curated list of actions we want to display
	-- Categories align with which-key groups where applicable:
	--   find (<leader>f), git (<leader>g), buffer (<leader>b),
	--   diag (<leader>d), rename (<leader>r), lsp (g*, K, <leader>a),
	--   nav (windows/splits), fold (z*), tab (<leader>t, gt)
	local curated_keymaps = {
		-- find  (<leader>f)
		{ category = "find", desc = "Find files" },
		{ category = "find", desc = "Live grep" },
		{ category = "find", desc = "Recent files" },
		{ category = "find", desc = "Buffers" },
		{ category = "find", desc = "File symbols" },
		{ category = "find", desc = "Help tags" },
		{ category = "find", desc = "Format buffer" },
		{ category = "find", desc = "Keymaps reference" },
		{ category = "find", desc = "Markdown reference" },

		-- lsp  (gd, gD, gi, gr, K, <leader>a, <leader>rn)
		{ category = "lsp", desc = "Go to definition" },
		{ category = "lsp", desc = "Go to declaration" },
		{ category = "lsp", desc = "Go to implementation" },
		{ category = "lsp", desc = "Go to references" },
		{ category = "lsp", desc = "LSP Hover / Docs" },
		{ category = "lsp", desc = "Signature help" },
		{ category = "lsp", desc = "Code action" },
		{ category = "lsp", desc = "Rename symbol" },

		-- diag  (<leader>d, [d, ]d)
		{ category = "diag", desc = "Line diagnostic" },
		{ category = "diag", desc = "Cursor diagnostic" },
		{ category = "diag", desc = "Prev diagnostic" },
		{ category = "diag", desc = "Next diagnostic" },

		-- git  (<leader>g)
		{ category = "git", desc = "Next hunk" },
		{ category = "git", desc = "Prev hunk" },
		{ category = "git", desc = "Stage hunk" },
		{ category = "git", desc = "Reset hunk" },
		{ category = "git", desc = "Preview hunk" },
		{ category = "git", desc = "Toggle blame" },
		{ category = "git", desc = "Diff this" },

		-- buffer  (<leader>b, <Tab>)
		{ category = "buffer", desc = "Next buffer" },
		{ category = "buffer", desc = "Prev buffer" },
		{ category = "buffer", desc = "Close buffer" },
		{ category = "buffer", desc = "Close all buffers" },

		-- nav  (<C-h/j/k/l>, H/L/J/K, splits, explorer)
		{ category = "nav", desc = "Open file explorer" },
		{ category = "nav", desc = "Open parent directory" },
		{ category = "nav", desc = "Go to left window" },
		{ category = "nav", desc = "Go to right window" },
		{ category = "nav", desc = "Go to upper window" },
		{ category = "nav", desc = "Go to lower window" },
		{ category = "nav", desc = "Split vertical" },
		{ category = "nav", desc = "Split horizontal" },
		{ category = "nav", desc = "Close split window" },
		{ category = "nav", desc = "Equally size windows" },
		{ category = "nav", desc = "Increase window width" },
		{ category = "nav", desc = "Decrease window width" },
		{ category = "nav", desc = "Increase window height" },
		{ category = "nav", desc = "Decrease window height" },

		-- fold  (z*)
		{ category = "fold", desc = "Toggle fold" },
		{ category = "fold", desc = "Open fold" },
		{ category = "fold", desc = "Close fold" },
		{ category = "fold", desc = "Open all folds" },
		{ category = "fold", desc = "Close all folds" },

		-- tab  (<leader>t, gt/gT)
		{ category = "tab", desc = "New tab" },
		{ category = "tab", desc = "Next tab" },
		{ category = "tab", desc = "Prev tab" },
		{ category = "tab", desc = "Close tab" },
	}

	-- Build keymap lookup index
	local lookup = {}
	local function parse_maps(maps)
		for _, map in ipairs(maps) do
			if map.desc and map.desc ~= "" then
				-- Index mapping by its lowercase description for robust lookup
				local desc = map.desc:lower()
				if not lookup[desc] then
					lookup[desc] = {}
				end
				-- Normalize the key sequence representation for duplicate detection (lowercase)
				local norm_lhs = map.lhs:lower()
				lookup[desc][norm_lhs] = map.lhs
			end
		end
	end

	-- Scan normal mode global and buffer-local mappings
	parse_maps(vim.api.nvim_get_keymap("n"))
	parse_maps(vim.api.nvim_get_keymap("i"))
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			parse_maps(vim.api.nvim_buf_get_keymap(buf, "n"))
			parse_maps(vim.api.nvim_buf_get_keymap(buf, "i"))
		end
	end

	-- Resolve dynamic shortcuts
	local flat_results = {}
	for _, item in ipairs(curated_keymaps) do
		local keys_set = lookup[item.desc:lower()]
		if keys_set and next(keys_set) then
			local keys_list = {}
			for _, lhs in pairs(keys_set) do
				table.insert(keys_list, lhs)
			end
			-- Sort so they always display in a stable order
			table.sort(keys_list)
			local keys_str = table.concat(keys_list, ", ")

			table.insert(flat_results, {
				category = item.category,
				name = item.desc,
				keys = keys_str,
				unbound = false,
			})
		else
			table.insert(flat_results, {
				category = item.category,
				name = item.desc,
				keys = "—",
				unbound = true,
			})
		end
	end

	-- Insert group header rows between category changes
	local results = {}
	local last_category = nil
	for _, item in ipairs(flat_results) do
		if item.category ~= last_category then
			table.insert(results, {
				is_header = true,
				category = item.category,
				name = item.category,
				keys = "",
				unbound = false,
			})
			last_category = item.category
		end
		table.insert(results, item)
	end

	local CATEGORY_W = 8
	local KEYS_W = 16

	local make_display = function(entry)
		if entry.is_header then
			local label = "  ▸ " .. entry.category
			return label, { { { 0, #label }, "Title" } }
		end

		local category_part = pad_right("", CATEGORY_W)
		local keys_part = " " .. pad_right(entry.keys, KEYS_W) .. " "
		local name_part = entry.name

		local part1 = category_part .. "   " -- indent instead of category+separator
		local part2 = part1 .. keys_part .. "│ "
		local display_str = part2 .. name_part

		-- Unbound actions are visually muted/subtle
		local keys_hl = entry.unbound and "Comment" or "String"

		local highlights = {
			{ { string.len(part1), string.len(part1) + string.len(keys_part) }, keys_hl },
			{ { string.len(part1) + string.len(keys_part), string.len(part2) }, "Comment" },
		}

		return display_str, highlights
	end

	pickers
		.new({}, {
			prompt_title = "Command & Keymap Reference",
			finder = finders.new_table({
				results = results,
				entry_maker = function(entry)
					return {
						value = entry.is_header and "" or entry.keys,
						category = entry.category,
						keys = entry.keys,
						name = entry.name,
						is_header = entry.is_header or false,
						unbound = entry.unbound,
						display = make_display,
						-- Headers sort before their group; items include name for filtering
						ordinal = entry.category .. (entry.is_header and "" or " " .. entry.keys .. " " .. entry.name),
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection.is_header then
						-- no-op: selecting a group header does nothing
						return
					end
					if selection.unbound then
						vim.notify("Command '" .. selection.name .. "' is not currently bound.", vim.log.levels.WARN)
					else
						local value = selection.value
						local comma_idx = string.find(value, ",")
						if comma_idx then
							value = string.sub(value, 1, comma_idx - 1)
						end
						local keys = vim.api.nvim_replace_termcodes(value, true, true, true)
						vim.api.nvim_feedkeys(keys, "m", true)
					end
				end)
				return true
			end,
		})
		:find()
end

return M
