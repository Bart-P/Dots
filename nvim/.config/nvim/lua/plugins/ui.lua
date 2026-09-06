return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin-mocha" },
  },
  {
    "catppuccin/nvim",
    opts = { transparent_background = true },
  },
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        hover = { silent = true },
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            auto_close = true,
            jump = { close = true },
            win = { list = { keys = { ["<c-c>"] = "close" } } },
          },
        },
      },
    },
  },
}
