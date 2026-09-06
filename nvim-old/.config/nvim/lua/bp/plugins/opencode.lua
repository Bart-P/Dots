return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
    }

    -- Required for `opts.events.reload`.
    vim.o.autoread = true
    local key = vim.keymap

    -- Recommended/example keymaps.
    key.set({ "n", "x" }, "<C-a>",      function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode" })
    key.set({ "n", "x" }, "<C-x>",      function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
    key.set({ "n", "x" }, "<leader>aq", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode" })
    key.set("n"         , "<leader>ax", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
    key.set({ "n", "x" }, "<leader>aa", function() require("opencode").prompt("@this") end,                   { desc = "Add to opencode" })
    key.set({ "n", "t" }, "<leader>at", function() require("opencode").toggle() end,                          { desc = "Toggle opencode" })
    key.set("n",          "<S-C-u>",    function() require("opencode").command("session.half.page.up") end,   { desc = "opencode half page up" })
    key.set("n",          "<S-C-d>",    function() require("opencode").command("session.half.page.down") end, { desc = "opencode half page down" })
    -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
    key.set('n', '+', '<C-a>', { desc = 'Increment', noremap = true })
    key.set('n', '-', '<C-x>', { desc = 'Decrement', noremap = true })
  end,
}
