return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    build = "make install_jsregexp",
  },
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    -- vimtex isn't required if using treesitter
    dependencies = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
    config = function()
      require("luasnip-latex-snippets").setup({
        use_treesitter = true,
        allow_on_markdown = true, -- whether to add snippets to markdown filetype
      })
      require("luasnip").config.setup({ enable_autosnippets = true })
      require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/lua/snippets/" } })
    end,
  },
}
