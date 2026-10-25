-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Navigate by word with Option + Left/Right (macOS style)
-- Normal mode
map({ "n", "v" }, "<M-Left>", "b", { desc = "Jump backward word" })
map({ "n", "v" }, "<M-Right>", "w", { desc = "Jump forward word" })
map({ "n", "v" }, "<M-b>", "b", { desc = "Jump backward word" })
map({ "n", "v" }, "<M-f>", "w", { desc = "Jump forward word" })

-- Insert mode (jump word without exiting insert mode)
map("i", "<M-Left>", "<C-o>b", { desc = "Jump backward word" })
map("i", "<M-Right>", "<C-o>w", { desc = "Jump forward word" })
map("i", "<M-b>", "<C-o>b", { desc = "Jump backward word" })
map("i", "<M-f>", "<C-o>w", { desc = "Jump forward word" })

-- Jump to start/end of line with Command + Left/Right (macOS style)
-- Normal & Visual mode
map({ "n", "v" }, "<C-a>", "^", { desc = "Beginning of line" })
map({ "n", "v" }, "<C-e>", "$", { desc = "End of line" })
map({ "n", "v" }, "<D-Left>", "^", { desc = "Beginning of line" })
map({ "n", "v" }, "<D-Right>", "$", { desc = "End of line" })

-- Insert mode (jump to start/end without exiting insert mode)
map("i", "<C-a>", "<C-o>^", { desc = "Beginning of line" })
map("i", "<C-e>", "<C-o>$", { desc = "End of line" })
map("i", "<D-Left>", "<C-o>^", { desc = "Beginning of line" })
map("i", "<D-Right>", "<C-o>$", { desc = "End of line" })
