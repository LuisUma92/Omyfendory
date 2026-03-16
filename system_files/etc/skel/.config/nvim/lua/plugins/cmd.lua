return {
  {
    "saghen/blink.cmp",
    dependencies = { "L3MON4D3/LuaSnip", version = "v2.*" },
    opts = {
      completion = {
        accept = {
          -- experimental auto-brackets support
          auto_brackets = {
            enabled = false,
          },
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
        ghost_text = {
          enabled = false,
        },
      },
      snippets = {
        preset = "luasnip",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100, -- show at a higher priority than lsp
          },
        },
      },
      keymap = {
        preset = "enter",
        ["<C-y>"] = { "select_and_accept" },
        ["<C-Tab>"] = {
          "select_and_accept",
          "fallback",
        },
        ["<Tab>"] = {
          "snippet_forward",
          "select_and_accept",
          "fallback",
        },
      },
    },
  },
}
