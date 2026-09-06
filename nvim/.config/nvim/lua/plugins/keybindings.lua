return {
  {
    "folke/todo-comments.nvim",
    keys = {
      {
        "<leader>ft",
        function()
          Snacks.picker.todo_comments()
        end,
        desc = "TODOs",
      },
    },
  },
  {
    "folke/flash.nvim",
    keys = {
      {
        "gni",
        function()
          require("flash").treesitter({
            actions = {
              ["."] = "next",
              [","] = "next",
              ["-"] = "prev",
            },
          })
        end,
        desc = "Treesitter Incremental Selection",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "<leader>rn", vim.lsp.buf.rename, desc = "Rename" },
            { "gl", vim.diagnostic.open_float, desc = "Line Diagnostics" },
            {
              "<leader>cdp",
              function()
                vim.diagnostic.jump({ count = -1, float = true })
              end,
              desc = "Previous Diagnostic",
            },
            {
              "<leader>cdn",
              function()
                vim.diagnostic.jump({ count = 1, float = true })
              end,
              desc = "Next Diagnostic",
            },
            {
              "<leader>cda",
              function()
                Snacks.picker.diagnostics_buffer()
              end,
              desc = "Buffer Diagnostics",
            },
            {
              "gi",
              function()
                Snacks.picker.lsp_implementations()
              end,
              desc = "Goto Implementation",
            },
            {
              "<leader>csd",
              function()
                Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter })
              end,
              desc = "Document Symbols",
            },
            {
              "<leader>csw",
              function()
                Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter })
              end,
              desc = "Workspace Symbols",
            },
          },
        },
      },
    },
  },
}
