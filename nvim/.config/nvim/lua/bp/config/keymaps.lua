-- Yank into system clipboard - does not seem to work keeping for reference
-- vim.keymap.set({'n', 'v'}, '<C-y>', '"+y') -- yank motion
-- vim.keymap.set({'n', 'v'}, '<C-Y>', '"+Y') -- yank line
require('fzf-lua').setup({
    keymap = {
        fzf = {
            true,
            -- Use <c-q> to select all items and add them to the quickfix list
            ["ctrl-q"] = "select-all+accept",
        },
    },
})
