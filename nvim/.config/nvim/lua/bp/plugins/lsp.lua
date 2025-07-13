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
					"vue_ls", -- Vue
					"vtsls", -- Vue specific TS Server
					"lua_ls", -- Lua
					"bashls", -- Bash
					"pyright", -- Python
					"html", -- Html
					"cssls", -- CSS
					"tailwindcss", -- Tailwind
				},
				automatic_installation = true,
			})

			-- TODO: intelephense license?
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local function on_attach(_, bufnr) -- first arg was client, if ever needed
				require("lsp_signature").on_attach({
					bind = true,
					handler_opts = {
						border = "rounded",
					},
					hint_prefix = "",
					hint_enable = true,
				}, bufnr)

				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end
				local fzf = require("fzf-lua")

				-- Default LSP mappings
				map("n", "K", vim.lsp.buf.hover, "Hover docs")
				map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename")
				map("n", "<leader>ca", fzf.lsp_code_actions, "Code actions")
				map("n", "gl", vim.diagnostic.open_float, "Line diagnostics")
				map("n", "<leader>dp", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, "Prev diagnostic")
				map("n", "<leader>dn", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, "Next diagnostic")
				map("n", "<leader>da", fzf.lsp_document_diagnostics, "All buffer diagnostics")

				-- FZF-Lua powered LSP functions
				map("n", "gd", fzf.lsp_definitions, "Go to definition (fzf)")
				map("n", "gr", fzf.lsp_references, "References (fzf)")
				map("n", "gi", fzf.lsp_implementations, "Implementations (fzf)")
				map("n", "<leader>sd", fzf.lsp_document_symbols, "Document symbols (fzf)")
				map("n", "<leader>sw", fzf.lsp_workspace_symbols, "Workspace symbols (fzf)")
			end

			local vue_language_server_path = vim.fn.stdpath("data")
				.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
			local vue_plugin = {
				name = "@vue/typescript-plugin",
				location = vue_language_server_path,
				languages = { "vue" },
				configNamespace = "typescript",
			}
			local vtsls_config = {
				settings = {
					vtsls = {
						tsserver = {
							globalPlugins = {
								vue_plugin,
							},
						},
					},
				},
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
			}

			local vue_ls_config = {
				on_init = function(client)
					client.handlers["tsserver/request"] = function(_, result, context)
						local clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
						if #clients == 0 then
							vim.notify(
								"Could not find `vtsls` lsp client, `vue_ls` would not work without it.",
								vim.log.levels.ERROR
							)
							return
						end
						local ts_client = clients[1]

						local param = unpack(result)
						local id, command, payload = unpack(param)
						ts_client:exec_cmd({
							title = "vue_request_forward", -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
							command = "typescript.tsserverRequest",
							arguments = {
								command,
								payload,
							},
						}, { bufnr = context.bufnr }, function(_, r)
							local response_data = { { id, r.body } }
							---@diagnostic disable-next-line: param-type-mismatch
							client:notify("tsserver/response", response_data)
						end)
					end
				end,
			}
			-- nvim 0.11 or above
			vim.lsp.config("vtsls", vtsls_config)
			vim.lsp.config("vue_ls", vue_ls_config)
			vim.lsp.enable({ "vtsls", "vue_ls" })

			-- intelephense
			vim.lsp.config("intelephense", {
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Bash
			lspconfig.bashls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Python
			lspconfig.pyright.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- CSS
			lspconfig.cssls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- HTML
			lspconfig.html.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Tailwind
			lspconfig.tailwindcss.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})
		end,
	},
}
