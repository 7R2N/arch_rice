-- ~/.config/nvim/lua/autocmds.lua

-- Ensure ~/.local/bin is on PATH
vim.env.PATH = vim.fn.expand("$HOME/.local/bin") .. ":" .. vim.env.PATH

-- Inkscape figure watcher
vim.api.nvim_create_autocmd("User", {
  pattern = "VimtexEventInitPost",
  callback = function()
    local root = vim.b.vimtex and vim.b.vimtex.root or nil
    if root then
      local fig_dir = root .. "/figures"
      if vim.fn.isdirectory(fig_dir) == 1 then
        local cmd = "/usr/local/bin/inkscape-watch"
        vim.fn.jobstart({ "bash", cmd, fig_dir }, { detach = true })
      end
    end
  end,
})

-- ============================================================
-- CASTEL-STYLE INKSCAPE FIGURE MANAGEMENT
-- Insert mode Ctrl+F: current line becomes figure name,
--   replaced with \incfig boilerplate, SVG created, Inkscape opens
-- Normal mode Ctrl+F: Telescope picker for all SVGs in figures/
-- ============================================================

local function get_root()
  if vim.b.vimtex and vim.b.vimtex.root then
    return vim.b.vimtex.root
  end
  return vim.fn.expand("%:p:h")
end

local function create_figure()
  local line = vim.api.nvim_get_current_line()
  local name = vim.trim(line)
  if name == "" then
    vim.notify("Empty figure name", vim.log.levels.WARN)
    return
  end

  local root = get_root()
  local fig_dir = root .. "/figures"

  vim.fn.mkdir(fig_dir, "p")

  local svg_path = fig_dir .. "/" .. name .. ".svg"

  if vim.fn.filereadable(svg_path) == 1 then
    vim.notify("Figure already exists, opening...", vim.log.levels.INFO)
    vim.fn.jobstart({ "inkscape", svg_path }, { detach = true })
    return
  end

  local template = vim.fn.expand("~/.config/inkscape-figures/template.svg")
  if vim.fn.filereadable(template) == 1 then
    vim.fn.system({ "cp", template, svg_path })
  else
    local blank = [[<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     width="1000" height="800" viewBox="0 0 1000 800">
</svg>]]
    local f = io.open(svg_path, "w")
    if f then
      f:write(blank)
      f:close()
    end
  end
    
vim.defer_fn(function()
   vim.fn.jobstart({ "inkscape", svg_path }, { detach = true })
end, 200)

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local boilerplate = {
    "\\begin{figure}[ht]",
    "    \\centering",
    "    \\incfig{" .. name .. "}",
    "    \\caption{" .. name .. "}",
    "    \\label{fig:" .. name .. "}",
    "\\end{figure}",
  }
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, boilerplate)
  
end

local function search_figures()
  local root = get_root()
  local fig_dir = root .. "/figures"
  if vim.fn.isdirectory(fig_dir) == 0 then
    vim.notify("No figures directory found", vim.log.levels.WARN)
    return
  end

  local ok, telescope = pcall(require, "telescope.builtin")
  if ok then
    telescope.find_files({
      cwd = fig_dir,
      prompt_title = "Figures",
      find_command = { "find", ".", "-name", "*.svg", "-type", "f" },
      attach_mappings = function(_, map)
        local function open_in_inkscape(prompt_bufnr)
          local entry = require("telescope.actions.state").get_selected_entry(prompt_bufnr)
          require("telescope.actions").close(prompt_bufnr)
          if entry then
            vim.fn.jobstart({ "inkscape", fig_dir .. "/" .. entry[1] }, { detach = true })
          end
        end
        map("i", "<CR>", open_in_inkscape)
        map("n", "<CR>", open_in_inkscape)
        return true
      end,
    })
  else
    local files = vim.fn.globpath(fig_dir, "*.svg", false, true)
    vim.ui.select(files, { prompt = "Select figure:" }, function(choice)
      if choice then
        vim.fn.jobstart({ "inkscape", choice }, { detach = true })
      end
    end)
  end
end

vim.keymap.set("i", "<C-f>", function()
  vim.cmd("stopinsert")
  create_figure()
end, { desc = "Create Inkscape figure" })

vim.keymap.set("n", "<C-f>", function()
  search_figures()
end, { desc = "Search Inkscape figures" })
