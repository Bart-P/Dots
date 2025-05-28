return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			{ "williamboman/mason-lspconfig.nvim" },
		},
		config = function()
			require("mason").setup()

			require("mason-lspconfig").setup({
				ensure_installed = {
					"intelephense", -- PHP
					"ts_ls", -- JS/TS
					"vuels", -- Vue
					"lua_ls", -- Lua
					"bashls", -- Bash
					"pyright", -- Python
					"html", -- Html
					"cssls", -- CSS
					"tailwindcss", -- Tailwind
				},
				automatic_installation = true,
			})
		end,
	},
}
