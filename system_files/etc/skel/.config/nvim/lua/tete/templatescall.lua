vim.api.nvim_create_user_command("InitPartial", "!wl-copy < ~/.config/mytex/templates/PN-YYYY-IIIC.tex", {})

vim.api.nvim_create_user_command("InitPropousal", "!wl-copy < ~/.config/mytex/templates/PartialPropousal.tex", {})

vim.api.nvim_create_user_command("InitTestItem", "!wl-copy < ~/.config/mytex/templates/TNNE000.tex", {})

vim.api.nvim_create_user_command("InitMain", "!wl-copy < ~/.config/mytex/templates/00AA.tex", {})

vim.api.nvim_create_user_command("InitText", "!wl-copy < ~/.config/mytex/templates/C0S0-000.tex", {})

vim.api.nvim_create_user_command("InitBookExercise", "!wl-copy < ~/.config/mytex/templates/book-C00S00P000.tex", {})

vim.api.nvim_create_user_command("InitArtFicha", "!wl-copy < ~/.config/mytex/templates/lect.tex", {})
