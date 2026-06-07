-- Diagnostics
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Telescope
-- Telescope project searches
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "File symbols" })
vim.keymap.set("n", "<leader>fd", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Format buffer" })
--- Code Nav
-- Cycle open files on top bar
vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })

-- Jump between active split panes
vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })

-- Resize active splits on home row
vim.keymap.set("n", "H", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "L", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
vim.keymap.set("n", "K", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "J", "<cmd>resize +2<cr>", { desc = "Increase window height" })

-- Reset split window sizes to equal
vim.keymap.set("n", "<leader>=", "<C-w>=", { desc = "Equally size windows" })

-- Create split windows
vim.keymap.set("n", "<leader>v", "<cmd>vsplit<cr>", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>h", "<cmd>split<cr>", { desc = "Split horizontal" })

-- Close current split window
vim.keymap.set("n", "<leader>q", "<cmd>close<cr>", { desc = "Close split window" })
--- end Code Nav

-- File explorer
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Open file explorer" })
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

