-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Pickers (Snacks replaces fzf-lua).
map("n", "<C-f>", function()
  Snacks.picker.git_files()
end, { desc = "Find Git Files" })
map("n", "<leader>ff", function()
  Snacks.picker.files()
end, { desc = "Find Files" })
map("n", "<leader>fg", function()
  Snacks.picker.grep()
end, { desc = "Live Grep" })
map("n", "<leader>fo", function()
  Snacks.picker.recent()
end, { desc = "Recent Files" })
map("n", "<leader>fq", function()
  Snacks.picker.qflist()
end, { desc = "Quickfix List" })
map("n", "<leader>fb", function()
  Snacks.picker.buffers()
end, { desc = "Buffers" })
map("n", "<leader>fk", function()
  Snacks.picker.keymaps()
end, { desc = "Keymaps" })
map("n", "<leader>fr", function()
  Snacks.picker.registers()
end, { desc = "Registers" })
map("n", "<leader>fm", function()
  Snacks.picker.marks()
end, { desc = "Marks" })
map("n", "<leader>fc", function()
  Snacks.picker.commands()
end, { desc = "Commands" })
