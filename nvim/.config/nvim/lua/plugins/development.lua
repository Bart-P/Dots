return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {},
        intelephense = {},
        symfony_lsp = {
          filetypes = { "php", "twig" },
          root_dir = function(bufnr, on_dir)
            local root = vim.fs.root(bufnr, "composer.json")
            if
              root
              and (
                vim.uv.fs_stat(root .. "/symfony.lock")
                or vim.uv.fs_stat(root .. "/bin/console")
                or vim.uv.fs_stat(root .. "/config/bundles.php")
              )
            then
              on_dir(root)
            end
          end,
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "djlint",
        "php-cs-fixer",
        "pint",
        "twig-cs-fixer",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft.twig = { "djlint", "twig-cs-fixer" }
      opts.formatters = opts.formatters or {}
      opts.formatters.djlint = {
        prepend_args = { "--profile=jinja" },
      }
      opts.formatters["twig-cs-fixer"] = {
        exit_codes = { 0, 1 },
      }
      opts.formatters_by_ft.php = function(bufnr)
        local root = vim.fs.root(bufnr, "composer.json")
        if not root then
          return {}
        end
        if vim.fn.executable(root .. "/vendor/bin/pint") == 1 then
          return { "pint" }
        end
        if
          vim.uv.fs_stat(root .. "/.php-cs-fixer.php")
          or vim.uv.fs_stat(root .. "/.php-cs-fixer.dist.php")
          or vim.uv.fs_stat(root .. "/symfony.lock")
          or vim.uv.fs_stat(root .. "/bin/console")
          or vim.uv.fs_stat(root .. "/config/bundles.php")
        then
          return { "php_cs_fixer" }
        end
        return {}
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "php",
        "phpdoc",
        "twig",
        "vue",
        "typescript",
        "javascript",
        "html",
        "css",
        "scss",
        "json",
        "yaml",
        "xml",
        "markdown",
        "markdown_inline",
        "sql",
        "bash",
        "lua",
      },
    },
  },
}
