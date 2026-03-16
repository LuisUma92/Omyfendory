-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.env.PATH = "/usr/local/texlive/2025/bin/x86_64-linux:" .. vim.env.PATH
vim.opt.spellfile = {
  "$HOME/.config/nvim/spell/es.utf-8.add",
  "$HOME/.config/nvim/spell/en.utf-8.add",
}
vim.opt.spelllang = { "en", "es" }
vim.opt.spell = true

vim.g.mapleader = " "

vim.opt.filetype = "on"
vim.opt.filetype = "plugin"
vim.opt.filetype = "indent"
vim.opt.filetype = "detect"

vim.opt.foldmethod = "indent"

--vim.opt.guicursor = ""

vim.opt.number = true -- Display line number
vim.opt.relativenumber = true
vim.opt.syntax = "on"

vim.opt.tabstop = 2 -- The width of a TAB is set to 4.
-- Still it is a \t. It is just that
-- Vim will interpret it to be having
-- a width of 4.
vim.opt.shiftwidth = 2 -- Indents will have a width of 4
vim.opt.softtabstop = 2 -- Sets the number of columns for a TAB
vim.opt.expandtab = true -- Expand TABs to spaces
vim.opt.smarttab = true -- insert spaces or tabs to go to the next
-- indent of the next tabstop when the
-- cursor is at the beginning of a line

vim.api.nvim_command("autocmd FileType py setlocal ts=4 sts=4 sw=4 expandtab")

vim.opt.wrap = true

vim.opt.undodir = os.getenv("HOME") .. "/.local/state/nvim/undo"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8

vim.opt.termguicolors = true
vim.opt.colorcolumn = "80"

vim.g.netrw_altv = true
