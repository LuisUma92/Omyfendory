return {
  -- LSP
  {
    "neovim/nvim-lspconfig",
    cmd = { "LspInfo", "LspInstall", "LspStart" },
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason-lspconfig.nvim" },
    },
    opts = {
      servers = {
        texlab = {
          keys = {
            { "<Leader>K", "<plug>(vimtex-doc-package)", desc = "Vimtex Docs", silent = true },
          },
        },
      },
    },
    -- {
    --   "hinell/lsp-timeout.nvim",
    --   dependencies = { "neovim/nvim-lspconfig" },
    -- },
    -- config = function()
    --   -- This is where all the LSP shenanigans will live
    --   local lsp_zero = require('lsp-zero')
    --   lsp_zero.extend_lspconfig()

    --   --- if you want to know more about lsp-zero and mason.nvim
    --   --- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md
    --   lsp_zero.on_attach(function(client, bufnr)
    --     -- see :help lsp-zero-keybindings
    --     -- to learn the available actions
    --     lsp_zero.default_keymaps({buffer = bufnr})
    --   end)

    --   require('mason-lspconfig').setup({
    --     ensure_installed = {},
    --     handlers = {
    --       lsp_zero.default_setup,
    --       lua_ls = function()
    --         -- (Optional) Configure lua language server for neovim
    --         local lua_opts = lsp_zero.nvim_lua_ls()
    --         require('lspconfig').lua_ls.setup(lua_opts)
    --       end,
    --     }
    --   })
    -- end
  },
}
