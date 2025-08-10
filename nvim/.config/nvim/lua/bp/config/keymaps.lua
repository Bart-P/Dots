require('fzf-lua').setup({
    keymap = {
        fzf = {
            true,
            -- Use <c-q> to select all items and add them to the quickfix list
            ["ctrl-q"] = "select-all+accept",
        },
    },
})
