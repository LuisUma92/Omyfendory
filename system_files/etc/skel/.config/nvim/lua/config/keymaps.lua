-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Personal remaps
vim.keymap.set("i", "<C-z>", "<Esc>")
vim.keymap.set("n", "<C-b>", ":b#<CR>")
vim.keymap.set("n", "<leader>ws", ":w<CR>:so<CR>", { desc = "save and source" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>", { desc = "save from insert mode" })
vim.keymap.set("i", "<C-d>", "<Esc>ddkA", { desc = "remove line" })

vim.keymap.set("n", "<leader>tp", ":TimerlyToggle<CR>", { desc = "Toggle pomodoro" })
-- replace the word where you where
vim.keymap.set("n", "<leader>sz", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- -- dwnzed buffers remaps
-- vim.keymap.set("n", "<leader>bD", function()
--   closeAllBuffers()
-- end, { desc = "[B]uffer [D]elete all but current" })
--
-- vim.keymap.set("n", "<leader>bd", ":bdelete<cr>", { desc = "[B]uffer [D]elete" })
-- vim.keymap.set("n", "<leader>bn", ":bnext<cr>", { desc = "[B]uffer [N]ext" })
-- vim.keymap.set("n", "<leader>bp", ":bprevious<cr>", { desc = "[B]uffer [P]revious" })

-- Undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- -- Castle inkscape
-- vim.keymap.set("i", "<C-f>", function()
--   local current_line_number = vim.fn.line(".")
--   local current_line = vim.fn.getline(".")
--   local root_directory = vim.b.vimtex.root
--
--   local command = string.format('inkscape-figures create "%s" "%s/figures"', current_line, root_directory)
--
--   local output = vim.fn.systemlist(command)
--   local output_line_count = #output
--
--   -- Replace the current line with the first line of the output
--   vim.fn.setline(current_line_number, output[1])
--
--   -- Insert the remaining lines of the output below the current line
--   for i = 2, #output do
--     vim.fn.append(current_line_number + i - 2, output[i])
--   end
--   vim.fn.cursor(current_line_number + output_line_count, 0)
--   vim.api.nvim_command("write")
-- end, { silent = true })
-- vim.keymap.set("n", "<C-f>", function()
--   local root_directory = vim.b.vimtex.root
--   local command = string.format(
--     'inkscape-figures edit "%s/figures/"', -- > /dev/null 2>&1 &",
--     root_directory
--   )
--
--   vim.fn.system(command)
--   vim.cmd("redraw!")
-- end, { silent = true })
-- Nori insert
-- vim.keymap.set("i", "<C-p>", function()
--   local root_directory = vim.b.vimtex_root
--   local command = string.format("silent exec '!nori insert \"%s\"/res/'", root_directory)
--   vim.api.nvim_command(command)
--   vim.cmd("redraw!")
-- end, { silent = true })

-- Define a function to execute the command with the current highlighted line in netrw
function OpenWithZathura()
  -- Get the current line under the cursor
  local line_number = vim.fn.line(".")

  -- Construct the command with the current line number
  local command = string.format(":!zathura %d&", line_number)
  -- Execute the command
  vim.cmd(command)
end

-- Define the key mapping
vim.api.nvim_set_keymap("n", "<leader>z", ":lua OpenWithZathura()<CR>", { noremap = true, silent = true })

function OpenWithZathuraVisual()
  -- Obtener el rango de selección visual
  local _, ls, cs = unpack(vim.fn.getpos("'<"))
  local _, le, ce = unpack(vim.fn.getpos("'>"))

  -- Obtener las líneas seleccionadas
  local lines = vim.fn.getline(ls, le)
  if #lines == 0 then
    return
  end

  -- Si la selección está en una sola línea, recortar al rango de columnas
  if #lines == 1 then
    lines[1] = string.sub(lines[1], cs, ce)
  else
    lines[1] = string.sub(lines[1], cs)
    lines[#lines] = string.sub(lines[#lines], 1, ce)
  end

  -- Unir las líneas seleccionadas
  local selected_text = table.concat(lines, "\n")

  -- Escapar comillas por seguridad
  selected_text = vim.fn.shellescape(selected_text)

  -- Construir el comando para zathura
  local command = string.format("!zathura %s&", selected_text)

  -- Ejecutar el comando
  vim.cmd(command)
end

-- Mapeo de tecla en modo visual
vim.api.nvim_set_keymap("v", "<leader>z", ":<C-u>lua OpenWithZathuraVisual()<CR>", { noremap = true, silent = true })

function dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

-- \(\SI{1.35}{cm}\)
-- \(\SI{1.35}{m/s}\)
-- \(\SI{135}{m/s}\)
-- \(\SI{2.45}{m/2}\)

-- Define a function to wrap selected text with \(\SI{...}{...}\)
function WrapSelectedTextWithMath(SI)
  -- Get the visual selection range
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  -- Get the selected text
  local selected_text = vim.api.nvim_buf_get_text(0, start_pos[2] - 1, start_pos[3] - 1, end_pos[2] - 1, end_pos[3], {})
  local text_before = vim.api.nvim_buf_get_text(0, start_pos[2] - 1, 0, start_pos[2] - 1, start_pos[3] - 1, {})
  local text_after = vim.api.nvim_buf_get_text(0, end_pos[2] - 1, end_pos[3], end_pos[2] - 1, -1, {})

  local words = {}
  local i = 1

  for word in string.gmatch(selected_text[1], "(%w+)") do
    words[i] = word
    i = i + 1
  end

  if i == 4 then
    if string.find(words[2], "%a") == nil then
      words[1] = words[1] .. "." .. words[2]
      words[2] = words[3]
    else
      words[2] = words[2] .. "/" .. words[3]
    end
  elseif i == 5 then
    words[1] = words[1] .. "." .. words[2]
    words[2] = words[3] .. "/" .. words[4]
  end
  -- Replace the selected text with \(\SI{...}{...}\)
  local wrapped_text
  if SI == true then
    wrapped_text = text_before[1] .. "\\(\\SI{" .. words[1] .. "}{" .. words[2] .. "}\\)" .. text_after[1]
  else
    wrapped_text = text_before[1] .. "\\(" .. selected_text[1] .. "\\)" .. text_after[1]
  end
  -- local end_col = math.min(end_pos[3], #selected_text[#selected_text] + 1)
  -- Replace the selected text with the wrapped text
  vim.api.nvim_buf_set_text(0, start_pos[2] - 1, 0, end_pos[2], 0, {})

  local end_col = #wrapped_text
  -- vim.api.nvim_buf_set_text(
  vim.api.nvim_buf_set_lines(
    0,
    start_pos[2] - 1,
    -- 0,
    start_pos[2] - 1,
    -- end_col,
    false,
    { wrapped_text }
  )
  -- Adjust the cursor position
  -- vim.fn.cursor(start_pos[2], start_pos[3] + 5)
end

-- Define the key mapping for the function
vim.keymap.set("v", "<leader>i", ":lua WrapSelectedTextWithMath(true)<CR>")
vim.keymap.set("v", "<leader>m", ":lua WrapSelectedTextWithMath(false)<CR>")

vim.keymap.set("n", "<leader>c", function()
  local line = vim.api.nvim_get_current_line()
  local filename = line:match("{(.-)}")
  if filename then
    local file = io.open(filename, "w")
    if file then
      file:close()
      print("Created file: " .. filename)
    else
      print("Error: Could not create file: " .. filename)
    end
  else
    print("No text found inside")
  end
end)
