-- ~/.config/nvim/lua/options.lua
local o = vim.opt

o.number = true
o.relativenumber = true
o.conceallevel = 2       -- Castel used 1; 2 fully hides concealable text
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true
o.wrap = true
o.linebreak = true       -- wrap at word boundaries (important for prose)
o.clipboard = "unnamedplus"  -- use system clipboard (wl-clipboard)
o.updatetime = 250
o.signcolumn = "yes"
o.termguicolors = true

-- Transparent background (actual opacity is controlled by your terminal emulator)
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local groups = { "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer", "LineNr", "Folded", "NonText" }
    for _, group in ipairs(groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
    end
  end,
})
-- Also apply immediately in case colorscheme is already loaded
vim.schedule(function()
  local groups = { "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer", "LineNr", "Folded", "NonText" }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
end)
