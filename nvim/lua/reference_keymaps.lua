local M = {}

M.show = function()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

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
    { category = "Git", desc = "Diff this file" },
  }

  -- Build keymap lookup index
  local lookup = {}
  local function parse_maps(maps)
    for _, map in ipairs(maps) do
      if map.desc and map.desc ~= "" then
        -- Index mapping by its lowercase description for robust lookup
        lookup[map.desc:lower()] = map.lhs
      end
    end
  end

  -- Scan normal mode global and buffer-local mappings
  parse_maps(vim.api.nvim_get_keymap("n"))
  parse_maps(vim.api.nvim_buf_get_keymap(0, "n"))

  -- Scan insert mode mappings (e.g. for Signature Help)
  parse_maps(vim.api.nvim_get_keymap("i"))
  parse_maps(vim.api.nvim_buf_get_keymap(0, "i"))

  -- Resolve dynamic shortcuts
  local results = {}
  for _, item in ipairs(curated_keymaps) do
    local keys = lookup[item.desc:lower()]
    if keys then
      table.insert(results, {
        category = item.category,
        name = item.desc,
        keys = keys,
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
    local category_part = string.format("%-8s", entry.category)
    local keys_part = string.format(" %-12s ", entry.keys)
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
          local keys = vim.api.nvim_replace_termcodes(selection.value, true, true, true)
          vim.api.nvim_feedkeys(keys, "m", true)
        end
      end)
      return true
    end,
  }):find()
end

return M
