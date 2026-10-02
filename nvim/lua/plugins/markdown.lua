return {
  {
    "ixru/nvim-markdown",
    ft = "markdown",
    init = function()
      -- conceal links/emphasis, but keep the cursor line readable
      vim.g.vim_markdown_conceal = 1
      vim.g.vim_markdown_conceal_code_blocks = 0
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_new_list_item_indent = 2
      vim.g.vim_markdown_toc_autofit = 1
      -- fenced code blocks get syntax highlighting for these languages
      vim.g.vim_markdown_fenced_languages = { "python", "lua", "bash=sh", "json", "c", "cpp" }
    end,
  },
}
