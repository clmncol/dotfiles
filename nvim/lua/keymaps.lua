-- Diagnostics
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Telescope
-- Telescope project searches
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "File symbols" })
vim.keymap.set("n", "<leader>fd", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>fm", function() require("reference_markdown").show() end, { desc = "Markdown reference" })
vim.keymap.set("n", "<leader>fk", function() require("reference_keymaps").show() end, { desc = "Keymaps reference" })

-- Folds
vim.keymap.set("n", "za", "za", { desc = "Toggle fold" })
vim.keymap.set("n", "zo", "zo", { desc = "Open fold" })
vim.keymap.set("n", "zc", "zc", { desc = "Close fold" })
vim.keymap.set("n", "zM", "zM", { desc = "Close all folds" })
vim.keymap.set("n", "zR", "zR", { desc = "Open all folds" })

-- Tabs (independent workspaces with their own splits)
vim.keymap.set("n", "<leader>tt", "<cmd>tabnew<cr>", { desc = "New tab" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close tab" })
vim.keymap.set("n", "gt",         "gt",               { desc = "Next tab" })
vim.keymap.set("n", "gT",         "gT",               { desc = "Prev tab" })
vim.keymap.set("n", "<leader>tn", "gt",               { desc = "Next tab" })
vim.keymap.set("n", "<leader>tp", "gT",               { desc = "Prev tab" })

-- Buffers
vim.keymap.set("n", "<leader>bc", "<cmd>bdelete<cr>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprev<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<leader>ba", "<cmd>bufdo bdelete<cr>", { desc = "Close all buffers" })
--- Code Nav
-- Cycle open files on top bar
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })

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

