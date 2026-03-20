local map = vim.keymap.set

local nav_opts = { noremap = true, silent = true }
for _, mode in ipairs({ "n", "x", "o" }) do
  map(mode, "i", "k", nav_opts)
  map(mode, "j", "h", nav_opts)
  map(mode, "k", "j", nav_opts)
end
map("n", "h", "i", nav_opts)

map("n", "<leader>e", "<cmd>Neotree filesystem reveal left toggle<CR>", {
  silent = true,
  desc = "Toggle file browser",
})

map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", {
  silent = true,
  desc = "Find files",
})

map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", {
  silent = true,
  desc = "Live grep",
})
