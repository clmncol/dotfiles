local M = {}

M.show = function()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local markdown_formats = {
    {
      name = "H1 Header",
      syntax = "# Header",
      value = "# ",
      hls = {
        { { 0, 2 }, "Special" },
        { { 2, 8 }, "Title" },
      }
    },
    {
      name = "H2 Header",
      syntax = "## Header",
      value = "## ",
      hls = {
        { { 0, 3 }, "Special" },
        { { 3, 9 }, "Title" },
      }
    },
    {
      name = "H3 Header",
      syntax = "### Header",
      value = "### ",
      hls = {
        { { 0, 4 }, "Special" },
        { { 4, 10 }, "Title" },
      }
    },
    {
      name = "Bold",
      syntax = "**text**",
      value = "**text**",
      hls = {
        { { 0, 2 }, "Special" },
        { { 2, 6 }, "Type" },
        { { 6, 8 }, "Special" },
      }
    },
    {
      name = "Italic",
      syntax = "*text*",
      value = "*text*",
      hls = {
        { { 0, 1 }, "Special" },
        { { 1, 5 }, "Type" },
        { { 5, 6 }, "Special" },
      }
    },
    {
      name = "Strikethrough",
      syntax = "~~text~~",
      value = "~~text~~",
      hls = {
        { { 0, 2 }, "Special" },
        { { 2, 6 }, "Comment" },
        { { 6, 8 }, "Special" },
      }
    },
    {
      name = "Link",
      syntax = "[text](url)",
      value = "[text](url)",
      hls = {
        { { 0, 1 }, "Delimiter" },
        { { 1, 5 }, "Identifier" },
        { { 5, 7 }, "Delimiter" },
        { { 7, 10 }, "Underlined" },
        { { 10, 11 }, "Delimiter" },
      }
    },
    {
      name = "WikiLink",
      syntax = "[[link]]",
      value = "[[link]]",
      hls = {
        { { 0, 2 }, "Delimiter" },
        { { 2, 6 }, "Identifier" },
        { { 6, 8 }, "Delimiter" },
      }
    },
    {
      name = "Image",
      syntax = "![alt](url)",
      value = "![alt](url)",
      hls = {
        { { 0, 2 }, "Delimiter" },
        { { 2, 5 }, "Identifier" },
        { { 5, 7 }, "Delimiter" },
        { { 7, 10 }, "Underlined" },
        { { 10, 11 }, "Delimiter" },
      }
    },
    {
      name = "Code Block",
      syntax = "```lang ... ```",
      value = "```\n\n```",
      hls = {
        { { 0, 3 }, "Delimiter" },
        { { 3, 7 }, "Keyword" },
        { { 7, 12 }, "Comment" },
        { { 12, 15 }, "Delimiter" },
      }
    },
    {
      name = "Inline Code",
      syntax = "`code`",
      value = "`code`",
      hls = {
        { { 0, 1 }, "Delimiter" },
        { { 1, 5 }, "String" },
        { { 5, 6 }, "Delimiter" },
      }
    },
    {
      name = "Blockquote",
      syntax = "> text",
      value = "> ",
      hls = {
        { { 0, 2 }, "Special" },
        { { 2, 6 }, "Comment" },
      }
    },
    {
      name = "Horizontal Rule",
      syntax = "---",
      value = "---\n",
      hls = {
        { { 0, 3 }, "Special" },
      }
    },
    {
      name = "Table",
      syntax = "| Header 1 | Header 2 |",
      value = "| Header 1 | Header 2 |\n|---|---|\n| Cell 1 | Cell 2 |",
      hls = {
        { { 0, 1 }, "Delimiter" },
        { { 1, 11 }, "Type" },
        { { 11, 12 }, "Delimiter" },
        { { 12, 22 }, "Type" },
        { { 22, 23 }, "Delimiter" },
      }
    },
    {
      name = "Task List Item",
      syntax = "- [ ]",
      value = "- [ ] ",
      hls = {
        { { 0, 2 }, "Special" },
        { { 2, 3 }, "Delimiter" },
        { { 4, 5 }, "Delimiter" },
      }
    },
  }

  local make_display = function(entry)
    local display_str = string.format("%-20s │ %s", entry.name, entry.syntax)
    local highlights = {
      { { 21, 24 }, "Comment" },
    }

    local offset = 25
    for _, hl in ipairs(entry.hls) do
      table.insert(highlights, {
        { hl[1][1] + offset, hl[1][2] + offset },
        hl[2]
      })
    end

    return display_str, highlights
  end

  pickers.new({}, {
    prompt_title = "Markdown Reference & Templates",
    finder = finders.new_table({
      results = markdown_formats,
      entry_maker = function(entry)
        return {
          value = entry.value,
          name = entry.name,
          syntax = entry.syntax,
          hls = entry.hls,
          display = make_display,
          ordinal = entry.name .. " " .. entry.syntax,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local lines = vim.split(selection.value, "\n")
        vim.api.nvim_put(lines, "c", true, true)
      end)
      return true
    end,
  }):find()
end

return M
