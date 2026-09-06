return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
        local wk = require("which-key")
		wk.add({
			{ "<leader>a", group = "AI (opencode)" },
			{ "<leader>r", group = "refactor" },
			{ "<leader>c", group = "code" },
			{ "<leader>cd", group = "diagnostic" },
			{ "<leader>cs", group = "symbol" },
			{ "<leader>f", group = "find" },
			{ "<leader>y", group = "yank to system clipboard" },
		})
	end,
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
