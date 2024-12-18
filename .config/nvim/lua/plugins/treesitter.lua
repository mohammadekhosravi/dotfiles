return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    ---@diagnostic disable-next-line
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "bash",
        "comment",
        "cpp",
        "css",
        "csv",
        "diff",
        "dockerfile",
        "gitcommit",
        "go",
        "goctl",
        "gomod",
        "gosum",
        "gotmpl",
        "gowork",
        "html",
        "htmldjango",
        "javascript",
        "jq",
        "jsdoc",
        "json",
        "json5",
        "make",
        "python",
        "typescript",
        "scss",
        "sql",
        "styled",
        "tsx",
        "xml",
        "xresources",
        "yaml",
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
      },
      auto_install = false,
      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,
      -- List of parsers to ignore installing (or "all")
      ignore_install = {},
      highlight = {
        enable = true,
        -- disable = { "c", "rust" },
        -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
        disable = function(_, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false,
      },
    })
  end,
}
