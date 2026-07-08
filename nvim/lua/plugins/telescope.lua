return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          file_ignore_patterns = {
            "%.git/"
          },
          mappings = {
            i = {
              ["<C-h>"] = actions.select_horizontal,
            },
            n = {
              ["<C-h>"] = actions.select_horizontal,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
          buffers = {
            sort_mru = true,
            ignore_current_buffer = false,
            mappings = {
              i = {
                ["<C-d>"] = actions.delete_buffer,
              },
              n = {
                ["d"] = actions.delete_buffer,
                ["dd"] = actions.delete_buffer,
              },
            },
          },
        },
      })

      pcall(telescope.load_extension, "fzf")
    end,
  },
}
