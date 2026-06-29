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
  local curated_keymaps = {
    -- Find & Search
    { category = "Find", desc = "Find files" },
    { category = "Find", desc = "Live grep" },
    { category = "Find", desc = "Buffers" },
    { category = "Find", desc = "Recent files" },
    { category = "Find", desc = "File symbols" },
    { category = "Find", desc = "Help tags" },
    { category = "Find", desc = "Format buffer" },
    { category = "Find", desc = "Markdown reference" },
    { category = "Find", desc = "Keymaps reference" },

    -- Navigation & Windows
    { category = "Nav", desc = "Open file explorer" },
    { category = "Nav", desc = "Open parent directory" },
    { category = "Nav", desc = "Prev buffer" },
    { category = "Nav", desc = "Next buffer" },
    { category = "Nav", desc = "Go to left window" },
    { category = "Nav", desc = "Go to lower window" },
    { category = "Nav", desc = "Go to upper window" },
    { category = "Nav", desc = "Go to right window" },
    { category = "Nav", desc = "Decrease window width" },
    { category = "Nav", desc = "Increase window width" },
    { category = "Nav", desc = "Decrease window height" },
    { category = "Nav", desc = "Increase window height" },
    { category = "Nav", desc = "Split vertical" },
    { category = "Nav", desc = "Split horizontal" },
    { category = "Nav", desc = "Close split window" },
    { category = "Nav", desc = "Equally size windows" },

    -- LSP / Diagnostics
    { category = "LSP", desc = "Go to definition" },
    { category = "LSP", desc = "Go to declaration" },
    { category = "LSP", desc = "Go to implementation" },
    { category = "LSP", desc = "Go to references" },
    { category = "LSP", desc = "LSP Hover / Docs" },
    { category = "LSP", desc = "Rename symbol" },
    { category = "LSP", desc = "Code action" },
    { category = "LSP", desc = "Line diagnostic" },
    { category = "LSP", desc = "Cursor diagnostic" },
    { category = "LSP", desc = "Prev diagnostic" },
    { category = "LSP", desc = "Next diagnostic" },
    { category = "LSP", desc = "Signature help" },

    -- Git (Gitsigns)
    { category = "Git", desc = "Next hunk" },
    { category = "Git", desc = "Prev hunk" },
    { category = "Git", desc = "Stage hunk" },
    { category = "Git", desc = "Reset hunk" },
    { category = "Git", desc = "Preview hunk" },
    { category = "Git", desc = "Toggle blame" },
    { category = "Git", desc = "Diff this" },
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
  local results = {}
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

      table.insert(results, {
        category = item.category,
        name = item.desc,
        keys = keys_str,
        unbound = false,
      })
    else
      table.insert(results, {
        category = item.category,
        name = item.desc,
        keys = "—",
        unbound = true,
      })
    end
  end

  local make_display = function(entry)
    local category_part = pad_right(entry.category, 8)
    local keys_part = " " .. pad_right(entry.keys, 16) .. " "
    local name_part = entry.name

    local part1 = category_part .. " │"
    local part2 = part1 .. keys_part .. "│ "
    local display_str = part2 .. name_part

    -- Unbound actions are visually muted/subtle
    local keys_hl = entry.unbound and "Comment" or "String"

    local highlights = {
      { { 0, string.len(category_part) }, "Keyword" },
      { { string.len(category_part), string.len(part1) }, "Comment" },
      { { string.len(part1), string.len(part1) + string.len(keys_part) }, keys_hl },
      { { string.len(part1) + string.len(keys_part), string.len(part2) }, "Comment" },
    }

    return display_str, highlights
  end

  pickers.new({}, {
    prompt_title = "Command & Keymap Reference",
    finder = finders.new_table({
      results = results,
      entry_maker = function(entry)
        return {
          value = entry.keys,
          category = entry.category,
          keys = entry.keys,
          name = entry.name,
          unbound = entry.unbound,
          display = make_display,
          ordinal = entry.category .. " " .. entry.keys .. " " .. entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
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
  }):find()
end

return M
