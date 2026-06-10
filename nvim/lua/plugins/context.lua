return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "BufReadPre", -- or lazy load it as needed
  opts = {
    enable = true,            -- Enable this plugin
    max_lines = 3,            -- How many lines the context window should take up
    trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded
    mode = 'cursor',          -- Line used to calculate context: 'cursor' or 'topline'
  }
}
